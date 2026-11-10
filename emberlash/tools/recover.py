from analyze import *
import csv,hashlib,io,collections
from lupa.luajit21 import LuaRuntime
A=Analysis().run()
B={b.id:b for b in A.bindings}
# Labels below describe roles visible in methods/fields, not original author names.
MANUAL={41:'build_info',44:'constants',46:'ffi_lib',107:'menu',108:'native_contracts',109:'feature_registry',118:'logger',119:'diagnostic_log',258:'events',259:'lifecycle',264:'event_bus_class',343:'callback_group_class',401:'native_patcher',489:'native_patcher_impl',1193:'native_patch_class',1322:'x86_assembler',1610:'native_feature_class',2128:'entity_cache',2129:'trace_cache',2279:'private_transport',2481:'transport_runtime',2534:'bit_buffer',2766:'gamesense_controls',2823:'draw_helpers',2951:'math_helpers',2989:'animation_manager',3040:'control_override',3102:'shared_control_owners',3142:'antiaim_backend',3143:'player_state',3287:'yaw_scheduler',3607:'preset_manager',3611:'preset_catalog',3660:'local_configs',3740:'config_browser',4015:'preset_decoder',4074:'cloud_api',4790:'account_rewards',5066:'manual_antiaim',5067:'defensive_antiaim',5071:'ladder_antiaim',5072:'legit_antiaim',5073:'backstab_guard',5075:'native_edge_yaw',5077:'antiaim_builder',5180:'anti_bruteforce',5181:'target_selector',5208:'peek_scan_state',5209:'peek_scan_targets',5210:'peek_scan_settings',6483:'defensive_predictor',7092:'native_antiaim_bridge',8278:'session_statistics',8630:'aimtools',9186:'shot_feedback_policy',9501:'autostop_controller',9688:'movement_cvars',10099:'literal_patch_class',10156:'native_feature_compat',10258:'rage_target_priority',10343:'damage_snapshot',10536:'prediction_frame_hook',11253:'network_update_hook',11403:'roll_feedback_hook',12005:'penetration_feedback_hook',12246:'record_builder_policy',12573:'lag_compensation_policy',12882:'interpolation_policy',13012:'tick_anchor_policy',13250:'record_enrichment',13463:'prediction_observer',14299:'dt_charge_hook',14503:'quick_peek_return_hook',14764:'peek_math',14842:'peek_states',14845:'quick_peek_runtime',15508:'theme_colors',15509:'hud_panels',15540:'hud_effects',15622:'center_indicator',16111:'draggable_class',16176:'rounded_rect_pool',16238:'shadow_rect_pool',16432:'watermark_state',16756:'hotkey_panel_state',16838:'exploit_indicator_state',16839:'fakelag_indicator_state',16840:'status_panel_state',16988:'spectator_panel_state',17286:'shot_log_state',17558:'record_provenance_cache',17958:'shot_log_formatter',18069:'bomb_panel_state',18070:'bomb_timer_state',18363:'target_panel_style',18364:'target_panel_state',18366:'target_panel_animation',18369:'target_weapon_animation',18542:'crosshair_indicator_style',18995:'viewmodel_override',19081:'leg_animation_override',19240:'steam_status_override'}
# Remove a manual label if its role cannot be justified by its initializer.
# In particular import bindings are inferred from the actual string argument.
MANUAL.pop(46,None)
api={int(m[1]):m[2] for m in re.finditer(rb'^\[(\d+)\]="([^"\n]+)",?$',SRC,re.M)}
api={i:v.decode() for i,v in api.items()}
C=collections.defaultdict(list)

def propose(b,name,score):
 if name and b and b.id>0:C[b.id].append((score,name))
def slug(s):
 s=re.sub(r'[^A-Za-z0-9_]+','_',s).strip('_')
 if not s or s[0].isdigit():s='value_'+s
 return s[:64]
