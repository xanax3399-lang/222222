from pathlib import Path
from lupa.luajit21 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1]
def wrapper(source):
    body = source.split('return --[[ Function 299 ]] function()', 1)[1]
    body = body.split('\n                                end\n                            end)(value_20))())', 1)[0]
    return 'return function(argument)\n' + body + '\nend'

MOCK = '''
temporary = unpack
truthy_iterator = function(f, s, c) return f, s, c end
local next_id = 0
local controls = {}
local function create(...)
    next_id = next_id + 1
    controls[next_id] = {...}
    return next_id
end
return setmetatable({
    get = function(id) return false end,
    name = function(id) return "mock" end,
    type = function(id) return "checkbox" end,
    set = function() end, set_callback = function() end,
    set_visible = function() end, update = function() end,
    reference = function() return create(), create() end
}, {__index = function() return create end})
'''

CHECK = '''return function(state)
    local a,b = state.find("AA", "Anti-aimbot angles", "Pitch")[1], nil
    assert(a.reference ~= nil)
    local group = state.create("AA", "Anti-aimbot angles")
    local count = 1
    for _, method in ipairs({"switch", "hotkey", "combo", "selectable", "slider", "input", "list", "color_picker", "string"}) do
        local control = group[method](group, method, 0, 100)
        assert(control.reference ~= nil, method)
        count = count + 1
    end
    assert(group:label("label").reference ~= nil)
    assert(group:button("button", function() end).reference ~= nil)
    local ok = pcall(function() group:switch("switch") end)
    assert(not ok, "duplicate control must fail")
    return count + 3
end'''

if __name__ == '__main__':
    source = (ROOT / 'outlaw_source.lua').read_text()
    old = source.replace('value = callback\n', 'value = nil\n', 1)
    for name, text in [('before',old),('after',source)]:
        lua = LuaRuntime()
        api = lua.execute(MOCK)
        try:
            count = lua.execute(CHECK)(lua.execute(wrapper(text))(api))
        except Exception as exc:
            if name == 'after': raise
            assert "nil value" in str(exc), str(exc)
            print('Before: reproduced nil upvalue failure')
        else:
            assert name == 'after', 'Baseline unexpectedly passed'
            print('After:', count, 'UI checks passed')
    for name in ['outlaw_source.lua', 'outlaw_deobfuscated.lua']:
        ok, error = LuaRuntime().eval('function(s) local f,e=loadstring(s); return f ~= nil,e end')((ROOT/name).read_text())
        assert ok, error
        print(name, 'LuaJIT compilation passed')
