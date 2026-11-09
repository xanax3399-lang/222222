from pathlib import Path
import re,json
from lupa.lua54 import LuaRuntime

ROOT=Path(__file__).resolve().parent
text=(ROOT/'original.lua').read_text()
pattern=re.compile(r'''\s+|--\[(=*)\[[\s\S]*?\]\1\]|--[^\n]*|"(?:\\[\s\S]|[^"\\])*"|'(?:\\[\s\S]|[^'\\])*'|\[(=*)\[[\s\S]*?\]\2\]|0[xX][\da-fA-F]+(?:\.[\da-fA-F]*)?(?:[pP][+-]?\d+)?|\d+(?:\.\d*)?(?:[eE][+-]?\d+)?|[A-Za-z_]\w*|\.\.\.|\.\.|==|~=|<=|>=|::|<<|>>|//|[^\s]''')
tokens=[m.group()for m in pattern.finditer(text)if not m.group().isspace()and not m.group().startswith('--')]
lua=LuaRuntime(encoding=None)
def literal(s):
 value=lua.eval(('function()return '+s+' end').encode())()
 if isinstance(value,bytes):
  return '"'+''.join(chr(c)if 32<=c<127 and c not in (34,92)else '\\%03d'%c for c in value)+'"'
 if isinstance(value,(int,float)):
  return str(int(value))if int(value)==value else repr(value)
 return s
normal=[]
for token in tokens:
 if token[0]in '\'"'or token[0].isdigit():token=literal(token)
 normal.append(token)
(ROOT/'tokens.json').write_text(json.dumps(normal))
lines=[];current=[]
for token in normal:
 if token in ('local','function','return','if','elseif','else','end','while','repeat','until','for','goto','::')and current:
  lines.append(' '.join(current));current=[]
 current.append(token)
 if token in (';','then','do'):
  lines.append(' '.join(current));current=[]
if current:lines.append(' '.join(current))
(ROOT/'wrapper.normalized.lua').write_text('\n'.join(lines)+'\n')
print('tokens',len(tokens),'lines',len(lines))

