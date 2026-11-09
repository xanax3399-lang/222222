"""Execute the unmodified driver callbacks against the real compiled C++ model.

Only the Windows module-path lookup is replaced with the host library path.
GameSense APIs are strict offline fixtures; this is not an in-game test.
"""
import json
from pathlib import Path
from lupa.luajit21 import LuaRuntime

ROOT = Path(__file__).resolve().parent
BUILD = ROOT.parent / 'build'
runtime = LuaRuntime(unpack_returned_tuples=True)
runtime.execute((ROOT / 'driver_fixture.lua').read_text())
source = (ROOT / 'stock_resolver.lua').read_text()
marker = 'local native = load_native()'
assert source.count(marker) == 1
library = json.dumps(str(BUILD / 'stock_resolver_host.so'))
runtime.execute(source.replace(marker, 'local native = ffi.load(' + library + ')'))
runtime.execute('test_native = require("ffi").load(' + library + ')')
checks = runtime.execute((ROOT / 'test_driver.lua').read_text())
report = {'checks': checks, 'runtime': 'LuaJIT 2.1 + real C++ shared library',
          'windows_module_lookup': 'fixture', 'gamesense_api': 'strict offline fixture',
          'gameplay_tested': False}
(BUILD / 'stock_resolver_driver_validation.json').write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps(report))
