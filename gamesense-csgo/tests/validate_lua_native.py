"""Execute the compiled Lua bridge and actual GS bootstrap CALL instruction.

Lua table/closure/string allocation is a controlled GS C API fixture. The
production hook, native stack operations, callbacks, and x86 ABI execute. This
does not run the real Lua VM, compat bytecode, user scripts or the game.
"""
from pathlib import Path
import json,struct,math
from unicorn import UC_HOOK_CODE
from unicorn.x86_const import *
from validate_points_bridge import Machine,ROOT,BASE,DATA,STACK,STOP,words

SITE,ORIGINAL=0x433ec5c0,bytes.fromhex('e81bc9ffff')
STATE,VALUES,OBJECT=DATA+0x10000,DATA+0x11000,DATA+0x30000
class LuaMachine(Machine):
 def __init__(self,fault=None):
    super().__init__(fault,probe='lua_api_probe.dll');self.events=[];self.registered={};self.strings={};self.object=OBJECT
    self.api_fault=None;self.closure=None
    self.u.hook_add(UC_HOOK_CODE,self.lua_api)
 def top(self):return self.word(STATE+0x14)
 def push(self,value):self.u.mem_write(self.top(),value);self.store(STATE+0x14,self.top()+8)
 def text(self,address):
    result=bytearray()
    for i in range(1048576):
        c=bytes(self.u.mem_read(address+i,1))
        if c==b'\0':return result.decode()
        result+=c
    raise AssertionError('Missing string terminator')
 def returns(self,value=0):
    u=self.u;sp=u.reg_read(UC_X86_REG_ESP);ret=self.word(sp)
    u.reg_write(UC_X86_REG_EAX,value);u.reg_write(UC_X86_REG_ESP,sp+4);u.reg_write(UC_X86_REG_EIP,ret)
 def lua_api(self,u,address,size,unused):
    sp=u.reg_read(UC_X86_REG_ESP);arg=lambda i:self.word(sp+4*i)
    if address==0x43426632:
        assert arg(1)==STATE and arg(2)==(-10000&0xffffffff)and self.text(arg(3))=='_PRELOAD'and arg(4)==1
        self.events.append('find_preload');self.push(words(OBJECT,0xfffffff4));self.returns(DATA if self.api_fault else 0)
    elif address==0x43432f73:
        assert arg(1)==STATE and arg(3)==0;self.events.append('push_native_loader');self.closure=arg(2)
        self.push(words(self.closure,0xfffffff7));self.returns()
    elif address==0x43435b37:
        assert arg(1)==STATE and arg(2)==(-2&0xffffffff)and self.text(arg(3))=='gsnl_native'
        self.events.append('set_preload');self.store(STATE+0x14,self.top()-8);self.returns()
    elif address==0x433e8ee0:
        assert u.reg_read(UC_X86_REG_ECX)==STATE;self.events.append(('original_compat',self.top()));self.returns()
    elif address==0x43436420:
        assert arg(1)==STATE and self.text(arg(2))=='gsnl_native'and arg(4)==0
        entries=arg(3)
        for i in range(32):
            name,handler=struct.unpack('<II',u.mem_read(entries+i*8,8))
            if name==0:break
            self.registered[self.text(name)]=handler
        else:raise AssertionError('Unterminated luaL_Reg')
        self.push(words(OBJECT,0xfffffff4));self.returns()
    elif address==0x434370e4:
        assert arg(1)==STATE;text=self.text(arg(2));p=self.object;self.object+=(len(text)+32+15)&-16
        assert self.object<DATA+0x70000
        self.store(p+12,len(text));u.mem_write(p+16,text.encode()+b'\0');self.strings[p]=text
        self.push(words(p,0xfffffffb));self.returns(p+16)
 def runtime(self,u,address,size,unused):
    if self.imports.get(address)=='fmod':
        sp=u.reg_read(UC_X86_REG_ESP);x,y=struct.unpack('<dd',u.mem_read(sp+4,16))
        u.mem_write(DATA+0x80000,struct.pack('<d',math.fmod(x,y)));u.reg_write(UC_X86_REG_EIP,STOP+0x100);return
    return super().runtime(u,address,size,unused)
 def prepare(self,values=()):
    self.store(STATE+0x10,VALUES);self.store(STATE+0x14,VALUES);self.store(STATE+0x18,VALUES+0x800)
    for value in values:self.push(value if isinstance(value,bytes)else struct.pack('<d',value))
 def call(self,address,*args):
    u=self.u;sp=STACK+0x18000;u.mem_write(sp,words(STOP,*args));u.reg_write(UC_X86_REG_ESP,sp)
    u.reg_write(UC_X86_REG_FPCW,0x37f);u.reg_write(UC_X86_REG_MXCSR,0x1f80)
    u.emu_start(address,STOP,count=1000000)
    assert u.reg_read(UC_X86_REG_EIP)==STOP and u.reg_read(UC_X86_REG_ESP)==sp+4
    return u.reg_read(UC_X86_REG_EAX)
 def results(self,count):
    out=[]
    for at in range(self.top()-8*count,self.top(),8):
        a,b=struct.unpack('<II',self.u.mem_read(at,8))
        if b==0xffffffff:out.append(None)
        elif b==0xfffffffb:out.append(self.strings[a])
        else:out.append(struct.unpack('<d',self.u.mem_read(at,8))[0])
    return out

