-- Implementations are supplied by the DLL's native Lua preload module.
-- No FFI, external symbol lookup or module signature scanning is required.
local ok,backend=pcall(require,'gsnl_native')
assert(ok and type(backend)=='table','GSNL: native module unavailable; use the matching DLL and restart CS:GO')
for _,name in ipairs({'abi_version','source','snapshot','length3','dot3','normalize_yaw'})do
    assert(type(backend[name])=='function','GSNL: missing native function '..name)
end
assert(backend.abi_version()==0x10000,'GSNL: incompatible native Lua ABI')
local source=backend.source()
assert(type(source)=='string' and #source>0 and #source<1048576,'GSNL: invalid embedded source')
local factory,err=loadstring(source,'@skeet.dll/gsnl');assert(factory,err)
local function checked(fn)
    return function(...)
        local result,message=fn(...)
        assert(result~=nil,message or 'GSNL: native call failed')
        return result
    end
end
local native={gsnl_length3=checked(backend.length3),gsnl_dot3=checked(backend.dot3),
    gsnl_normalize_yaw=checked(backend.normalize_yaw),snapshot=backend.snapshot}
local gs={environment=_G,client=client,entity=entity,globals=globals,ui=ui,renderer=renderer,
    database=database,json=json or require('json'),bit=bit or require('bit')}
return factory()(native,gs)
