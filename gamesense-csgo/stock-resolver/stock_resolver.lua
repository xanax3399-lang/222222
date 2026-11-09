-- Stock GS resolver: native bounded history/scoring; supported GameSense overrides.
local ffi = require('ffi')
if not pcall(ffi.typeof, 'sr_snapshot_v1') then
    ffi.cdef[[
    typedef struct { uint32_t player,identity,flags,reserved; float simulation_time,now,interval,latency,lerp,max_unlag,eye_yaw,lower_body_yaw,pose_yaw,velocity_x,velocity_y,duck,origin_x,origin_y,origin_z; } sr_snapshot_v1;
    typedef struct { uint32_t player,identity,generation,apply,records,state,reason,reserved; float offset,confidence,simulation_time; } sr_decision_v1;
    typedef struct { uint32_t feeds,records,duplicates,rejected,resets,selected,fallback,head_feedback,feedback_rejected,slots,memory_bytes; } sr_stats_v1;
    typedef struct { uint32_t count,spikes; float mean_ms,p50_ms,p95_ms,p99_ms,max_ms; } sr_frames_v1;
    unsigned sr_abi_version(void); unsigned sr_snapshot_bytes(void); unsigned sr_decision_bytes(void);
    unsigned sr_mode_enabled(void);
    void sr_reset(void); void sr_forget(unsigned);
    unsigned sr_feed(const sr_snapshot_v1*,float,sr_decision_v1*);
    unsigned sr_head_hit(unsigned,unsigned,unsigned);
    void sr_stats(sr_stats_v1*); unsigned sr_history(unsigned,sr_snapshot_v1*,unsigned);
    void sr_frame(float); void sr_frame_stats(sr_frames_v1*);
    unsigned long __stdcall GetModuleFileNameA(void*, char*, unsigned long);
    void* __stdcall GetModuleHandleA(const char*);
    ]]
end
local function load_native()
    local handle = ffi.C.GetModuleHandleA('skeet.dll')
    if handle == nil then error('[stock resolver] Inject the matching skeet.dll first') end
    local buffer = ffi.new('char[32768]')
    local size = tonumber(ffi.C.GetModuleFileNameA(handle, buffer, 32768))
    if size == 0 or size >= 32768 then error('[stock resolver] Cannot locate injected skeet.dll') end
    local ok, module = pcall(ffi.load, ffi.string(buffer, size))
    if not ok then error('[stock resolver] Cannot bind injected resolver DLL: ' .. tostring(module)) end
    return module
end
local native = load_native()
assert(native.sr_abi_version() == 0x00010001 and native.sr_snapshot_bytes() == ffi.sizeof('sr_snapshot_v1') and native.sr_decision_bytes() == ffi.sizeof('sr_decision_v1'), '[stock resolver] DLL/Lua versions differ')
assert(native.sr_mode_enabled() == 1, '[stock resolver] Select loader option 2 and restart CS:GO to enable this module')
assert(type(plist) == 'table' and type(plist.get) == 'function' and type(plist.set) == 'function', '[stock resolver] Player-list API is unavailable')

local enabled = ui.new_checkbox('LUA', 'B', 'Stock resolver: enabled')
local confidence = ui.new_slider('LUA', 'B', 'Resolver evidence threshold', 50, 95, 65, true, '%')
local show_metrics = ui.new_checkbox('LUA', 'B', 'Resolver: show frame-time metrics')
local framecap = ui.new_checkbox('LUA', 'B', 'Resolver: stable FPS limit')
local frame_limit = ui.new_slider('LUA', 'B', 'Resolver FPS limit', 30, 500, 120, true)
local save_report
ui.new_button('LUA', 'B', 'Save resolver report and history', function() if save_report then save_report() end end)

local sample = ffi.new('sr_snapshot_v1[1]')
local decision = ffi.new('sr_decision_v1[1]')
local stats = ffi.new('sr_stats_v1[1]')
local frames = ffi.new('sr_frames_v1[1]')
local history = ffi.new('sr_snapshot_v1[16]')
local states, shots = {}, {}
for i = 1, 64 do states[i] = {owned=false, blocked=false, identity=0, seen=0, value=0, original_value=0, original_enabled=false, generation=0, applied=false, confidence=0, reason=0, records=0} end
for i = 1, 128 do shots[i] = {id=-1, target=0, identity=0, generation=0} end
local epoch, next_cvars, lerp, max_unlag = 0, 0, 0.03125, 0.2
local latency, last_update_ms, worst_update_ms = 0, 0, 0
local next_metrics, metric_line = 0, ''
local fps_owned, fps_original, fps_value = false, nil, nil
local failures = 0

