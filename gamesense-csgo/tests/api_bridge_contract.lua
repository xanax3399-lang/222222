-- Host contracts only: this fixture does not emulate a live CS:GO scene.
local ffi=require('ffi')
local rawload=ffi.load
ffi.cdef'void gsnl_fixture_failure(int);'
local host=rawload(HOST_LIBRARY)
ffi.load=function(name,...)if name=='kernel32.dll'then return host end;return rawload(name,...)end
local checks=0
local function check(v,message)assert(v,message);checks=checks+1 end
local function near(a,b)check(math.abs(a-b)<1e-8,tostring(a)..' != '..tostring(b))end
local function throws(fn,fragment)
    local ok,err=pcall(fn);check(not ok and tostring(err):find(fragment,1,true),tostring(err))
end
local callbacks,controls,props,db={},{},{},{}
local renders,lastangles={},{10,20}
client={}
function client.set_event_callback(name,fn)callbacks[name]=callbacks[name]or {};callbacks[name][fn]=true end
function client.unset_event_callback(name,fn)if callbacks[name]then callbacks[name][fn]=nil end end
local function fire(name,arg)
    local list={};for fn in pairs(callbacks[name]or {})do list[#list+1]=fn end
    for _,fn in ipairs(list)do fn(arg)end
end
client.log=function()end
client.screen_size=function()return 1920,1080 end
client.camera_position=function()return 1,2,3 end
client.camera_angles=function(p,y)if p then lastangles={p,y}else return unpack(lastangles)end end
client.eye_position=function()return 10,20,64 end
client.userid_to_entindex=function(id)return id==77 and 2 or nil end
client.exec=function(...)return ... end
client.delay_call=function(_,fn,...)return fn(...)end
client.random_int=function(a)return a end
client.random_float=function(a)return a end
client.create_interface=function()return nil end
client.timestamp=function()return 1234 end
client.key_state=function(k)return k==1 end
client.set_clan_tag=function(s)return s end
globals={};for _,key in ipairs({'curtime','realtime','frametime','framecount','absoluteframetime','tickcount','maxplayers','chokedcommands','lastoutgoingcommand','oldcommandack','commandack'})do globals[key]=function()return 42 end end
globals.tickinterval=function()return 1/64 end
entity={}
entity.get_classname=function(idx)if idx==1 or idx==2 then return 'CCSPlayer'elseif idx==3 then return 'CWeaponSSG08'end end
entity.get_local_player=function()return 1 end
entity.get_all=function(class)if not class or class=='CCSPlayer'then return {1,2}else return {3}end end
entity.is_enemy=function(idx)return idx==2 end
entity.is_alive=function()return true end
entity.is_dormant=function(idx)return idx==2 end
entity.get_player_name=function(idx)return 'Player '..idx end
entity.get_origin=function(idx)return idx,idx*2,idx*3 end
entity.get_prop=function(idx,name)
    if name=='m_angEyeAngles'then return 10,20,0 end
    if name=='m_hOwnerEntity'then return 1 end
    return (props[idx]or {})[name]
end
entity.hitbox_position=function(_,h)return 10,20,h end
entity.get_player_weapon=function()return 3 end
entity.get_steam64=function()return '76561198000000001'end
entity.get_game_rules=function()return nil end
entity.get_player_resource=function()return nil end
props[1]={m_iHealth=100,m_flSimulationTime=5};props[3]={m_iItemDefinitionIndex=40}
renderer={}
for _,name in ipairs({'line','rectangle','circle','circle_outline','text'})do renderer[name]=function(...)renders[name]={...}end end
renderer.world_to_screen=function(x,y,z)if z<0 then return nil end;return x*2,y*2 end
renderer.measure_text=function(_,s)return #s*8,14 end
ui={}
local function control(...)
    local args={...};local ref=#controls+1;controls[ref]={args=args,value=false};return ref
end
for _,name in ipairs({'checkbox','slider','combobox','multiselect','color_picker','button','textbox','label'})do ui['new_'..name]=control end
ui.get=function(ref)local v=controls[ref].value;if type(v)=='table'then return unpack(v)end;return v end
ui.set=function(ref,...)
    local c=controls[ref];if select('#',...)>1 then c.value={...}else c.value=(...)end
    if c.callback then c.callback()end
end
ui.set_callback=function(ref,fn)controls[ref].callback=fn end
ui.set_visible=function(ref,v)controls[ref].visible=v end
ui.menu_size=function()return 600,500 end
ui.menu_position=function()return 20,30 end
ui.mouse_position=function()return 40,50 end
database={read=function(k)return db[k]end,write=function(k,v)db[k]=v end}
json={parse=function(s)return {raw=s}end,stringify=function()return '{}'end}
bit=require('bit')
local oldui,oldentity,oldglobals=ui,entity,globals
local loader=assert(loadfile(BOOTSTRAP))
host.gsnl_fixture_failure(1);throws(loader,'must already be loaded')
host.gsnl_fixture_failure(2);throws(loader,'missing gsnl_')
host.gsnl_fixture_failure(0)
local api=loader()
check(ui==oldui and entity==oldentity and globals==oldglobals,'host globals replaced')
check(api.gs.ui==ui and api.gs.environment==_G)
check(api.native.snapshot().points_added==456)
check(api.native.snapshot().recharge_enabled==0)
check(api.supports('vector:length') and not api.supports('rage_exploit:force_charge'))
check(api.capability('render.text').status=='partial')
local inventory=api.capabilities();inventory['vector:length'].status='corrupted'
check(api.supports('vector:length'),'capabilities leaked mutable registry')
local v=api.vector(3,4,12);near(v:length(),13);near(v:length2d(),5)
near(v:dot(api.vector(2,3,4)),66)
near(v:dist(api.vector(3,4,0)),12)
check((v+2)==api.vector(5,6,14));check((2-v)==api.vector(-1,-2,-10))
near(v:normalized():length(),1);check(v==api.vector(3,4,12),'normalized mutated source')
local zero=api.vector();near(zero:normalize(),0);check(zero==api.vector())
check(api.vector(1,0,0):cross(api.vector(0,1,0))==api.vector(0,0,1))
check(api.vector(2,3,0):closest_ray_point(api.vector(),api.vector(1,0,0))==api.vector(1,0,0))
near(api.vector(2,3,0):dist_to_ray(api.vector(),api.vector(1,0,0)),3)
local right,up=api.vector(1,0,0):vectors();check(right==api.vector(0,-1,0));check(up==api.vector(0,0,1))
near(api.vector(0,90):angles().y,1)
throws(function()api.vector(0/0)end,'finite number')
local c=api.color(100,50);check(c.r==100 and c.g==100 and c.b==100 and c.a==50)
check(api.color('FFA0').a==160);check(api.color('#01020304'):to_hex()=='01020304')
check(api.color():to_hex()=='FFFFFFFF')
check(api.color():as_int32(api.color(1,2,3,4):to_int32()):to_hex()=='01020304')
near(api.color(255,0,0):to_fraction(),1)
check(api.color(1,2,3,4):alpha_modulate(25).a==25)
throws(function()api.color('oops')end,'invalid color hex')
near(api.math.normalize_yaw(540),-180);near(api.math.normalize_yaw(-181),179)
near(api.math.difference(179,-179),358);near(api.math.difference(3,5),2)
near(api.math.map(2,0,1,0,10,true),10)
throws(function()api.math.clamp(2)end,'explicit min and max')
throws(function()api.math.map(2,1,1,0,10)end,'zero input range')
check(api.to_ticks(.5)==32);near(api.to_time(32),.5)
check(api.globals.max_players==42);check(api.globals.tickinterval==1/64)
throws(function()return api.globals.server_tick end,'no verified host getter')
throws(function()api.globals.curtime=0 end,'read-only')
local player=api.entity.get_local_player();check(player:get_index()==1 and player.m_iHealth==100)
check(player:get_name()=='Player 1');check(player:get_origin()==api.vector(1,2,3))
check(player.m_angEyeAngles==api.vector(10,20,0))
check(player:get_eye_position()==api.vector(10,20,64));check(player:get_player_weapon():get_weapon_index()==40)
check(api.entity.get(77,true):get_index()==2);check(api.entity.get(999)==nil)
check(#api.entity.get_players(true,false)==0);check(#api.entity.get_players(true,true)==1)
local enumerated=0
check(api.entity.get_players(false,true,function()enumerated=enumerated+1 end)==nil and enumerated==2)
throws(function()api.entity.get_entities(40)end,'numeric class IDs')
throws(function()api.entity.get(2):get_eye_position()end,'only local eye getter')
throws(function()player.m_iHealth=1 end,'netprop writes')
throws(function()player:get_player_weapon(true)end,'all_weapons')
throws(function()player:get_anim_state()end,'unavailable')
local calls=0;local onhurt=function(e)calls=calls+e.damage end
api.events.player_hurt:set(onhurt);api.events.player_hurt:set(onhurt);fire('player_hurt',{damage=2});check(calls==2)
api.events.player_hurt(onhurt,false);fire('player_hurt',{damage=2});check(calls==2)
api.events.player_hurt(onhurt);api.events.player_hurt:call({damage=3});check(calls==5)
local raw={pitch=1,yaw=2,forwardmove=0,sidemove=0,upmove=0,in_attack=0,chokedcommands=2}
api.events.createmove:set(function(cmd)
    check(cmd.in_attack==false and cmd.choked_commands==2)
    cmd.in_attack=true;cmd.forwardmove=100;cmd.view_angles.y=90
    cmd.view_angles=api.vector(10,100)
    throws(function()cmd.force_defensive=true end,'unsupported')
end)
fire('setup_command',raw);check(raw.in_attack==1 and raw.forwardmove==100 and raw.pitch==10 and raw.yaw==100)
local broken=function(cmd)cmd.forwardmove=450;cmd.in_attack=false;cmd.send_packet=false end
api.events.createmove:set(broken)
throws(function()fire('setup_command',raw)end,'unsupported')
check(raw.forwardmove==100 and raw.in_attack==1,'failed callback partially wrote a movement/attack command')
api.events.createmove:unset(broken)
api.events.createmove_run:set(function(cmd)
    check(cmd.command_number==9 and cmd.choked_commands==2)
    throws(function()return cmd.forwardmove end,'does not expose')
end)
fire('run_command',{command_number=9,chokedcommands=2})
throws(function()api.events.aim_ack:set(function()end)end,'no verified mapping')
api.render.line(api.vector(1,2),api.vector(3,4),api.color(10,20,30,40))
check(renders.line[1]==1 and renders.line[8]==40)
api.render.rect(api.vector(1,2),api.vector(5,8),api.color())
check(renders.rectangle[3]==4 and renders.rectangle[4]==6)
check(api.render.world_to_screen(api.vector(3,4,0))==api.vector(6,8))
check(api.render.world_to_screen(api.vector(3,4,-1))==nil)
check(api.render.measure_text(nil,'','test')==api.vector(32,14))
throws(function()api.render.line(api.vector(),api.vector(),api.color(),2)end,'thickness=1')
throws(function()api.render.text(10,api.vector(),api.color(),'','test')end,'custom font')
local group=api.ui.create('test');local sw=group:switch('toggle',true)
check(sw:get()==true);local ui_calls=0;local cb=function(i)ui_calls=ui_calls+1;check(i==sw)end
sw:set_callback(cb,true);sw:set(false);check(ui_calls==2);sw:unset_callback(cb);sw:set(true);check(ui_calls==2)
sw:visibility(false);check(controls[sw:id()].visible==false)
local cp=group:color_picker('color',api.color(1,2,3,4));cp:set(api.color(4,3,2,1));check(cp:get():to_hex()=='04030201');cp:reset();check(cp:get():to_hex()=='01020304')
api.map_menu({'Aimbot','test'},sw:id());check(api.ui.find('Aimbot','test'):get()==true)
throws(function()api.ui.find('unknown')end,'register this path')
throws(function()api.ui.create('tab','group')end,'only group overload')
throws(function()sw:override(true)end,'unavailable')
api.db.test={a=1};check(db['gsnl:test'].a==1 and api.db.test.a==1)
check(api.json.parse('abc').raw=='abc');check(api.utils.console_exec('a')=='a')
local chunk=assert(api.load('return globals.tickinterval, vector(3,4):length(), gamesense.ui == gsnl.gs.ui'))
local interval,length,same=chunk();check(interval==1/64 and length==5 and same)
local cls=api.new_class():struct 'first' {value=10}:struct 'second' {get=function(self)return self.first.value end}
check(cls.second:get()==10,'new_class sibling lookup')
check(ui==oldui and globals==oldglobals,'isolated script changed host')
throws(function()api.rage.exploit:force_charge()end,'unavailable')
throws(function()api.utils.net_channel()end,'unavailable')
local shutdown_calls=0
api.events.shutdown:set(function()sw:set(false);shutdown_calls=shutdown_calls+1 end)
api.dispose();fire('player_hurt',{damage=100});check(calls==5)
check(shutdown_calls==1 and sw:get()==false,'cleanup did not run while UI was usable')
fire('shutdown');check(shutdown_calls==1,'shutdown ran twice')
throws(function()api.events.player_hurt:set(onhurt)end,'disposed')
check(api.native.snapshot().recharge_enabled==0,'bridge changed native recharge')
return checks
