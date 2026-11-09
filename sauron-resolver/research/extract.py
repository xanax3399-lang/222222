from pathlib import Path
import json
from lupa.luajit21 import LuaRuntime
from vm_sandbox import BOOTSTRAP,dump_graph
R=Path(__file__).resolve().parent
s=(R/'original.lua').read_bytes()
old=b'return m(H(),{},F())(...);';assert s.count(old)==1
s=s.replace(old,b'return {proto=H(),vm=m,env=F()};')
lua=LuaRuntime(encoding=None,register_eval=False,register_builtins=False)
result=lua.execute(BOOTSTRAP)(s)
g=dump_graph(lua,result);(R/'graph.json').write_text(json.dumps(g))
print('graph objects',len(g['objects']))
