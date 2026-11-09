from pathlib import Path
import re,contextlib,io,copy,json
from luaparser import ast,astnodes as N
import source_ast as H
R=Path(__file__).resolve().parent
s=(R/'recovered.structured.lua').read_text();decl=s.split('\n',1)[0];s=decl+'\n'+s[s.index('L4_1 = client'):]
# Reconstruct this short selection directly from the decoded CFG: unluac
# misnests its overlapping forward branches.
s=re.sub(r'function L63_1\(.*?\nend\n', '''function L63_1(delta, player, alternate, ...)
    local index
    if delta >= 0 and delta < 16 then
        index = alternate and 1 or 3
    elseif delta > 0 then
        index = alternate and 2 or 1
    elseif delta < 0 then
        index = alternate and 3 or 2
    else
        index = false
    end
    return L49_1[L51_1[player].stage][index]
end
''', s, count=1, flags=re.S)
preserved={}

def protect(m):
 x=m[0]
 if '\\'not in x and all(ord(c)<128 for c in x):return x
 k='__SAURON_LITERAL_%d__'%len(preserved);preserved[k]=x;return k
with contextlib.redirect_stdout(io.StringIO()):tree=ast.parse(re.sub(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'',protect,s))
repairs=[]
def visit(n):
 if isinstance(n,N.Forin):n.body.body.insert(0,N.If(test=N.ULNotOp(operand=copy.deepcopy(n.targets[0])),body=N.Block([N.Break()]),orelse=None))
 if isinstance(n,N.Block):
  for i,st in enumerate(n.body):
   if isinstance(st,N.Assign)and len(st.targets)==len(st.values)==1 and isinstance(st.values[0],(N.Dots,N.Varargs)):
    name=st.targets[0].id
    # Open VARARG consumed by a following open CALL in the UI creator.
    if i+1<len(n.body)and isinstance(n.body[i+1],N.Return):
     ret=n.body[i+1]
     if len(ret.values)==1 and isinstance(ret.values[0],N.Call)and ret.values[0].args and isinstance(ret.values[0].args[-1],N.Name)and ret.values[0].args[-1].id==name:
      ret.values[0].args[-1]=N.Dots();st.values=[N.Nil()];repairs.append(name)
 for field,i,ch in list(H.children(n)):
  new=visit(ch)
  if i is None:setattr(n,field,new)
  else:getattr(n,field)[i]=new
 if isinstance(n,N.Function):return N.Assign(targets=[n.name],values=[N.AnonymousFunction(args=n.args,body=n.body)])
 if isinstance(n,N.ElseIf):return N.If(test=n.test,body=n.body,orelse=n.orelse)
 if isinstance(n,N.If)and isinstance(n.orelse,N.If):n.orelse=N.Block([n.orelse])
 return n
visit(tree)
names={4:'color_log',5:'eye_position',6:'random_int',7:'register_esp_flag',8:'screen_size',9:'set_event_callback',10:'unset_event_callback',11:'trace_bullet',12:'update_player_list',13:'userid_to_entindex',14:'get_local_player',15:'get_player_weapon',16:'get_players',17:'get_prop',18:'hitbox_position',19:'frametime',20:'atan',21:'cos',22:'floor',23:'max',24:'min',25:'rad',26:'sin',27:'sqrt',28:'plist_get',29:'plist_set',30:'draw_line',31:'measure_text',32:'draw_rectangle',33:'draw_text',34:'world_to_screen',35:'table_remove',36:'to_number',37:'require_module',38:'pairs_iter',39:'ui_get',40:'ui_name',41:'original_func',42:'print_message',43:'ui_set_callback',44:'ui_set_visible',45:'notifications',46:'weapon_data',47:'vector_constructor',48:'menu',49:'yaw_presets',50:'stage_defaults',51:'player_state',52:'player_history',53:'remember_ui_references',54:'log_message',55:'controls',56:'reset_player_state',57:'on_player_death',58:'on_round_start',59:'on_player_connect',60:'round_number',61:'weapon_is_selected',62:'contains',63:'select_preset_yaw',64:'normalize_yaw',65:'yaw_between_points',66:'trace_hitbox_offsets',67:'angles_to_direction',68:'classify_movement',69:'same_side_of_threshold',70:'on_setup_command',71:'on_aim_hit',72:'on_aim_miss',73:'update_callbacks'}
def rename(n):
 if isinstance(n,N.Name):
  m=re.fullmatch(r'L(\d+)_1',n.id)
  if m and int(m[1])in names:n.id=names[int(m[1])]
 for field,_,ch in H.children(n):
  if isinstance(n,N.Index)and field=='idx'and n.notation==N.IndexNotation.DOT:continue
  rename(ch)
rename(tree)
main=N.LocalFunction(name=N.Name('main'),args=[N.Varargs()],body=tree.body)
# Keep a test-only helper table, omitted from distributed script.
export=N.Return(values=[N.Table(fields=[N.Field(key=N.String(v),value=N.Name(v),between_brackets=True)for k,v in names.items()if k>=46])])
def output(t,path):
 def lists(n):
  if isinstance(n,N.Field)and isinstance(n.key,N.Number)and n._first_token is not None and n._first_token.text!='[':n.key=N.Name('__LIST__');n.between_brackets=True
  for _,_,c in H.children(n):lists(c)
 lists(t)
 with contextlib.redirect_stdout(io.StringIO()):text=ast.to_lua_source(t)
 text=re.sub(r'\[__LIST__\]\s*=\s*','',text);text=re.sub(r'\b__SAURON_LITERAL_\d+__\b',lambda m:preserved[m[0]],text)
 pack='local function __dec14_pack_results(...) return {n=select("#",...),...} end\n'
 path.write_text((pack+text+'\n').replace('__dec14_pack_results','pack_results'))
tree.body=N.Block([main,N.Return(values=[N.Call(func=N.Name('main'),args=[N.Dots()])])]);output(copy.deepcopy(tree),R/'source.lexical.lua')
main.body.body.append(export);output(tree,R/'source.test.lua')
import readability
readability.transform(R/'source.lexical.lua',R/'sauron_resolver_source.lua')
readability.transform(R/'source.test.lua',R/'source.test.optimized.lua')
print('vararg repairs',repairs,'optimizer',readability.statistics)
(R/'names.json').write_text(json.dumps(names,indent=2))

p=R/'sauron_resolver_source.lua'
s=p.read_text().split('\n',1)[1]
p.write_text('-- Sauron resolver: recovered editable GameSense Lua.\n-- PSU VM, encoded payload and unused padding removed. Names inferred.\n-- Requires gamesense/csgo_weapons and vector. See README_RU.txt.\n'+s)
