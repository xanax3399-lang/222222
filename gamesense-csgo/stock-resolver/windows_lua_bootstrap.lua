-- Real Windows x86 LuaJIT + the actual compiled DLL. No lookup substitution.
local ffi=require('ffi')
assert(ffi.os=='Windows' and ffi.abi('32bit'), 'Expected Windows x86 LuaJIT')
local core=ffi.load(assert(arg[1])) -- Injected-module analogue: absolute external path.
local file=assert(io.open(assert(arg[2]),'rb'));local source=file:read('*a');file:close()
local scenario=assert(arg[3])
if scenario=='snapshot_already_declared' then
    ffi.cdef(assert(source:match('(typedef struct {.-} sr_snapshot_v1;)')))
elseif scenario=='typeof_returns_nil' then
    local original=ffi.typeof
    ffi.typeof=function(...) local ok,value=pcall(original,...);if ok then return value end end
else assert(scenario=='clean') end
for pass=1,2 do
    local ok,why=pcall(assert(loadstring(source,'@stock_resolver.lua')))
    -- A standalone test process has no selected game mode. Reaching THIS guard
    -- proves the unmodified bootstrap resolved the library and all ABI queries.
    assert(not ok and tostring(why):find('Select loader option 2',1,true), tostring(why))
end
local by_name=ffi.load('skeet.dll')
core.sr_reset()
local input=ffi.new('sr_snapshot_v1[1]');local output=ffi.new('sr_decision_v1[1]')
local s=input[0]
s.player,s.identity,s.flags,s.interval=2,42,7,1/64
s.latency,s.lerp,s.max_unlag,s.eye_yaw,s.pose_yaw,s.velocity_x=.1,.03125,.2,60,-60,100
for tick=0,7 do
    s.simulation_time=10+tick/64;s.now=s.simulation_time+.1;s.origin_x=tick*1.5625
    assert(by_name.sr_feed(input,.65,output)==1)
end
assert(output[0].apply==1 and output[0].offset==-60,'Real x86 LuaJIT C++ call mismatch')
local stats=ffi.new('sr_stats_v1[1]');core.sr_stats(stats)
assert(stats[0].records==8,'DLL basename did not resolve the already loaded module')
print('Windows x86 Lua bootstrap passed: '..scenario..' (two loads, shared DLL, real model calls)')