def infer_expr(n):
 if n is None:return None
 k=n.type
 if k=='identifier':
  b=A.uses.get(n.start_byte)
  return b.new if b and b.new else text(n) if text(n) not in ('a','v','cond','val','tmp') and not re.fullmatch(r'(?:v|val|tbl|fn|tmp|cond|n|flag|str)_?\d*',text(n)) else None
 if k in ('dot_index_expression','method_index_expression'):
  f=n.child_by_field_name('field') or n.child_by_field_name('method');root=n.child_by_field_name('table')
  root_name=infer_expr(root);name=text(f)
  if root and root.type=='identifier' and text(root) in ('math','string','table','bit','coroutine'):return slug(text(root)+'_'+name)
  return slug(name)
 if k=='bracket_index_expression':
  table=n.child_by_field_name('table');f=n.child_by_field_name('field')
  if table and text(table)=='a' and f and f.type=='number':return slug(api.get(int(text(f)),'')) or None
 if k=='function_call':
  name=n.child_by_field_name('name');args=n.child_by_field_name('arguments');values=args.named_children if args else []
  # The checked import helper is recognized from the original source body.
  if values and values[0].type=='string':
   nb=A.uses.get(name.start_byte) if name and name.type=='identifier' else None
   if text(name)=='require' or nb and any(v.type=='function_definition' and 'pcall(require,' in text(v) for v in nb.values):
    module=text(values[0])[1:-1];return slug(module.split('/')[-1])+'_lib'
  callee=infer_expr(name)
  if callee:return callee+'_result'
 return None

# Recover names from explicit assignments of aliases to named table members.
def gather(n):
 if n.type=='assignment_statement':
  vl=next((x for x in n.named_children if x.type=='variable_list'),None);el=next((x for x in n.named_children if x.type=='expression_list'),None)
  if vl and el:
   for t,v in zip(vl.named_children,el.named_children):
    if v.type=='identifier' and t.type in ('dot_index_expression','method_index_expression'):
     name=t.child_by_field_name('field') or t.child_by_field_name('method');b=A.uses.get(v.start_byte)
     propose(b,text(name),75)
 for c in n.named_children:gather(c)
gather(TREE.root_node)
reserved=set()
def reserve_names(n):
 if n.type=='identifier':reserved.add(text(n))
 if n.type=='string':return
 for c in n.named_children:reserve_names(c)
reserve_names(TREE.root_node)
keywords=set('and break do else elseif end false for function goto if in local nil not or repeat return then true until while'.split())
used=set(reserved)|keywords

def select_name(b,stem):
 stem=slug(stem)
 if stem not in used:used.add(stem);return stem
 name=stem+'_'+str(b.id)
 while name in used:name+='_' 
 used.add(name);return name

generic=re.compile(r'^(?:a_\d+|b|c|d|e|f|g|h|i|j|k|v|val|tbl|fn|tmp|cond|flag|str|n)(?:_\d+)*$')
for b in A.bindings:
 if b.id in MANUAL:b.new=select_name(b,MANUAL[b.id])
# All inferred aliases are read from their initializers. No expressions are evaluated.
for iteration in range(3):
 for b in A.bindings:
  if b.new or not generic.fullmatch(b.old):continue
  for v in b.values:
   name=infer_expr(v)
   if name:propose(b,name,60 if v.type in ('identifier','dot_index_expression','bracket_index_expression') else 50)
   if v.type in ('function_definition','function_declaration') and 'pcall(require,' in text(v):propose(b,'load_library',100)
  if C[b.id]:
   _,name=max(C[b.id]);b.new=select_name(b,name)
# Generic parameters and temporaries are made unique and named by observable type.
for b in A.bindings:
 if b.new or not generic.fullmatch(b.old):continue
 if b.kind=='parameter':
  fn=next((f for f in A.functions if f['scope'] is b.scope),None)
  is_first=bool(fn and fn['args'] and fn['args'][0] is b)
  # Reading/writing multiple fields suggests a state/object argument, not an original name.
  role='state' if b.fields else 'argument'
  if is_first and b.fields:role='self_state'
 elif b.kind=='loop':role='index' if b.old.startswith('i') else 'key' if b.old.startswith('k') else 'item'
 elif b.kind=='function' or any(v.type in ('function_definition','function_declaration') for v in b.values):role='helper'
 elif any(v.type=='table_constructor' for v in b.values):role='state_table' if b.fields else 'values'
 elif any(v.type in ('true','false') for v in b.values):role='enabled'
 elif any(v.type=='number' for v in b.values):role='number_value'
 elif any(v.type=='string' for v in b.values):role='text_value'
 else:role='result' if b.values else 'slot'
 b.new=select_name(b,role)

