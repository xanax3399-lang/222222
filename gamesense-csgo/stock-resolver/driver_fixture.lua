-- Strict offline GameSense boundary; native scoring is NOT mocked.
controls, callbacks, logs, files, player_list = {}, {}, {}, {}, {}
writes, now, simulation, enemy_yaw, enemy_alive, enemy_dormant = 0, 10.1, 10, 60, true, false
steam_id, local_alive, fail_enable_once = '76561198000000002', true, false
local function control(kind, _, _, name, ...)
    local args={...}
    local c={kind=kind, value=kind=='slider' and args[3] or false, callback=kind=='button' and args[1] or nil}
    controls[name]=c
    return c
end
ui={}
for _,kind in ipairs({'checkbox','slider','button'}) do ui['new_'..kind]=function(...) return control(kind,...) end end
ui.get=function(c) return c.value end
ui.set=function(c,v)
    assert((c.kind=='checkbox' and type(v)=='boolean') or (c.kind=='slider' and type(v)=='number'))
    local changed=c.value~=v;c.value=v
    if changed and c.callback then c.callback() end
end
ui.set_callback=function(c,f) c.callback=f end
client={
    set_event_callback=function(name,f) callbacks[name]=callbacks[name] or {};table.insert(callbacks[name],f) end,
    latency=function() return .1 end,
    log=function(s) table.insert(logs,s) end,
    userid_to_entindex=function(id) return id end
}
function emit(event,data) for _,f in ipairs(callbacks[event] or {}) do f(data or {}) end end
entity={
    get_local_player=function() return 1 end,
    is_alive=function(p) return p==1 and local_alive or p==2 and enemy_alive end,
    is_dormant=function() return enemy_dormant end,
    get_players=function() return {2} end,
    get_steam64=function() return steam_id end,
    get_player_name=function() return 'offline fixture' end,
    get_prop=function(_,name,index)
        if name=='m_flSimulationTime' then return simulation end
        if name=='m_angEyeAngles[1]' then return enemy_yaw end
        if name=='m_flLowerBodyYawTarget' then return 0 end
        if name=='m_flPoseParameter' then assert(index==11);return 0 end
        if name=='m_vecVelocity' then return 100,0,0 end
        if name=='m_vecOrigin' then return simulation*100,0,0 end
        if name=='m_flDuckAmount' then return 0 end
        if name=='m_fFlags' then return 1 end
        error('Unexpected netprop '..name)
    end
}
globals={curtime=function() return now end,realtime=function() return now end,
    tickinterval=function() return 1/64 end,absoluteframetime=function() return 1/120 end}
renderer={text=function(_,_,_,_,_,_,_,_,s) assert(type(s)=='string') end}
plist={}
local function player(p)
    assert(p>=1 and p<=64)
    if not player_list[p] then player_list[p]={['Force body yaw']=false,['Force body yaw value']=17} end
    return player_list[p]
end
plist.get=function(p,name) assert(name=='Force body yaw' or name=='Force body yaw value');return player(p)[name] end
plist.set=function(p,name,v)
    if name=='Force body yaw' then
        assert(type(v)=='boolean','boolean expected')
        if v and fail_enable_once then fail_enable_once=false;error('Injected enable failure') end
    elseif name=='Force body yaw value' then assert(type(v)=='number' and v>=-60 and v<=60,'yaw range')
    else error('Unknown player control') end
    writes=writes+1;player(p)[name]=v
end
cvar={}
for name,value in pairs({cl_updaterate=64,cl_interp_ratio=2,cl_interp=0,sv_maxunlag=.2,
    sv_client_min_interp_ratio=-1,sv_client_max_interp_ratio=-1,fps_max=300}) do
    local var={value=value}
    var.get_float=function(self) return self.value end
    var.set_int=function(self,v) assert(type(v)=='number');self.value=v end
    cvar[name]=var
end
writefile=function(name,data) assert(type(data)=='string');files[name]=data end
function tick(count)
    for _=1,count do simulation=simulation+1/64;now=simulation+.1;emit('net_update_end') end
end
