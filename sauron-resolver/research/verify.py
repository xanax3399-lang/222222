from pathlib import Path
import json,math,contextlib,io
from lupa.luajit21 import LuaRuntime,lua_type
R=Path(__file__).resolve().parent
from vm_sandbox import BOOTSTRAP
fixture=(R/'gamesense_fixture.lua').read_bytes()
SETUP=b'''
local raw_pairs=pairs
pairs=function(t)local keys={}for k in raw_pairs(t)do keys[#keys+1]=k end table.sort(keys,function(a,b)return tostring(a)<tostring(b)end);local i=0;return function()i=i+1;local k=keys[i];if k~=nil then return k,t[k]end end end

print=function(...)end
require=function(name) if name=='gamesense/csgo_weapons' then return function(id)return {idx=40,type='sniperrifle'}end elseif name=='vector' then return vector end error(name) end
client.update_player_list=function()end
entity.hitbox_position=function(id,hitbox)return id*20,30,64 end
entity.get_local_player=function()return 1 end
entity.get_player_weapon=function()return 101 end
entity.get_players=function()return {2,3}end
entity.get_prop=function(id,name,index)
 if name=='m_vecVelocity' then return fixture_speed or 0,0,0 end
 if name=='m_fFlags' then return fixture_flags or 1 end
 if name=='m_flPoseParameter' then return 0.65 end
 if name=='m_angEyeAngles' then return 10,30,0 end
 return 0
end
client.userid_to_entindex=function(x)return x end
client.trace_bullet=function(...)return 2,fixture_damage or 50 end
trace={};esp={}
local function val(x)
 if type(x)=='function'then return '<function>'end
 if type(x)=='table'then local out={}for k,v in pairs(x)do out[k]=val(v)end return out end
 return x
end
for _,module in ipairs({'ui','client','renderer','plist'})do
 for name,fn in pairs(_G[module])do
  if type(fn)=='function'then _G[module][name]=function(...)trace[#trace+1]={module,name,val({...})};return fn(...)end end
 end
end
client.register_esp_flag=function(label,r,g,b,fn) esp[label]=fn;trace[#trace+1]={'esp',label,r,g,b} end
client.unset_event_callback=function(event,fn) for i=#events,1,-1 do if events[i][1]==event and events[i][2]==fn then table.remove(events,i)end end end
function enable_all()for id,c in pairs(sigma_controls())do if c.kind=='checkbox'then ui.set(id,true)elseif c.kind=='multiselect'then ui.set(id,{'Scout','Auto','Pistols'})end end end
function fire_event(name,data)for _,ev in ipairs(events)do if ev[1]==name then ev[2](data or {})end end end
'''
def runtime():
 l=LuaRuntime(encoding=None,register_eval=False,register_builtins=False);l.execute(fixture);l.execute(SETUP);return l
orig=runtime();s=(R/'original.lua').read_bytes();s=s.replace(b'local function m(e,d,u,...)',b'local function m(e,d,u,...)local proto=e;');s=s.replace(b'while(true)do local e=h;',b'if __capture_registers then __capture_registers(proto,l)end;while(true)do local e=h;')
orig.execute(b'captured={};__capture_registers=function(p,r)if p.__fid==0 then captured=r end end')
s=s.replace(b'return m(H(),{},F())(...);',b'return {proto=H(),vm=m};')
# BOOTSTRAP would erase fixture; only use its loader for extraction, then recreate fixture.
from vm_sandbox import BOOTSTRAP
orig=LuaRuntime(encoding=None,register_eval=False,register_builtins=False);result=orig.execute(BOOTSTRAP)(s)
orig.execute(fixture);orig.execute(SETUP);orig.execute(b'captured={};__capture_registers=function(p,r)if p.__fid==0 then captured=r end end')
p=result[b'proto'];p[b'__fid']=0
budget=orig.eval(b"function()local d=debug end") if False else None
result[b'vm'](p,orig.table(),orig.globals())()
source=runtime();helpers=source.execute((R/'source.test.optimized.lua').read_bytes())
lex=runtime();lexhelpers=lex.execute((R/'source.test.lua').read_bytes())
names={int(k):v.encode()for k,v in json.loads((R/'names.json').read_text()).items()}
def norm(v,seen=None):
 if lua_type(v)=='function':return '<function>'
 if lua_type(v)=='table':return {str(k):norm(x)for k,x in v.items()}
 if isinstance(v,bytes):return v.decode('utf-8','backslashreplace')
 if isinstance(v,tuple):return [norm(x)for x in v]
 if isinstance(v,float)and not math.isfinite(v):return str(v)
 return v