# Only lexical identifier tokens are replaced; table keys, strings, globals,
# expressions and control flow remain unchanged.
edits={}
for b in A.bindings:
 if b.new:
  for n in b.refs:
   assert text(n)==b.old
   edits[(n.start_byte,n.end_byte)]=b.new.encode()
parts=[];at=0
for (start,end),value in sorted(edits.items()):parts.extend([SRC[at:start],value]);at=end
parts.append(SRC[at:]);renamed=b''.join(parts)

LUA=LuaRuntime(encoding=None)
compile_dump=LUA.eval(b'function(s) local f,e=loadstring(s,"@emberlash.lua"); assert(f,e); return string.dump(f,"sd") end')
original_dump=compile_dump(SRC);renamed_dump=compile_dump(renamed)
if original_dump!=renamed_dump:
 (ROOT/'renamed.failed.lua').write_bytes(renamed)
 raise AssertionError('Lexical rename changed LuaJIT bytecode; refusing output')
(ROOT/'emberlash.renamed.lua').write_bytes(renamed)
(ROOT/'symbols.json').write_text(json.dumps([{'id':b.id,'original':b.old,'recovered':b.new or b.old,'line':line(b.node),'kind':b.kind,'uses':len(b.refs)}for b in A.bindings],indent=2))
print('Renamed',sum(bool(b.new) for b in A.bindings),'bindings;',len(edits),'identifier tokens. Bytecode identical.',flush=True)
# A second parse gives exact positions after names have changed.
T2=Parser(Language(tree_sitter_lua.language())).parse(renamed);assert not T2.root_node.has_error
rows=renamed.splitlines(keepends=True);delta=[0]*(len(rows)+1);protected=set();api_edits=[];functions=[];loops=[];sections={}

def visit(n):
 if n.type=='string' and n.end_point.row>n.start_point.row:protected.update(range(n.start_point.row+1,n.end_point.row+1))
 if n.type=='block' and n.parent.type!='do_statement':
  delta[n.start_point.row]+=1;delta[n.end_point.row+1]-=1
 if n.type=='table_constructor' and n.end_point.row>n.start_point.row:
  delta[n.start_point.row+1]+=1;delta[n.end_point.row]-=1
 if n.type=='bracket_index_expression':
  table=n.child_by_field_name('table');f=n.child_by_field_name('field')
  if table and renamed[table.start_byte:table.end_byte]==b'a' and f and f.type=='number':
   idx=int(renamed[f.start_byte:f.end_byte]);name=api.get(idx)
   if name:api_edits.append((n.end_byte,b' --[[ '+name.encode()+b' ]]'))
 if n.type in ('function_definition','function_declaration'):
  functions.append(n)
 if n.type in ('while_statement','repeat_statement'):
  test=n.child_by_field_name('condition');loops.append({'line':n.start_point.row+1,'condition':renamed[test.start_byte:test.end_byte].decode() if test else ''})
 if n.type not in ('string','comment'):
  for c in n.named_children:visit(c)
visit(T2.root_node)
# API comments are inserted at token boundaries and cannot change lookup timing.
extra={}
for pos,v in api_edits:extra.setdefault(pos,[]).append(v)
parts=[];at=0
for pos,values in sorted(extra.items()):parts.extend([renamed[at:pos],*values]);at=pos
parts.append(renamed[at:]);annotated=b''.join(parts)
annotated_rows=annotated.splitlines(keepends=True);assert len(annotated_rows)==len(rows)
for bid,heading in MANUAL.items():sections.setdefault(line(B[bid].node)-1,[]).append(heading)
output=[];depth=0;line_map={};current_line=1
header=b'-- Emberlash v3.1.1: complete readable reconstruction of the supplied Lua.\n-- Local names are inferred; strings, code, scopes and all functions are preserved.\n-- See README_RU.md and validation.json for scope and bytecode verification.\n\n'
output.append(header);current_line+=header.count(b'\n')
for i,row in enumerate(annotated_rows):
 depth+=delta[i]
 if i in sections:
  banner=b'\n-- === '+', '.join(sections[i]).encode()+b' ===\n';output.append(banner);current_line+=banner.count(b'\n')
 line_map[i+1]=current_line
 if i in protected:out=row
 else:out=b'    '*max(0,depth)+row.lstrip(b' \t')
 output.append(out);current_line+=out.count(b'\n')
