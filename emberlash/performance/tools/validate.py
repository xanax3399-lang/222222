"""Exercise extracted production UI helpers with LuaJIT and controlled host APIs."""
from pathlib import Path
import json,hashlib,time,sys
from collections import Counter
from tree_sitter import Language,Parser
import tree_sitter_lua
from lupa.luajit21 import LuaRuntime
ROOT=Path(__file__).resolve().parent.parent
old=(ROOT.parent/'emberlash_source.lua').read_text();new=(ROOT/'emberlash_optimized.lua').read_text()
parser=Parser(Language(tree_sitter_lua.language()))

def functions(s):
 raw=s.encode();root=parser.parse(raw).root_node;assert not root.has_error
 out=[]
 def walk(n):
  if n.type in ('function_definition','function_declaration'):out.append((n,raw[n.start_byte:n.end_byte].decode()))
  if n.type not in ('string','comment'):
   for c in n.named_children:walk(c)
 walk(root);return out
F={id(s):functions(s) for s in [old,new]}
RAW={id(old):old.encode(),id(new):new.encode()}

def assigned(s,label):
 for n,text in F[id(s)]:
  p=n.parent
  if p.type=='expression_list' and p.parent.type=='assignment_statement':
   assign=p.parent;vl=next(c for c in assign.named_children if c.type=='variable_list')
   raw=RAW[id(s)];names=[raw[c.start_byte:c.end_byte].decode()for c in vl.named_children]
   if label in names:return text
  if n.type=='function_declaration':
   name=n.child_by_field_name('name')
   if name and RAW[id(s)][name.start_byte:name.end_byte].decode()==label:return text
 raise KeyError(label)

def iife(s,marker):
 candidates=[text for _,text in F[id(s)]if marker in text]
 return min(candidates,key=len)

def runtime():return LuaRuntime(unpack_returned_tuples=True)
checks=0

def check(x,msg):
 global checks
 checks+=1
 assert x,msg

# Verify the complete new file compiles, without invoking its native main chunk.
lua=runtime();compile_lua=lua.eval('function(s)local f,e=loadstring(s);assert(f,e);return #string.dump(f,"sd")end')
check(compile_lua(new)>0,'complete optimized source compiles')
# Preserve the entire native/rage/antiaim source region, not just a mocked API.
def core_region(s):return s[s.index('-- === control_override'):s.index('-- === theme_colors')]
check(core_region(old)==core_region(new),'native/rage/antiaim region is byte-for-byte unchanged')
core_hash=hashlib.sha256(core_region(old).encode()).hexdigest()

# Real animation-manager module: randomized retargets, resets, tolerances,
# duration changes and custom easing with observable call counts.
def animation_factory(s):
 body=iife(s,'local math_min_2994 =')
 return '''return function(host)
 local animation_manager={};local type_2=type;local math_max=math.max;local math_min=math.min
 local globals_framecount=function()return host.frame end
 local a={[161]=math.abs,[162]=math.min,[18]=function()return host.dt end,[19]=function()return host.dt end}
 ('''+body+''')()
 return animation_manager
 end'''