checks=[]
def same(label,values):
 n=[norm(x)for x in values];assert n[0]==n[1]==n[2],(label,n);checks.append(label)
same('startup controls/options/events',[l.globals().trace for l in (orig,source,lex)])
for id in (60,62,63,64,65,66,67,68,69):
 args={60:[(12.345,2),(-80.55,0),(0,3)],62:[([1,2,3],2),([1,2],4)],63:[(x,2,flag)for x in (-50,-1,0,1,10,15,16,30)for flag in (True,False)],64:[(x,)for x in (-721,-360,-181,-180,0,180,181,360,721)],65:[(1,2,3,4),(0,3,0,7)],66:[(1,2,0,0,64)],67:[(10,20),(-80,180)],68:[(2,)],69:[(2,3,0),(-2,-3,0),(2,-2,0),(0,1,0)]}[id]
 for a in args:
  vals=[]
  for l,h in [(orig,None),(source,helpers),(lex,lexhelpers)]:
   fn=orig.globals().captured[id]if h is None else h[names[id]]
   av=[l.table_from(v)if isinstance(v,list)else v for v in a]
   vals.append(fn(*av))
  same('helper '+str(id)+' '+str(a),vals)
# Main resolver callbacks, settings toggles, hit/miss reasons and render passes.
for l in (orig,source,lex):l.execute(b'enable_all();trace={}');
for label,script in [('enable',b"fire_event('setup_command'); for _,c in pairs(sigma_controls())do if c.callback then c.callback()end end"),('command stationary',b"fire_event('setup_command')"),('moving',b"fixture_speed=110;fire_event('setup_command')"),('slow',b"fixture_speed=40;fire_event('setup_command')"),('body hit',b"fire_event('aim_hit',{target=2,damage=50,hitgroup=3})"),('hit',b"fire_event('aim_hit',{target=2,damage=50,hitgroup=1})"),('spread miss',b"fire_event('aim_miss',{target=2,reason='spread'})"),('unknown miss',b"fire_event('aim_miss',{target=2,reason='?'})"),('repeat unknown',b"for i=1,4 do fire_event('aim_miss',{target=2,reason='?'})end"),('death',b"fire_event('player_death',{userid=1})"),('round',b"fire_event('round_start')"),('connect',b"fire_event('player_connect_full',{userid=1})"),('notifications',b"fire_event('paint_ui')")]:
 for l in (orig,source,lex):l.execute(b'trace={};'+script)
 same(label,[l.globals().trace for l in (orig,source,lex)])
 same(label+' player state',[orig.globals().captured[51],helpers[b'player_state'],lexhelpers[b'player_state']])
 same(label+' player history',[orig.globals().captured[52],helpers[b'player_history'],lexhelpers[b'player_history']])
for flag in (b'RESOLVING',b'RESOLVED',b'SLOW',b'0'):
 same('ESP '+flag.decode(),[l.globals().esp[flag](2)for l in (orig,source,lex)])
text=(R/'sauron_resolver_source.lua').read_bytes();source.compile(text)
assert b'PSU|' not in text and b'goto 'not in text and b'loadstring'not in text
(R/'validation.json').write_text(json.dumps({'passed':len(checks),'checks':checks,'vm_removed':True,'prototypes':31,'gameplay_tested':False},indent=2))
print('PASS',len(checks),'checks')
