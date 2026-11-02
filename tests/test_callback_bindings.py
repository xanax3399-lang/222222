from pathlib import Path
from lupa.luajit21 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1]

def check(source):
    lua = LuaRuntime()
    lua.execute('''
    truthy_iterator = function(f,s,c) return f,s,c end
    is_menu_open = function() return true end
    calls, events, visibility = {}, {}, {}
    screen_size = {find=function(...)
        return {visibility=function(self, visible)
            visibility[#visibility+1] = visible
        end}
    end}
    client = {set_event_callback=function(event, callback)
        assert(type(callback)=="function", event .. ": function expected, got " .. type(callback))
        events[event]=callback
    end}
    ''')
    start = source.index('local state_6 = {}', source.index('Function 242'))
    end = source.index('\n                                                        end', source.index('client.set_event_callback("shutdown",', start))
    lua.execute('local value_192\n' + source[start:end])
    lua.execute('''
    events.paint_ui()
    assert(#visibility==10)
    for i=1,10 do assert(visibility[i]==false) end
    events.shutdown()
    assert(#visibility==20)
    for i=11,20 do assert(visibility[i]==true) end
    ''')
    start = source.index('value_125 = ((function(argument)')
    end = source.index('\n                                                                                    callback_15 = value_46', start)
    lua.execute('''
    local value_192
    local temporary_30, value_151, value_125, callback_6
    local value_138 = {{"Default","encoded-default"}}
    local value_137 = {{"Custom","encoded-custom"}}
    local updates = 0
    local value_126 = {update=function(self, options)
        assert(options[1]=="Default" and options[2]=="Custom")
        updates=updates+1
    end}
    ''' + source[start:end] + '''
    assert(updates==1)
    callback_6()
    assert(updates==2)
    ''')
    # Execute the actual import callback binding, with a sentinel importer.
    binding = source[source.index('callback_15 = ', source.index('--[[ Function 296 ]]')):]
    binding = binding.split('\n', 1)[0]
    lua.execute('local value_192; local load_control=function() return "imported" end; local callback_15; ' + binding + '; assert(callback_15()=="imported")')
    binding = next(line.strip() for line in source.splitlines() if 'callback_16(value_136,' in line)
    lua.execute('''local value_192; local value_136={};
        local value_157=function() return "deleted" end
        local callback_16=function(self, f) assert(self==value_136); assert(f()=="deleted") end;
        ''' + binding)
    return 'UI hide/restore, config list initialization/refresh, import and delete callback bindings passed'

if __name__ == '__main__':
    source = (ROOT/'outlaw_source.lua').read_text()
    baseline = source.replace('client.set_event_callback("shutdown", callback_10)', 'client.set_event_callback("shutdown", nil)', 1)
    try:
        check(baseline)
    except Exception as exc:
        assert 'shutdown: function expected, got nil' in str(exc), str(exc)
        print('Before: reproduced shutdown callback registration failure')
    else:
        raise AssertionError('Baseline unexpectedly passed')
    print('After:', check((ROOT/'outlaw_source.lua').read_text()))
