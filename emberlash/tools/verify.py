"""Compile only. Never execute the attached Lua or any reconstructed callback."""
from pathlib import Path
import hashlib,json,sys
from lupa.luajit21 import LuaRuntime
ROOT=Path(__file__).resolve().parent
if not (ROOT/'original.lua').exists() and (ROOT.parent/'original.lua').exists():ROOT=ROOT.parent

def uleb(data,pos):
 value=0;shift=0
 while True:
  c=data[pos];pos+=1;value|=(c&127)<<shift
  if c<128:return value,pos
  shift+=7

def prototypes(data):
 assert data[:4]==b'\x1bLJ\x02'
 flags,pos=uleb(data,4)
 if not flags&2:length,pos=uleb(data,pos);pos+=length
 count=0
 while True:
  length,pos=uleb(data,pos)
  if not length:break
  count+=1;pos+=length
 assert pos==len(data)
 return count

def verify(folder=ROOT):
 report=json.loads((folder/'validation.json').read_text())
 original=(folder/'original.lua').read_bytes();source=(folder/'emberlash_source.lua').read_bytes()
 assert hashlib.sha256(original).hexdigest()==report['input_sha256']
 assert hashlib.sha256(source).hexdigest()==report['source_sha256']
 lua=LuaRuntime(encoding=None)
 dump=lua.eval(b'function(s) local f,e=loadstring(s,"@emberlash.lua"); assert(f,e); return string.dump(f,"sd") end')
 a=dump(original);b=dump(source)
 assert a==dump(original),'Deterministic LuaJIT dump flag is unavailable'
 assert a==b,'Instructions/constants/upvalues/prototypes changed'
 assert len(a)==report['stripped_bytecode_bytes']
 assert hashlib.sha256(a).hexdigest()==report['stripped_bytecode_sha256']
 assert prototypes(a)==report['functions_preserved']+1==2301
 print(json.dumps({'verified':True,'functions':2300,'identical_deterministic_bytecode':True,'bytecode_bytes':len(a),'runtime_executed':False}))
if __name__=='__main__':verify(Path(sys.argv[1]) if len(sys.argv)>1 else ROOT)
