#!/usr/bin/env python3
"""Compiled Windows installer and native core checksum, controlled WinAPI.

Exercises the production prepare() order and real x86 0x4333d6a2 checksum.
Does not execute DllMain, the VM, Steam, an injector or the game.
"""
import hashlib,json,struct
from pathlib import Path
from unicorn.x86_const import *
from validate_hypotheses import Machine,ROOT,BASE,SHIM,SITE,STACK,STOP,PEBASE

SIZE=0x2fc000
HASH_BASE,HASH_SIZE=0x4331e000,0x105b12
def expected_hash(image):
    h=0x811c9dc5
    start=HASH_BASE-BASE
    for b in image[start:start+HASH_SIZE]:h=((h^b)*0x1000193)&0xffffffff
    return h^0x92ca5df1

class StartupMachine(Machine):
    def __init__(self,image,fault=None):
        super().__init__(image)
        self.fault=fault;self.error=0;self.events=[];self.allocations=0;self.frees=0;self.flushes=[]
    def u32(self,address):return struct.unpack('<I',self.uc.mem_read(address,4))[0]
    def store(self,address,value):self.uc.mem_write(address,struct.pack('<I',value&0xffffffff))
    def runtime(self,u,address,size,user):
        name=self.imports.get(address)
        sp=u.reg_read(UC_X86_REG_ESP);ret=self.u32(sp);argc=0;result=0
        self.events.append(name)
        if name=='VirtualAlloc':
            argc=4;args=[self.u32(sp+4+i*4) for i in range(argc)]
            assert args==[0,4096,0x3000,4],args
            self.allocations+=1;result=0 if self.fault=='allocate' else SHIM
            if not result:self.error=8
        elif name=='VirtualProtect':
            argc=4;args=[self.u32(sp+4+i*4) for i in range(argc)]
            assert args[:3]==[SHIM,4096,0x20],args
            result=int(self.fault!='protect');self.store(args[3],4)
            if not result:self.error=5
        elif name=='GetCurrentProcess':result=0xffffffff
        elif name=='FlushInstructionCache':
            argc=3;process,where,length=[self.u32(sp+4+i*4) for i in range(argc)]
            assert process==0xffffffff and (where,length) in [(SHIM,128),(SITE,13)]
            self.flushes.append((where,length))
            fail=(self.fault=='flush_trampoline' and where==SHIM) or (self.fault=='flush_core' and len(self.flushes)==2)
            result=int(not fail)
            if fail:self.error=1117
        elif name=='GetLastError':result=self.error
        elif name=='SetLastError':argc=1;self.error=self.u32(sp+4)
        elif name=='VirtualFree':
            argc=3;args=[self.u32(sp+4+i*4) for i in range(argc)]
            assert args==[SHIM,0,0x8000],args
            self.frees+=1;result=1
            self.error=999 # Ensure cleanup cannot hide the original error.
        else:raise AssertionError(('unexpected installer API',name,hex(address)))
        u.reg_write(UC_X86_REG_EAX,result)
        u.reg_write(UC_X86_REG_ESP,sp+4+argc*4);u.reg_write(UC_X86_REG_EIP,ret)
    def call(self,export,args):
        u=self.uc;sp=STACK+0x10000
        u.mem_write(sp,struct.pack('<'+'I'*(len(args)+1),STOP,*args))
        u.reg_write(UC_X86_REG_ESP,sp);u.reg_write(UC_X86_REG_EFLAGS,2)
        u.emu_start(self.exports[export],STOP,count=20000000)
        assert u.reg_read(UC_X86_REG_EIP)==STOP,('installer did not return',hex(u.reg_read(UC_X86_REG_EIP)))
        return u.reg_read(UC_X86_REG_EAX)
    def message(self):
        address=self.call('probe_install_error',[]);s=bytearray()
        for i in range(244):
            ch=self.uc.mem_read(address+i,1)
            if ch==b'\0':return s.decode()
            s+=ch
        raise AssertionError('unterminated error')
    def status(self):return struct.unpack('<10i',self.uc.mem_read(self.exports['skeet_nl_hypotheses_status'],40))

