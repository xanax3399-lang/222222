"""Verify actual PE architecture and exact embedded server resource (BINARY/201)."""
import hashlib,json,struct,sys
from pathlib import Path
root=Path(sys.argv[1] if len(sys.argv)>1 else 'Release')
class PE:
 def __init__(self,p):
  self.b=Path(p).read_bytes();b=self.b
  assert b[:2]==b'MZ'
  self.pe=struct.unpack_from('<I',b,60)[0];assert b[self.pe:self.pe+4]==b'PE\0\0'
  self.machine,self.count=struct.unpack_from('<HH',b,self.pe+4);self.opt=self.pe+24
  size=struct.unpack_from('<H',b,self.pe+20)[0];self.sections=[]
  for n in range(self.count):
   off=self.opt+size+n*40;vsize,rva,rsize,raw=struct.unpack_from('<IIII',b,off+8);self.sections.append((rva,max(vsize,rsize),raw))
  self.dirs=self.opt+(112 if struct.unpack_from('<H',b,self.opt)[0]==0x20b else 96)
 def at(self,rva):
  for start,size,raw in self.sections:
   if start<=rva<start+size:return raw+rva-start
  raise AssertionError('RVA outside sections')
 def resource(self,kind,identifier):
  rva,size=struct.unpack_from('<II',self.b,self.dirs+16);assert size
  base=self.at(rva)
  def entries(offset):
   named,ids=struct.unpack_from('<HH',self.b,base+offset+12)
   for i in range(named+ids):
    name,value=struct.unpack_from('<II',self.b,base+offset+16+i*8)
    if name&0x80000000:
     p=base+(name&0x7fffffff);length=struct.unpack_from('<H',self.b,p)[0];name=self.b[p+2:p+2+2*length].decode('utf-16le')
    yield name,value
  first=dict(entries(0))[kind];assert first&0x80000000
  second=dict(entries(first&0x7fffffff))[identifier];assert second&0x80000000
  language=list(entries(second&0x7fffffff))[0][1];assert not language&0x80000000
  data_rva,length=struct.unpack_from('<II',self.b,base+language);p=self.at(data_rva)
  return self.b[p:p+length]
server=PE(root/'neverlose-server.exe');injector=PE(root/'injector.exe')
dll_path=root/'neverlose.dll'
if dll_path.exists():
 dll=PE(dll_path);assert dll.machine==0x14c
 assert hashlib.sha256(dll.resource('BINARY',101)).hexdigest()=='682ce73b371349f87da6fd9365f8550e240dcdb97951e80445e70286275ad96e'
assert server.machine==0x8664 and injector.machine==0x14c
embedded=injector.resource('BINARY',201);assert embedded==server.b,'Embedded server differs from release server'
runtime=root/'libunwind.dll'
if runtime.exists():assert injector.resource('BINARY',202)==runtime.read_bytes(),'Bundled runtime differs'
result={'bundled_runtime_verified':runtime.exists(),'injector':'x86 PE32','embedded_server':'x64 PE32+','embedded_bytes':len(embedded),'embedded_sha256':hashlib.sha256(embedded).hexdigest(),'exact_resource_match':True,'full_dll_built':(root/'neverlose.dll').exists(),'windows_runtime_tested':False}
(root/'build_receipt.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