source=b''.join(output);final_dump=compile_dump(source)
assert final_dump==original_dump,'Formatting changed LuaJIT bytecode; refusing output'
(ROOT/'emberlash_source.lua').write_bytes(source)
(ROOT/'original.lua').write_bytes(SRC)
# Count every serialized LuaJIT prototype, including the main chunk.
def uleb(data,pos):
 result=0;shift=0
 while True:
  c=data[pos];pos+=1;result|=(c&127)<<shift
  if c<128:return result,pos
  shift+=7
pos=4;flags,pos=uleb(original_dump,pos)
if not flags&2:
 length,pos=uleb(original_dump,pos);pos+=length
prototypes=0
while True:
 length,pos=uleb(original_dump,pos)
 if not length:break
 prototypes+=1;pos+=length
assert pos==len(original_dump)
assert prototypes==len(functions)+1,(prototypes,len(functions))
report={'input_file':'emberlash_decompiled.lua','input_sha256':hashlib.sha256(SRC).hexdigest(),'source_sha256':hashlib.sha256(source).hexdigest(),'input_bytes':len(SRC),'source_bytes':len(source),'input_lines':len(SRC.splitlines()),'source_lines':len(source.splitlines()),'functions_preserved':len(functions),'luajit_prototypes_including_main':prototypes,'local_bindings':len(A.bindings),'bindings_renamed':sum(bool(b.new) for b in A.bindings),'identifier_tokens_renamed':len(edits),'api_references_annotated':len(api_edits),'stripped_luajit_bytecode_identical':True,'deterministic_dump_mode':'sd','stripped_bytecode_sha256':hashlib.sha256(original_dump).hexdigest(),'stripped_bytecode_bytes':len(original_dump),'runtime_executed':False,'l uraph_vm_removed_in_this_pass':False,'original_protected_build_available':False,'loop_conditions':loops}
report['luraph_vm_removed_in_this_pass']=report.pop('l uraph_vm_removed_in_this_pass')
(ROOT/'validation.json').write_text(json.dumps(report,indent=2)+'\n')
# Generate navigable function/symbol inventories without executing any callbacks.
def renamed_text(n):return renamed[n.start_byte:n.end_byte].decode()
def function_label(n):
 name=n.child_by_field_name('name')
 if name:return renamed_text(name)
 parent=n.parent
 if parent.type=='expression_list' and parent.parent.type=='assignment_statement':
  assign=parent.parent;vl=next(c for c in assign.named_children if c.type=='variable_list');vs=parent.named_children
  index=next((i for i,c in enumerate(vs) if c==n),0)
  if index<len(vl.named_children):return renamed_text(vl.named_children[index])
 if parent.type=='field':
  key=parent.child_by_field_name('name')
  if key:return 'field:'+renamed_text(key)
 if parent.type=='arguments':
  call=parent.parent;name=call.child_by_field_name('name')
  return 'callback:'+renamed_text(name) if name else 'callback'
 return 'anonymous'
with (ROOT/'FUNCTIONS.csv').open('w',newline='') as f:
 w=csv.writer(f);w.writerow(['id','name','source_start_line','source_end_line','input_start_line','parameters'])
 for i,n in enumerate(functions,1):
  params=n.child_by_field_name('parameters');w.writerow([i,function_label(n),line_map[n.start_point.row+1],line_map[n.end_point.row+1],n.start_point.row+1,renamed_text(params) if params else ''])
with (ROOT/'SYMBOLS.csv').open('w',newline='') as f:
 w=csv.writer(f);w.writerow(['id','original','recovered','source_line','input_line','kind','uses'])
 for b in A.bindings:w.writerow([b.id,b.old,b.new or b.old,line_map[line(b.node)],line(b.node),b.kind,len(b.refs)])
(ROOT/'API_MAP.json').write_text(json.dumps(api,indent=2)+'\n')
print(json.dumps({k:v for k,v in report.items() if k!='loop_conditions'},indent=2),flush=True)
