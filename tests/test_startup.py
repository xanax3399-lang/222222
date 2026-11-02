"""Run the recovered application initializer with offline GameSense stand-ins.

No native FFI, real game client, HTTP, or original author VM is exercised.
"""
from pathlib import Path
import json
from lupa.luajit21 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1]

def run():
    source = (ROOT / 'outlaw_source.lua').read_text()
    body = source.split('return --[[ Function 65 ]] function()', 1)[1].split(
        '\n            end\n        end)(msgpack, antiaim_funcs, csgo_weapons, http, images, websockets)', 1)[0]
    lua = LuaRuntime()
    lua.execute((ROOT / 'tests/gamesense_fixture.lua').read_text())
    lua.execute('debug.sethook(function() error("Offline instruction budget exceeded") end, "", 5000000)')
    factory = lua.execute('return function(argument, argument_2, argument_3, argument_4, argument_5, argument_6)\nreturn function()' + body + '\nend\nend')
    g = lua.globals()
    factory(g.mock_msgpack, g.mock_antiaim, g.mock_weapons, g.mock_http, g.mock_images, None)()
    initial = g.fixture_stats()
    delayed = lua.execute('''
        local seen, executed, i = {}, 0, 1
        while i <= #delayed and i <= 64 do
            local item=delayed[i]; i=i+1
            if not seen[item[1]] then
                seen[item[1]]=true
                item[1](unpack(item[2]))
                executed=executed+1
            end
        end
        assert(i > #delayed, "Delayed queue exceeded budget")
        return executed
    ''')
    final = g.fixture_stats()
    ui_count, errors, detail = g.fixture_ui_callbacks()
    assert errors == 0, detail
    variants, errors, detail = g.fixture_variants()
    assert errors == 0, detail
    events_count = lua.execute('''
        local count=0
        for _,item in ipairs(events) do
            if item[1]=='paint_ui' or item[1]=='paint' or item[1]=='shutdown' then
                item[2]()
                count=count+1
            end
        end
        return count
    ''')
    return {'initial_controls': initial[0], 'final_controls': final[0],
            'initial_event_registrations': final[1], 'delayed_initializers': delayed,
            'ui_callbacks': ui_count, 'ui_variants': variants,
            'menu_render_shutdown_callbacks_after_variants': events_count,
            'scope': 'offline Function 65 initialization and UI; native FFI, live server, gameplay and root loader untested'}

if __name__ == '__main__':
    print(json.dumps(run(), indent=2))