la=runtime();make_old=la.execute(animation_factory(old));make_new=la.execute(animation_factory(new))
animation_test=la.eval('''function(make_old,make_new)
 local host={frame=0,dt=1/120};local a,b=make_old(host),make_new(host)
 local oa,ob={},{};local ea,eb=0,0
 local function ease_a(x)ea=ea+1;return x*x*.75 end
 local function ease_b(x)eb=eb+1;return x*x*.75 end
 local function equal(x,y)return x==y or x~=x and y~=y end
 local total=0
 math.randomseed(18471)
 for frame=1,2400 do
  host.frame=frame;host.dt=(frame%173==0 and 0 or frame%181==0 and .2 or 1/(60+frame%180))
  for j=1,12 do
   local key='channel'..j
   local target=frame<20 and 0 or frame<160 and 1 or frame<500 and 1.000001 or math.random(-500,500)/10
   local duration=frame%311==0 and 0 or frame%317==0 and -.2 or j%3==0 and .3 or .15
   local custom=j==4
   local x=a.to(oa,key,target,duration,j%2==0 and .001 or nil,custom and ease_a or nil,j==3)
   local y=b.to(ob,key,target,duration,j%2==0 and .001 or nil,custom and ease_b or nil,j==3)
   assert(equal(x,y),'animation mismatch at '..frame..'/'..j)
   assert(equal(oa[key],ob[key]));total=total+1
  end
  local x=a.interp(2,frame<1000 and true or false,.25,'bool')
  local y=b.interp(2,frame<1000 and true or false,.25,'bool')
  assert(equal(x,y));total=total+1
  if frame%211==0 then a.clear_owner(oa,'channel1');b.clear_owner(ob,'channel1') end
  if frame%997==0 then a.clear_owner(oa);b.clear_owner(ob);a.clear('bool');b.clear('bool') end
 end
 assert(ea==eb,'custom easing side effects changed')
 -- Settled positive/negative/zero values and nonfinite inputs.
 for _,v in ipairs({0,-0.0,1,-1,1e100,-1e100,math.huge,-math.huge,0/0})do
  local x=a.to(oa,'edge',v,.1,.0001);local y=b.to(ob,'edge',v,.1,.0001)
  assert(equal(x,y));total=total+1
 end
 return total,ea
 end''')
check(iife(old,'local math_min_2994 =')==iife(new,'local math_min_2994 ='),'animation module unchanged')
comparisons,custom_calls=animation_test(make_old,make_new)
check(comparisons>=30000 and custom_calls>0,'animation differential suite')
# Execute the exact inserted HUD cache block. No cached result survives a frame.
a=new.index('    -- HUD-only snapshots');b=new.index('    local perf_lightweight_hud',a)
cache_code=new[a:b]
lc=runtime();cache_factory=lc.execute('''return function(host)
 local globals_framecount_15533=function()return host.frame end
 local type=type;local renderer_measure_text_15537=host.measure;local client_screen_size_15535=host.screen
 '''+cache_code+'''
 return {measure=renderer_measure_text_15537,screen=client_screen_size_15535}
 end''')
cache_test=lc.eval('''function(make)
 local h={frame=1,scale=1,w=1440,h=1080,measures=0,screens=0}
 h.measure=function(...)h.measures=h.measures+1;local f,s=...;if type(f)~='string' or type(s)~='string'then error('invalid text')end
  local extra=select('#',...);return #s*6*h.scale+extra,#f+10 end
 h.screen=function(...)h.screens=h.screens+1;return h.w+(select('#',...)),h.h end
 local c=make(h)
 for i=1,100 do local w,y=c.measure('b','Emberlash');assert(w==56 and y==11);local sw,sh=c.screen();assert(sw==1440 and sh==1080) end
 assert(h.measures==1 and h.screens==1)
 c.measure('b','another');c.measure('','Emberlash');assert(h.measures==3)
 c.measure('a\\0','b');c.measure('a','\\0b');assert(h.measures==5,'string-key collision')
 h.frame=2;h.scale=2;h.w=1920;h.h=1080
 assert(c.measure('b','Emberlash')==110);assert(c.screen()==1920);assert(h.measures==6 and h.screens==2)
 c.measure('b','Emberlash','extra',nil);c.measure('b','Emberlash','extra',nil);assert(h.measures==8,'vararg fallback')
 local ok=pcall(c.measure,nil,'bad');assert(not ok,'error behavior')
 for i=1,1300 do c.measure('b','dynamic'..i) end
 local upcache
 for i=1,30 do local n,v=debug.getupvalue(c.measure,i);if not n then break end;if n=='text_cache'then upcache=v end end
 local entries=0;for _,bucket in pairs(upcache)do for _ in pairs(bucket)do entries=entries+1 end end
 assert(entries<=512,'unbounded text cache')
 h.frame=1;h.scale=3;assert(c.measure('b','Emberlash')==164,'frame rollback invalidation')
 return h.measures,h.screens,entries,100,1
 end''')
measure_calls,screen_calls,entries,repeat_calls,native_calls=cache_test(cache_factory)
check(entries<=512,'bounded text cache, invalidation, fallback, collisions and arity')