local function finite(value) return type(value) == 'number' and value == value and value > -math.huge and value < math.huge end
local function close(a, b) return finite(a) and finite(b) and math.abs(a-b) < 0.01 end
local function cvar_number(name, fallback)
    local variable = cvar[name]
    if variable == nil then return fallback end
    local ok, value = pcall(function() return variable:get_float() end)
    return ok and finite(value) and value or fallback
end
local function identity(player)
    local text = entity.get_steam64(player)
    if text == nil or text == '0' or text == 0 then text = 'bot:' .. player .. ':' .. (entity.get_player_name(player) or '') end
    text = tostring(text)
    local hash = 5381
    for i=1,#text do hash = (hash*33+text:byte(i))%4294967296 end
    return hash == 0 and 1 or hash
end
local function release(player)
    local state = states[player]
    if state.owned then
        -- Restore only our own current override, preserving later manual edits.
        if plist.get(player, 'Force body yaw') == true and close(plist.get(player, 'Force body yaw value'), state.value) then
            plist.set(player, 'Force body yaw', state.original_enabled)
            plist.set(player, 'Force body yaw value', state.original_value)
        end
        state.owned = false
    end
    state.applied = false
end
local function forget(player)
    release(player)
    native.sr_forget(player)
    local state = states[player]
    state.identity, state.blocked, state.generation, state.records = 0, false, 0, 0
end
local function reset_all()
    for player=1,64 do pcall(forget,player) end
    for i=1,128 do shots[i].id=-1 end
    native.sr_reset()
end
local function apply(player, d)
    local state = states[player]
    state.confidence, state.reason, state.records = tonumber(d.confidence), tonumber(d.reason), tonumber(d.records)
    state.generation, state.applied = tonumber(d.generation), false
    if d.apply == 0 or state.blocked then release(player); return end
    local current_enabled = plist.get(player, 'Force body yaw')
    local current_value = plist.get(player, 'Force body yaw value')
    if type(current_enabled) ~= 'boolean' or not finite(current_value) then error('Unsupported Force body yaw player-list controls') end
    if state.owned then
        if not current_enabled or not close(current_value, state.value) then
            state.owned, state.blocked = false, true
            return
        end
    else
        -- Existing manual/other-script overrides keep priority.
        if current_enabled then state.blocked=true; return end
        state.original_enabled, state.original_value = current_enabled, current_value
    end
    local value = tonumber(d.offset)
    if not state.owned or not close(state.value, value) then
        local ok,why=pcall(function()
            plist.set(player, 'Force body yaw value', value)
            plist.set(player, 'Force body yaw', true)
        end)
        if not ok then
            -- Undo a partial write before the outer handler disables the driver.
            local got,actual=pcall(plist.get,player,'Force body yaw value')
            if got and close(actual,value) then
                pcall(plist.set,player,'Force body yaw',current_enabled)
                pcall(plist.set,player,'Force body yaw value',current_value)
            end
            error(why)
        end
    end
    state.value, state.owned, state.applied = value, true, true
end
local function update_cvars(now, interval)
    if now < next_cvars then return end
    next_cvars = now+1
    local rate = math.max(1, cvar_number('cl_updaterate', 1/interval))
    local low_rate, high_rate = cvar_number('sv_minupdaterate', 0), cvar_number('sv_maxupdaterate', 0)
    if low_rate>0 and high_rate>=low_rate then rate=math.max(low_rate, math.min(rate, high_rate)) end
    local ratio = cvar_number('cl_interp_ratio', 2)
    local minimum, maximum = cvar_number('sv_client_min_interp_ratio', -1), cvar_number('sv_client_max_interp_ratio', -1)
    if minimum>=0 and maximum>=minimum then ratio=math.max(minimum, math.min(ratio, maximum)) end
    lerp = math.max(0, math.min(0.5, math.max(cvar_number('cl_interp', 0), math.max(0,ratio)/rate)))
    max_unlag = math.max(0.01, math.min(1, cvar_number('sv_maxunlag', 0.2)))
    latency = math.max(0, math.min(2, client.latency()))