def main():
 cases=0
 for fault in [None,'flush']:
    m=LuaMachine(fault);before=bytes(m.u.mem_read(BASE,len(m.image)))
    ok=m.call(m.exports['lua_probe_apply'],BASE,len(m.image));assert ok==int(fault is None)
    after=bytes(m.u.mem_read(BASE,len(m.image)))
    if fault:assert after==before
    else:assert after[:SITE-BASE]==before[:SITE-BASE]and after[SITE-BASE+5:]==before[SITE-BASE+5:]
    cases+=1
 for size,base in [(0,BASE),(0x2fc000,BASE+4096)]:
    m=LuaMachine();assert m.call(m.exports['lua_probe_apply'],base,size)==0;cases+=1
 m=LuaMachine();m.u.mem_write(SITE,b'\x90');assert m.call(m.exports['lua_probe_apply'],BASE,len(m.image))==0;cases+=1
 m=LuaMachine();m.store(m.exports['gsnl_lua_status']+4,0)
 assert m.call(m.exports['lua_probe_apply'],BASE,len(m.image))==1 and bytes(m.u.mem_read(SITE,5))==ORIGINAL;cases+=1
 for failure in [False,True]:
    m=LuaMachine();assert m.call(m.exports['lua_probe_apply'],BASE,len(m.image))==1
    m.prepare([11,22]);m.api_fault=failure;old_top=m.top();u=m.u
    u.reg_write(UC_X86_REG_ESP,STACK+0x18000);u.reg_write(UC_X86_REG_ECX,STATE)
    u.emu_start(SITE,SITE+5,count=1000000)
    assert u.reg_read(UC_X86_REG_EIP)==SITE+5 and u.reg_read(UC_X86_REG_ESP)==STACK+0x18000
    assert m.top()==old_top
    assert m.events==(['find_preload',('original_compat',old_top)]if failure else ['find_preload','push_native_loader','set_preload',('original_compat',old_top)])
    status=struct.unpack('<7I',u.mem_read(m.exports['gsnl_lua_status'],28))
    assert status[:5]==(1,1,1,1,int(not failure))and status[6]==int(failure);cases+=1
    if failure:continue
    m.prepare([0]);assert m.call(m.closure,STATE)==1
    assert set(m.registered)=={'abi_version','source','snapshot','length3','dot3','normalize_yaw'};cases+=1
    for name,args,expected in [('abi_version',[],65536),('dot3',[1,2,3,4,5,6],32),('length3',[3,4,12],13),('normalize_yaw',[540],-180)]:
        m.prepare(args);ret=m.call(m.registered[name],STATE);assert ret==1 and m.results(ret)==[expected],(name,m.results(ret));cases+=1
    for name,args in [('dot3',[1]),('length3',[1,2,float('nan')]),('normalize_yaw',[words(0,0xffffffff)])]:
        m.prepare(args);ret=m.call(m.registered[name],STATE)
        assert ret==2 and m.results(ret)[0]is None and 'required'in m.results(ret)[1];cases+=1
    m.prepare();ret=m.call(m.registered['snapshot'],STATE);assert ret==18 and m.results(18)[:7]==[72,65536,2,6,1,123,456];cases+=1
    m.prepare();ret=m.call(m.registered['source'],STATE);assert ret==1
    assert m.results(1)[0]==(ROOT/'build/gsnl_embedded.lua').read_text();cases+=1
 report={'compiled_native_lua_cases':cases,'actual_gs_bootstrap_call_executed':True,
    'preload_registered_before_original_compat':True,'existing_stack_restored':True,
    'native_math_c_callbacks_executed':True,'lua_allocating_apis_controlled_fixtures':True,
    'diagnostic_values_controlled_fixture':True,'real_gs_lua_vm_tested':False,'gameplay_tested':False}
 (ROOT/'reports/lua_native_validation.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))
if __name__=='__main__':main()
