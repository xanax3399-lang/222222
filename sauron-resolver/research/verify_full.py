"""Compare the readable rewrite with the original PSU VM and lexical recovery."""
from pathlib import Path
import json
R=Path(__file__).resolve().parent
script=(R/'verify.py').read_text()
final=(R/'sauron_resolver_full_source.lua').read_text()
names={int(k):v for k,v in json.loads((R/'names.json').read_text()).items()}
export='return {'+','.join('['+repr(v)+']='+v for k,v in names.items()if k>=46)+'}\n'
assert final.endswith('end\nreturn main(...)\n')
exposed=final[:-len('end\nreturn main(...)\n')]+export+'end\nreturn main(...)\n'
script=script.replace("helpers=source.execute((R/'source.test.optimized.lua').read_bytes())",'helpers=source.execute('+repr(exposed.encode())+')')
script=script.replace("same('startup controls/options/events'",'literal_final=runtime();literal_final.execute('+repr(final.encode())+")\nsame('startup controls/options/events'")
script=script.replace('for l in (orig,source,lex)','for l in (orig,source,lex,literal_final)')
script=script.replace('assert n[0]==n[1]==n[2]','assert all(x==n[0]for x in n[1:])')
script=script.replace("text=(R/'sauron_resolver_source.lua').read_bytes()", "text=(R/'sauron_resolver_full_source.lua').read_bytes()")
script=script.replace("R/'validation.json'","R/'full_validation.json'")
# Expose ordinary fixture inputs without replacing cached APIs after startup.
script=script.replace("print=function(...)end", "print=function(...)trace[#trace+1]={'print',{...}}end")
script=script.replace("{idx=40,type='sniperrifle'}", "{idx=fixture_weapon_idx or 40,type=fixture_weapon_type or 'sniperrifle'}")
script=script.replace("entity.get_player_weapon=function()return 101 end", "entity.get_player_weapon=function()if fixture_no_weapon then return nil end return 101 end")
script=script.replace("entity.get_players=function()return {2,3}end", "entity.get_players=function()if fixture_no_enemies then return {}end return {2,3}end")
script=script.replace("return fixture_speed or 0,0,0", "return fixture_speed or 0,fixture_speed_y or 0,0")
script=script.replace("return 0.65", "return fixture_pose or 0.65")
script=script.replace("if name=='m_flPoseParameter'", "if name=='m_flDuckAmount'then return fixture_duck or 0 end\n if name=='m_flPoseParameter'")
script=script.replace("client.update_player_list=function()end", "globals.frametime=function()return fixture_frame_dt or 1/120 end;globals.tickcount=function()return fixture_tick or 0 end;client.update_player_list=function()end")
scope={'__file__':str(R/'verify.py')}
exec(compile(script,str(R/'verify.py'),'exec'),scope)
orig,source,lex,literal_final=[scope[n]for n in ('orig','source','lex','literal_final')]
helpers,lexhelpers=scope['helpers'],scope['lexhelpers']
same=scope['same'];checks=scope['checks']
# Additional tests compare against original VM, with unmodified distributed Lua
# participating in all public callback/ESP traces.
runtimes=(orig,source,literal_final)
def scenario(label,code):
 for lua in runtimes:lua.execute(b'trace={};'+code.encode())
 same(label,[lua.globals().trace for lua in runtimes])
 same(label+' state',[orig.globals().captured[51],helpers[b'player_state']])
 same(label+' history',[orig.globals().captured[52],helpers[b'player_history']])
for speed in (0,3,4,5,20,40,84,85,86,250):
 scenario('movement speed '+str(speed),"fixture_speed="+str(speed)+";fire_event('setup_command')")
for duck,flags in ((0,0),(0,1),(0.7,1),(1,1)):
 scenario('duck/ground '+str((duck,flags)),"fixture_speed=40;fixture_duck="+str(duck)+";fixture_flags="+str(flags)+";fire_event('setup_command')")
for pose in (0,0.1,0.5,0.625,0.75,1):
 scenario('pose '+str(pose),"fixture_pose="+str(pose)+";fire_event('setup_command')")
for tick in (1,15,16,17,32,64):
 scenario('tick '+str(tick),"fixture_tick="+str(tick)+";fixture_duck=0;fixture_flags=1;fixture_speed=40;fire_event('setup_command')")
scenario('no visible targets',"fixture_no_enemies=true;fire_event('setup_command');fixture_no_enemies=false")
scenario('no active weapon',"fixture_no_weapon=true;fire_event('setup_command');fixture_no_weapon=false")
scenario('no damage',"fixture_damage=0;fire_event('round_start');fire_event('setup_command')")
scenario('inactive unknown',"fire_event('aim_miss',{target=2,reason='?'})")
scenario('inactive hit',"fire_event('aim_hit',{target=2,hitgroup=1})")
for idx,kind,selected in ((38,'sniperrifle','Auto'),(1,'pistol','Deagle'),(64,'pistol','Revolver'),(7,'rifle','Rifles'),(4,'pistol','Pistols'),(17,'smg','SMG'),(40,'sniperrifle','Auto')):
 scenario('weapon filter '+str(idx),"fixture_damage=50;fixture_weapon_idx="+str(idx)+";fixture_weapon_type='"+kind+"';ui.set(3,{'"+selected+"'});fire_event('setup_command')")
for duration in (0.1,0.3,0.7,1,5,7):
 scenario('notification fade '+str(duration),"fixture_frame_dt="+str(duration)+";fire_event('paint_ui')")
# Compare ESP while players have populated histories, not only after reset.
for flag in (b'RESOLVING',b'RESOLVED',b'SLOW',b'0'):
 same('active ESP '+flag.decode(),[lua.globals().esp[flag](2)for lua in runtimes])
from lupa.lua51 import LuaRuntime as Lua51
Lua51(encoding=None,register_eval=False,register_builtins=False).compile(final.encode())
import re,hashlib
assert not re.search(r'\b(?:L\d+_\d+|A\d+_\d+|returned_\d+_\d+|pack_results)\b',final)
report={'passed':len(checks),'checks':checks,'vm_removed':True,'temporary_register_names_removed':True,'hand_structured_source':True,'lua51_syntax':True,'sha256':hashlib.sha256(final.encode()).hexdigest(),'gameplay_tested':False}
(R/'full_validation.json').write_text(json.dumps(report,indent=2)+'\n')
print('Full source PASS',len(checks),'checks')