end
local function update()
    if not ui.get(enabled) then return end
    local local_player = entity.get_local_player()
    if not local_player or not entity.is_alive(local_player) then
        for player=1,64 do if states[player].owned then release(player) end end
        return
    end
    local started = globals.realtime()
    local now, interval = globals.curtime(), globals.tickinterval()
    if not finite(now) or not finite(interval) or interval<0.001 then return end
    update_cvars(now, interval)
    epoch = epoch+1
    local enemies = entity.get_players(true)
    local threshold = ui.get(confidence)*0.01
    for i=1,#enemies do
        local player=enemies[i]
        if player>=1 and player<=64 and entity.is_alive(player) and not entity.is_dormant(player) then
            local state=states[player]
            state.seen=epoch
            local id=identity(player)
            if state.identity~=id then forget(player);state.identity=id;state.seen=epoch end
            local sim=entity.get_prop(player,'m_flSimulationTime')
            local yaw=entity.get_prop(player,'m_angEyeAngles[1]')
            if yaw==nil then local _, y=entity.get_prop(player,'m_angEyeAngles');yaw=y end
            local lby=entity.get_prop(player,'m_flLowerBodyYawTarget')
            local pose=entity.get_prop(player,'m_flPoseParameter',11)
            local vx,vy=entity.get_prop(player,'m_vecVelocity')
            local x,y,z=entity.get_prop(player,'m_vecOrigin')
            local duck=entity.get_prop(player,'m_flDuckAmount')
            local flags=entity.get_prop(player,'m_fFlags')
            if finite(sim) and finite(yaw) and finite(vx) and finite(vy) and finite(x) and finite(y) and finite(z) and finite(duck) and finite(flags) then
                local value=sample[0]
                value.player,value.identity,value.flags,value.reserved=player,id,flags%2==1 and 1 or 0,0
                if finite(lby) then value.flags=value.flags+4 end
                if finite(pose) and pose>=0 and pose<=1 then value.flags=value.flags+2 end
                value.simulation_time,value.now,value.interval=sim,now,interval
                value.latency,value.lerp,value.max_unlag=latency,lerp,max_unlag
                value.eye_yaw,value.lower_body_yaw,value.pose_yaw=yaw,finite(lby) and lby or 0,finite(pose) and pose>=0 and pose<=1 and (pose*120-60) or 0
                value.velocity_x,value.velocity_y,value.duck=vx,vy,duck
                value.origin_x,value.origin_y,value.origin_z=x,y,z
                if native.sr_feed(sample,threshold,decision)~=0 then apply(player,decision[0]) else release(player) end
            else release(player) end
        end
    end
    for player=1,64 do if states[player].identity~=0 and states[player].seen~=epoch then forget(player) end end
    last_update_ms=math.max(0, (globals.realtime()-started)*1000)
    worst_update_ms=math.max(worst_update_ms,last_update_ms)
end
local function safe_update()
    local ok,why=pcall(update)
    if not ok then
        failures=failures+1
        for player=1,64 do pcall(release,player) end
        ui.set(enabled,false)
        client.log('[stock resolver] Disabled after API error: '..tostring(why))
    end
end
local function update_framecap()
    local variable=cvar.fps_max
    if variable==nil then return end
    local current=cvar_number('fps_max',0)
    if ui.get(framecap) then
        if fps_owned and not close(current,fps_value) then
            fps_owned=false
            ui.set(framecap,false)
            return
        end
        if not fps_owned then fps_original=current end
        fps_value=ui.get(frame_limit)
        variable:set_int(fps_value)
        fps_owned=true
    elseif fps_owned then
        if close(current,fps_value) then variable:set_int(fps_original) end
        fps_owned=false
    end
end
local function paint()
    native.sr_frame(globals.absoluteframetime())
    if not ui.get(show_metrics) then return end
    local now=globals.realtime()
    if now>=next_metrics then
        next_metrics=now+0.25
        native.sr_frame_stats(frames);native.sr_stats(stats)
        local applied,tracked=0,0
        for player=1,64 do
            if states[player].identity~=0 then tracked=tracked+1 end
            if states[player].applied then applied=applied+1 end
        end
        metric_line=string.format('Resolver %d/%d players | p95 %.1f ms | update %.3f ms',applied,tracked,tonumber(frames[0].p95_ms),last_update_ms)
    end
    renderer.text(12,40,210,225,245,230,'',0,metric_line)
