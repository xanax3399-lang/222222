"""Execute the full unmodified driver against real C++ with strict API fixtures.

The ffi.load DLL basename maps to the host library. Bootstrap, declarations,
callbacks and native calls execute unchanged, including partial typedef states.
"""
import json
import re
from pathlib import Path
from lupa.luajit21 import LuaRuntime

ROOT = Path(__file__).resolve().parent
BUILD = ROOT.parent / 'build'
source = (ROOT / 'stock_resolver.lua').read_text()
library = json.dumps(str(BUILD / 'stock_resolver_host.so'))
scenarios = []
for scenario in ('clean', 'snapshot_already_declared', 'typeof_returns_nil'):
    runtime = LuaRuntime(unpack_returned_tuples=True)
    runtime.execute((ROOT / 'driver_fixture.lua').read_text())
    if scenario == 'snapshot_already_declared':
        declaration = re.search(r'typedef struct \{[^}]*\} sr_snapshot_v1;', source).group()
        runtime.execute('require("ffi").cdef(' + json.dumps(declaration) + ')')
    runtime.execute('''
        local real = require('ffi')
        local proxy = setmetatable({}, {__index=real})
        local loads = 0
        proxy.load = function(name)
            assert(name=='skeet.dll', 'Unexpected DLL request: '..tostring(name))
            loads=loads+1
            return real.load(''' + library + ''')
        end
        test_native = real.load(''' + library + ''')
        test_loads = function() return loads end
        package.loaded.ffi = proxy
    ''')
    if scenario == 'typeof_returns_nil':
        runtime.execute('''
            local ffi=require('ffi'); local original=ffi.typeof
            ffi.typeof=function(...) local ok,value=pcall(original,...);if ok then return value end end
        ''')
    runtime.execute(source)
    checks = runtime.execute((ROOT / 'test_driver.lua').read_text())
    assert runtime.eval('test_loads()') == 1
    scenarios.append({'name': scenario, 'checks': checks})
report = {'checks': checks, 'runtime': 'LuaJIT 2.1 + real C++ shared library',
          'bootstrap_scenarios': scenarios, 'total_checks': sum(x['checks'] for x in scenarios),
          'windows_module_lookup': 'host library mapping', 'gamesense_api': 'strict offline fixture',
          'gameplay_tested': False}
(BUILD / 'stock_resolver_driver_validation.json').write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps(report))