# Shared drag state: compare production methods for many windows each frame.
start=new.index('    local perf_read_drag_input\n');end=new.index('    draggable_class._refresh_input',start)
drag_shared=new[start:end]
def drag_factory(s):
 fn=assigned(s,'draggable_class._refresh_input')
 return '''return function(host)
 local type=type;local a={[64]=function()host.keys=host.keys+1;return host.down end}
 local globals_framecount_15533=function()return host.frame end
 local client_screen_size_15535=function()host.screens=host.screens+1;return host.w,host.h end
 local pui_lib={is_menu_open=function()host.opens=host.opens+1;return host.open end,
 mouse_position=function()host.mouse=host.mouse+1;return host.x,host.y end,
 menu_position=function()host.positions=host.positions+1;return 100,200 end,
 menu_size=function()host.sizes=host.sizes+1;return 400,300 end}
 local animation_manager={to=function(o,k,v)o[k]=v end}
 '''+(drag_shared if s is new else '')+'''
 return '''+fn+''' end'''
ld=runtime();df0=ld.execute(drag_factory(old));df1=ld.execute(drag_factory(new))
drag_test=ld.eval('''function(f0,f1)
 local function host()return {frame=1,keys=0,screens=0,opens=0,mouse=0,positions=0,sizes=0,w=1440,h=1080,x=10,y=20,down=false,open=false}end
 local a,b=host(),host();local fa,fb=f0(a),f1(b);local oa,ob={},{}
 local function owner()return {last_frame=-1,mouse_down=false,menu_open=false,dragging=false,visual={},_clear_drag=function(s)s.dragging=false;s.cleared=(s.cleared or 0)+1 end}end
 for i=1,12 do oa[i]=owner();ob[i]=owner() end
 local n=0
 for f=1,120 do
  a.frame,b.frame=f,f;a.down=f%5<2;b.down=a.down;a.open=f%9<6;b.open=a.open;a.x=f;b.x=f
  for i=1,12 do
   fa(oa[i],true);fb(ob[i],true)
   for _,k in ipairs({'last_frame','mouse_down','prev_mouse_down','menu_open','mouse_x','mouse_y','menu_x','menu_y','menu_w','menu_h','screen_w','screen_h','dragging','cleared'})do assert(oa[i][k]==ob[i][k],k) end
   assert(oa[i].visual.fade==ob[i].visual.fade and oa[i].visual.bounds==ob[i].visual.bounds)
   fa(oa[i],true);fb(ob[i],true);n=n+1
  end
 end
 assert(a.keys==1440 and b.keys==120 and a.mouse==1440 and b.mouse==120)
 return n,a.keys,b.keys
 end''')
drag_cases,old_input,new_input=drag_test(df0,df1)
check(drag_cases==1440 and old_input>new_input,'shared input preserves per-window state')

# Actual effects functions and validation; the Panorama boundary is controlled.
def effects_factory(s):
 finite=assigned(s,'hud_effects.finite_number');blur=assigned(s,'hud_effects.draw_blur');shadow=assigned(s,'hud_effects.draw_shadow')
 return '''return function()
 local calls={};local factories=0;local perf_lightweight_hud=true
 local function factory()factories=factories+1;return {renderer_rect=function(...)calls[#calls+1]={...}end}end
 local result_16221='''+('factory' if s is new else 'factory()')+'''
 local result_16283='''+('factory' if s is new else 'factory()')+'''
 local math_floor_15512,math_max_15513,math_min_15514=math.floor,math.max,math.min
 local hud_effects={};hud_effects.finite_number='''+finite+'''
 hud_effects.draw_blur='''+blur+'''
 hud_effects.draw_shadow='''+shadow+'''
 return hud_effects,function(v)perf_lightweight_hud=v end,function()return factories,#calls,calls end
 end'''