end
save_report=function()
    native.sr_stats(stats);native.sr_frame_stats(frames)
    local a,b=stats[0],frames[0]
    local rows={'player,identity,simtime,eye_yaw,lby,pose_yaw,vx,vy,duck,x,y,z,flags'}
    for player=1,64 do
        local count=tonumber(native.sr_history(player,history,16))
        for i=0,count-1 do
            local s=history[i]
            rows[#rows+1]=string.format('%d,%u,%.6f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%u',player,tonumber(s.identity),tonumber(s.simulation_time),tonumber(s.eye_yaw),tonumber(s.lower_body_yaw),tonumber(s.pose_yaw),tonumber(s.velocity_x),tonumber(s.velocity_y),tonumber(s.duck),tonumber(s.origin_x),tonumber(s.origin_y),tonumber(s.origin_z),tonumber(s.flags))
        end
    end
    writefile('stock_resolver_history.csv',table.concat(rows,'\n'))
    local report=string.format('Stock resolver v1\nRecords: %d; duplicate updates: %d; rejected: %d\nCustom decisions: %d; GS fallbacks: %d; head feedback: %d\nSlots: %d; native memory: %d bytes\nFrames: %d; mean/p50/p95/p99/max: %.3f/%.3f/%.3f/%.3f/%.3f ms\nLast/worst update: %.3f/%.3f ms; API failures: %d\n',tonumber(a.records),tonumber(a.duplicates),tonumber(a.rejected),tonumber(a.selected),tonumber(a.fallback),tonumber(a.head_feedback),tonumber(a.slots),tonumber(a.memory_bytes),tonumber(b.count),tonumber(b.mean_ms),tonumber(b.p50_ms),tonumber(b.p95_ms),tonumber(b.p99_ms),tonumber(b.max_ms),last_update_ms,worst_update_ms,failures)
    writefile('stock_resolver_report.txt',report)
    client.log('[stock resolver] Saved stock_resolver_report.txt and stock_resolver_history.csv')
end
client.set_event_callback('net_update_end',safe_update)
client.set_event_callback('paint',paint)
client.set_event_callback('aim_fire',function(e)
    if not e.id or not e.target or e.target<1 or e.target>64 then return end
    local state=states[e.target];local shot=shots[e.id%128+1]
    shot.id,shot.target,shot.identity,shot.generation=e.id,e.target,state.identity,state.applied and state.generation or 0
end)
client.set_event_callback('aim_hit',function(e)
    if not e.id then return end
    local shot=shots[e.id%128+1]
    if shot.id~=e.id or (e.target and e.target~=shot.target) then return end
    if shot.generation~=0 and (e.hitgroup=='head' or e.hitgroup==1) then native.sr_head_hit(shot.target,shot.identity,shot.generation) end
    shot.id=-1
end)
client.set_event_callback('aim_miss',function(e) if e.id then local shot=shots[e.id%128+1];if shot.id==e.id then shot.id=-1 end end end)
for _,event in ipairs({'player_spawn','player_death','player_disconnect'}) do
    client.set_event_callback(event,function(e) local player=client.userid_to_entindex(e.userid);if player and player>=1 and player<=64 then forget(player) end end)
end
for _,event in ipairs({'round_start','game_newmap','cs_game_disconnected'}) do client.set_event_callback(event,reset_all) end
client.set_event_callback('shutdown',function()
    pcall(save_report)
    for player=1,64 do pcall(release,player) end
    if fps_owned and close(cvar_number('fps_max',0),fps_value) then cvar.fps_max:set_int(fps_original) end
    native.sr_reset()
end)
ui.set_callback(enabled,function() if not ui.get(enabled) then reset_all() end end)
ui.set_callback(framecap,update_framecap)
ui.set_callback(frame_limit,update_framecap)
native.sr_reset()
ui.set(enabled,true)
client.log('[stock resolver] Loaded. Settings: LUA / B. Existing player overrides take priority; low evidence uses GS.')