def main():
    original=(ROOT/'source/skeet/Binary/skeet.bin').read_bytes();before=expected_hash(original)
    cases=[]
    for mode,fault,pointer,size,accepted,error in [
        (0,None,BASE,SIZE,True,0),
        (1,None,BASE,SIZE,True,0),
        (2,None,BASE,SIZE,False,87),
        (1,None,BASE+1,SIZE,False,487),
        (1,None,BASE,SIZE-1,False,1306),
        (1,'signature',BASE,SIZE,False,1306),
        (1,'allocate',BASE,SIZE,False,8),
        (1,'protect',BASE,SIZE,False,5),
        (1,'flush_trampoline',BASE,SIZE,False,1117),
        (1,'flush_core',BASE,SIZE,False,1117),
    ]:
        image=bytearray(original)
        if fault=='signature':image[SITE-BASE]^=1
        machine=StartupMachine(bytes(image),fault)
        assert bool(machine.call('probe_prepare',[pointer,size,mode])&255)==accepted,(mode,fault)
        after=bytes(machine.uc.mem_read(BASE,len(image)))
        sealed=machine.u32(machine.exports['probe_sealed_hash'])
        seal_calls=machine.u32(machine.exports['probe_seal_calls'])
        status=machine.status()
        assert machine.error==error,(mode,fault,machine.error,error)
        if accepted:
            assert seal_calls==1 and sealed==expected_hash(after)
            if mode==0:assert after==original and not machine.events and status[2]==0
            else:
                assert after!=original and sealed!=before and status[2]==1
                assert machine.allocations==1 and machine.frees==0
                assert machine.flushes==[(SHIM,128),(SITE,13)]
                # Reproduce the prior stale-checksum condition: a checksum
                # saved before this detour differs from the installed image.
                assert before!=sealed
        else:
            assert seal_calls==0 and status[2]==0 and after==image
            if fault in ('protect','flush_trampoline','flush_core'):assert machine.frees==1
            else:assert machine.frees==0
            assert machine.message().startswith('NL setup:')
        cases.append({'mode':mode,'fault':fault,'accepted':accepted,'error':error,
                      'seal_calls':seal_calls,'installed':bool(status[2]),'allocations':machine.allocations,
                      'frees':machine.frees,'error_message':machine.message() if not accepted else None})
    # The VM must not subsequently overwrite the hook or its contract guards.
    bytecode=json.loads((ROOT/'source/skeet/VM/bytecode.json').read_text())
    for unit in bytecode:
        for entry in [unit.get('main',{})]+unit.get('others',[]):
            if not entry:continue
            for start,length in [(0x433fac08,12),(0x433fb4b8,31)]:
                assert not(entry['vip']<start+length and entry['vip']+entry['size']>start)
    # Production must use the tested ordering helper, not a second manual path.
    source=(ROOT/'source/skeet/skeet.cpp').read_text()
    extra=source.split('bool skeet_t::extra()',1)[1].split('bool skeet_t::entry()',1)[0]
    assert 'nl_hypotheses_patch::prepare(' in extra and extra.count('recompile();')==1
    assert 'nl_hypotheses_patch::apply(' not in extra
    report={'passed':True,'cases':cases,'prior_stale_checksum_condition_reproduced':True,
            'checksum_range':[hex(HASH_BASE),hex(HASH_SIZE)],'checksum_function':'0x4333d6a2',
            'checksum_execution':'Original x86 instructions in Unicorn; independently compared to FNV-1a with native XOR.',
            'production_order':'install selected module, then prepare native checksum/VM',
            'vm_signature_overlap':False,'source_sha256':hashlib.sha256(source.encode()).hexdigest(),
            'patch_header_sha256':hashlib.sha256((ROOT/'source/skeet/nl_hypotheses_patch.h').read_bytes()).hexdigest(),
            'windows_runtime_tested':False,'game_runtime_tested':False,
            'limitations':'WinAPI controlled stubs; native VM initialization and original entry are not executed.'}
    (ROOT/'build/hypotheses_startup_validation.json').write_text(json.dumps(report,indent=2)+'\n')
    print('10 compiled startup cases passed; native checksum matches after installation; failures restore original bytes.')
if __name__=='__main__':main()
