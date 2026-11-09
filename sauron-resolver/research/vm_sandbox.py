from pathlib import Path
import hashlib,json
from lupa.luajit21 import LuaRuntime,lua_type
ROOT=Path(__file__).resolve().parent
SHA256='eb49cf0ca426ea748aadd008694cde1f2a2ce5a64a4d5bf524768a78825718fe'
BOOTSTRAP=b'''
local debug=debug
local safe=_G
local allowed={assert=true,error=true,pcall=true,xpcall=true,select=true,type=true,
 tostring=true,tonumber=true,next=true,pairs=true,ipairs=true,rawget=true,rawset=true,
 rawequal=true,setmetatable=true,getmetatable=true,string=true,table=true,math=true,
 coroutine=true,unpack=true,getfenv=true,setfenv=true,loadstring=true,load=true,
 _G=true,_VERSION=true,newproxy=true}
local bitlib=require('bit')
for key in pairs(safe)do if not allowed[key]then safe[key]=nil end end
safe.bit=bitlib
return function(source)
 local fn,err=loadstring(source,'@sigma-unpack');assert(fn,err);setfenv(fn,safe)
 local budget=0
 debug.sethook(function()budget=budget+10000;if budget>20000000 then error('Unpack instruction budget exhausted')end end,'',10000)
 local ok,result=pcall(fn);debug.sethook();assert(ok,result)
 return result
end
'''
def unpack():
 raw=(ROOT/'new_sigma_pred.original.lua').read_bytes()
 assert hashlib.sha256(raw).hexdigest()==SHA256
 marker=b'for l,e in pairs({(function(e,...)'
 assert raw.count(marker)==1
 raw=raw[raw.index(marker):]
 old=b'return p(H(),{},_())(...);'
 assert raw.count(old)==1
 source=raw.replace(old,b'return {proto=H(),vm=p,env=_()};')
 runtime=LuaRuntime(encoding=None,register_eval=False,register_builtins=False)
 result=runtime.execute(BOOTSTRAP)(source)
 return runtime,result
def dump_graph(runtime,result):
 objects=[];seen={};tostring=runtime.eval(b'tostring')
 def encode(value):
  kind=lua_type(value)
  if kind=='table':
   identity=tostring(value)
   if identity in seen:return {'ref':seen[identity]}
   index=len(objects);seen[identity]=index;obj={'id':index,'items':[]};objects.append(obj)
   obj['items']=[[encode(k),encode(v)]for k,v in value.items()]
   return {'ref':index}
  if kind=='function':return {'function':True}
  if isinstance(value,bytes):
   try:return value.decode('utf-8')
   except UnicodeDecodeError:return {'bytes':value.hex()}
  return value
 graph={'root':encode(result),'objects':objects}
 (ROOT/'application.graph.json').write_text(json.dumps(graph,ensure_ascii=False,indent=2)+'\n')
 return graph
if __name__=='__main__':
 runtime,result=unpack();graph=dump_graph(runtime,result)
 print('graph tables',len(graph['objects']))