le=runtime();ef0=le.execute(effects_factory(old));ef1=le.execute(effects_factory(new))
effects_test=le.eval('''function(f0,f1)
 local old,_,so=f0();local new,set,sn=f1()
 for i=1,100 do new.draw_blur(10,20,100,30,200,5,.7,8);new.draw_shadow(10,20,100,30,8,200,100)end
 local factories,calls=sn();assert(factories==0 and calls==0,'lightweight mode allocates/draws effects')
 set(false)
 for i=1,2 do
  old.draw_blur(10,20,100,30,200,5,.7,8);old.draw_shadow(10,20,100,30,8,200,100)
  new.draw_blur(10,20,100,30,200,5,.7,8);new.draw_shadow(10,20,100,30,8,200,100)
 end
 local fo,co,ao=so();local fn,cn,an=sn();assert(fo==2 and fn==2 and co==cn)
 for i=1,co do for j,v in ipairs(ao[i])do assert(v==an[i][j],'effect geometry changed')end end
 set(true);new.draw_shadow(10,20,100,30,8,200,100);local f,c=sn();assert(f==2 and c==cn)
 return factories,calls,co,fn
 end''')
no_factories,no_draws,full_draws,live_factories=effects_test(ef0,ef1)
check(no_factories==0 and no_draws==0 and full_draws==4,'lightweight off/full effect equivalence and lazy lifetime')

# Real pre-render handlers: an empty frame must hide prior nodes exactly once.
def pool_factory(s,label,poolname):
 fn=assigned(s,label)
 return '''return function()
 local p={count=0,max_rects=12,pool={},rects={},hides=0,applies=0}
 for i=1,4 do p.pool[i]={visible=false}end
 p.ensure_pool=function()end
 p.hide_node=function(n)p.hides=p.hides+1;n.visible=false end
 p.apply_node=function(n,r)p.applies=p.applies+1;n.visible=true end
 p.clear_rects=function()p.count=0 end
 local '''+poolname+'''=p;local math_min_15514=math.min
 '''+fn+'''
 return '''+label+''',p end'''
lp=runtime();pool_stats=[]
for label,name in [('helper_16216','rounded_rect_pool'),('helper_16278','shadow_rect_pool')]:
 x=lp.execute(pool_factory(old,label,name));y=lp.execute(pool_factory(new,label,name))
 t=lp.eval('''function(f0,f1)
 local a,pa=f0();local b,pb=f1()
 for i=1,100 do a();b()end
 assert(pa.hides==400 and pb.hides==4)
 for i=1,3 do pa.rects[i]={};pb.rects[i]={}end;pa.count=3;pb.count=3;a();b()
 for i=1,4 do assert(pa.pool[i].visible==pb.pool[i].visible)end
 a();b();for i=1,4 do assert(not pa.pool[i].visible and not pb.pool[i].visible)end
 local old_h,new_h=pa.hides,pb.hides
 for i=1,100 do a();b()end
 assert(pb.hides==new_h and pa.hides>old_h)
 return pa.hides,pb.hides
 end''')
 pool_stats.append(t(x,y))
check(len(pool_stats)==2,'both idle pool handlers hide once and stop idle traversal')

report={'checks':checks,'animation_output_comparisons':comparisons,'custom_easing_calls_preserved':custom_calls,'drag_state_comparisons':drag_cases,
 'drag_host_reads':{'baseline':old_input,'optimized':new_input},'same_frame_text_measurements':{'requested':repeat_calls,'native':native_calls},
 'text_cache_limit':512,'text_cache_observed_entries_after_churn':entries,'lightweight_initial_effect_factories':no_factories,'lightweight_effect_draw_calls':no_draws,
 'full_quality_effect_geometry_preserved':True,'idle_pool_hide_dispatches':pool_stats,
 'native_gameplay_source_unchanged':True,'native_gameplay_source_sha256':core_hash,
 'animation_module_unchanged':True,
 'baseline_sha256':hashlib.sha256(old.encode()).hexdigest(),'optimized_sha256':hashlib.sha256(new.encode()).hexdigest(),
 'baseline_functions':len(F[id(old)]),'optimized_functions':len(F[id(new)]),'isolated_components_executed':True,'full_game_runtime_executed':False,'fps_gain_measured':False}
(ROOT/'optimization_validation.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
