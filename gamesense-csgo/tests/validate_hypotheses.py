#!/usr/bin/env python3
"""Test real adapter/shim code in x86 emulation; no game or OS injection.

Optional --donor nl.bin checks the recovered branch against donor instructions.
The shim test runs the compiled Windows C++ bridge, not a Python substitute.
Only fmod from the C runtime is stubbed. DllMain is never run.
"""
import argparse
import ctypes as C
import hashlib
import json
import math
from pathlib import Path
import random
import struct
import subprocess
import pefile
from unicorn import Uc, UC_ARCH_X86, UC_MODE_32, UC_HOOK_CODE
from unicorn.x86_const import *

ROOT=Path(__file__).resolve().parents[1]
BASE,DATA,STACK,SHIM,STOP,PEBASE,RUNTIME=0x43310000,0x20000000,0x30000000,0x50000000,0x51000000,0x60000000,0x71000000
SITE,CONT=BASE+0xeb4be,BASE+0xeb4cb
CALLERS=[0x43345e34,0x4336a702,0x4336d838,0x43387cf7,0x43398e1b,0x43416476,0x4341672b]
F32=C.c_float
def f32(x):return F32(x).value
def packed(x):return struct.pack('<f',x)
def normalize(x):
    x=f32(math.fmod(x,360))
    if x>180:x=f32(x-360)
    if x< -180:x=f32(x+360)
    return x

class Plan(C.Structure):
    _fields_=[('code',C.c_ubyte*128),('jump',C.c_ubyte*13),('length',C.c_uint32)]

def host():
    lib=C.CDLL(str(ROOT/'build/hypotheses_probe.so'))
    lib.probe_donor.argtypes=[F32,C.c_uint32,C.POINTER(F32)];lib.probe_donor.restype=C.c_bool
    lib.probe_adapt.argtypes=[F32,C.c_uint32,F32,F32,C.POINTER(F32)];lib.probe_adapt.restype=C.c_bool
    lib.probe_plan.argtypes=[C.c_void_p,C.c_uint32,C.c_uint32,C.c_uint32,C.POINTER(Plan)];lib.probe_plan.restype=C.c_bool
    lib.probe_caller.argtypes=[C.c_uint32];lib.probe_caller.restype=C.c_bool
    return lib

class Machine:
    def __init__(self,image):
        self.uc=Uc(UC_ARCH_X86,UC_MODE_32);u=self.uc
        pe=pefile.PE(str(ROOT/'build/hypotheses_probe.dll'));pe.relocate_image(PEBASE)
        for base,size in [(BASE,len(image)),(DATA,0x10000),(STACK,0x20000),(SHIM,0x1000),(STOP,0x1000),
                          (PEBASE,pe.OPTIONAL_HEADER.SizeOfImage),(RUNTIME,0x10000)]:
            u.mem_map(base,(size+4095)&-4096)
        u.mem_write(BASE,image);u.mem_write(PEBASE,pe.get_memory_mapped_image())
        self.exports={s.name.decode().lstrip('_'):PEBASE+s.address for s in pe.DIRECTORY_ENTRY_EXPORT.symbols if s.name}
        self.imports={}
        for module in pe.DIRECTORY_ENTRY_IMPORT:
            for entry in module.imports:
                address=RUNTIME+len(self.imports)*16
                self.imports[address]=entry.name.decode() if entry.name else '#'+str(entry.ordinal)
                u.mem_write(entry.address,struct.pack('<I',address))
        u.hook_add(UC_HOOK_CODE,self.runtime,begin=RUNTIME,end=RUNTIME+0xffff)
        # Return helper: load the double result to x87 ST(0), then RET.
        u.mem_write(STOP+0x100,b'\xdd\x05'+struct.pack('<I',DATA+0x4000)+b'\xc3')
        # Capture entire FXSAVE state without modifying general registers.
        u.mem_write(STOP+0x200,b'\x0f\xae\x05'+struct.pack('<I',DATA+0x5000))

    def calibrate_fxrestore(self):
        # Unicorn 2.1.4 restores x87 values/control but leaves FIP at the last
        # executed FP instruction. Reproduce independently before excluding
        # exactly those four environment bytes from the bridge comparison.
        u=self.uc
        code=b'\xdb\xe3\xd9\xe8\xd9\xeb'+b'\x0f\xae\x05'+struct.pack('<I',DATA+0x5000)
        code+=b'\xd9\xed'+b'\x0f\xae\x0d'+struct.pack('<I',DATA+0x5000)
        code+=b'\x0f\xae\x05'+struct.pack('<I',DATA+0x5200)
        u.mem_write(STOP+0x400,code);u.emu_start(STOP+0x400,STOP+0x400+len(code),count=20)
        before=bytes(u.mem_read(DATA+0x5000,512));after=bytes(u.mem_read(DATA+0x5200,512))
        differences=[i for i in range(512) if before[i]!=after[i]]
        assert differences and all(8<=i<12 for i in differences),differences
        return differences

    def runtime(self,u,address,size,user):
        if address==STOP+0x100:return
        name=self.imports.get(address)
        if name not in ('fmod','_fmod'):raise AssertionError(('unexpected runtime call',name,hex(address)))
        sp=u.reg_read(UC_X86_REG_ESP);a,b=struct.unpack('<dd',u.mem_read(sp+4,16))
        u.mem_write(DATA+0x4000,struct.pack('<d',math.fmod(a,b)))
        u.reg_write(UC_X86_REG_EIP,STOP+0x100)

    def fx(self):
        u=self.uc;u.emu_start(STOP+0x200,STOP+0x207,count=10)
        return bytes(u.mem_read(DATA+0x5000,512))

    def run_shim(self,plan,rng,variant,yaw,low,high,caller,df,entry=SITE):
        u=self.uc;sp=STACK+0x10000;ebp=sp+0x200;record=DATA+0x1000
        u.mem_write(STACK,bytes(0x20000));u.mem_write(DATA,bytes(0x3000))
        u.mem_write(self.exports['skeet_nl_hypotheses_status'],struct.pack('<10i',1,1,1,0,0,0,-1,0,0,0))
        u.mem_write(SHIM,bytes(plan.code));u.mem_write(SITE,bytes(plan.jump))
        u.mem_write(ebp+4,struct.pack('<I',caller))
        u.mem_write(record+0x2c,packed(yaw));u.mem_write(record+0x4c,struct.pack('<I',123456))
        u.mem_write(sp+0x3c,struct.pack('<I',variant));u.mem_write(sp+0x50,packed(high)+packed(low))
        u.mem_write(sp+0x44,struct.pack('<I',variant*0x3a0))
        # Nonempty x87 stack, arbitrary XMM upper lanes, non-default FP controls.
        fp_setup=b'\xdb\xe3'+b'\xd9\xe8'*8 # FNINIT, full x87 stack
        u.mem_write(STOP+0x300,fp_setup)
        u.emu_start(STOP+0x300,STOP+0x300+len(fp_setup),count=20)
        u.reg_write(UC_X86_REG_FPCW,0xa7f);u.reg_write(UC_X86_REG_MXCSR,0x5f80)
        for i,reg in enumerate([UC_X86_REG_XMM0,UC_X86_REG_XMM1,UC_X86_REG_XMM2,UC_X86_REG_XMM3,
                                UC_X86_REG_XMM4,UC_X86_REG_XMM5,UC_X86_REG_XMM6,UC_X86_REG_XMM7]):
            u.reg_write(reg,(rng.getrandbits(96)<<32)|struct.unpack('<I',packed(11.25+i))[0])
        regs=[UC_X86_REG_EAX,UC_X86_REG_EBX,UC_X86_REG_ECX,UC_X86_REG_EDX,UC_X86_REG_ESI,
              UC_X86_REG_EDI,UC_X86_REG_EBP,UC_X86_REG_ESP,UC_X86_REG_EFLAGS]
        values=[rng.getrandbits(32) for _ in range(4)]+[record,DATA+0x2000,ebp,sp,0x8d7|(0x400 if df else 0)]
        for reg,value in zip(regs,values):u.reg_write(reg,value)
        before_regs=[u.reg_read(r) for r in regs];before_fx=self.fx()
        u.mem_write(sp+0x14,before_fx[176:180])
        callback_args=[]
        def inspect_callback(uc,address,size,user):
            call_sp=uc.reg_read(UC_X86_REG_ESP)
            r,fx=struct.unpack('<II',uc.mem_read(call_sp+4,8))
            assert (call_sp+4)%16==0
            assert r==sp-36 and fx%16==0 and r-fx>=512
            assert not uc.reg_read(UC_X86_REG_EFLAGS)&0x400
            assert struct.unpack('<8I',uc.mem_read(r,32))==(values[5],values[4],ebp,sp-4,values[1],values[3],values[2],values[0])
            callback_args.append((r,fx))
        h=u.hook_add(UC_HOOK_CODE,inspect_callback,begin=self.exports['probe_bridge'],end=self.exports['probe_bridge'])
        try:u.emu_start(entry,CONT,count=100000)
        finally:u.hook_del(h)
        assert u.reg_read(UC_X86_REG_EIP)==CONT,'detour did not resume native code'
        assert len(callback_args)==1
        expected_regs=before_regs[:];expected_regs[0]=variant*0x3a0 # displaced native MOV EAX
        assert expected_regs==[u.reg_read(r) for r in regs],'register/flag corruption'
        after_fx=self.fx()
        status=struct.unpack('<10i',u.mem_read(self.exports['skeet_nl_hypotheses_status'],40))
        result=bytes(u.mem_read(record+0x5c0+variant*0x3a0,4))
        assert result==bytes(u.mem_read(sp+0x14,4))
        expected_fx=bytearray(before_fx)
        if status[4]:expected_fx[176:180]=result
        assert all(a==b for i,(a,b) in enumerate(zip(after_fx,expected_fx)) if not 8<=i<12),('FPU/SSE state corruption',[(i,a,b) for i,(a,b) in enumerate(zip(after_fx,expected_fx)) if a!=b],status)
        if not status[4]:assert result==before_fx[176:180]
        assert status[3]==1 and status[4]+status[5]==1,status
        return status,result

def donor_cases(path,lib,rng):
    image=Path(path).read_bytes()
    assert hashlib.sha256(image).hexdigest()=='682ce73b371349f87da6fd9365f8550e240dcdb97951e80445e70286275ad96e'
    u=Uc(UC_ARCH_X86,UC_MODE_32);base=0x412a0000
    u.mem_map(base,(len(image)+4095)&-4096);u.mem_write(base,image)
    for address,size in [(0,0x1000),(DATA,0x40000),(STACK,0x20000),(STOP,0x1000)]:u.mem_map(address,size)
    u.reg_write(UC_X86_REG_FPCW,0x37f);u.reg_write(UC_X86_REG_MXCSR,0x1f80)
    u.mem_write(STOP+0x100,b'\xdd\x05'+struct.pack('<I',DATA+0x100)+b'\xc3')
    def stub(uc,a,s,_):
        sp=uc.reg_read(UC_X86_REG_ESP)
        if a==0x42031040:
            x,y=struct.unpack('<dd',uc.mem_read(sp+4,16))
            uc.mem_write(DATA+0x100,struct.pack('<d',math.fmod(x,y)))
            uc.reg_write(UC_X86_REG_EIP,STOP+0x100)
        else:
            uc.reg_write(UC_X86_REG_EAX,0)
            uc.reg_write(UC_X86_REG_EIP,struct.unpack('<I',uc.mem_read(sp,4))[0]);uc.reg_write(UC_X86_REG_ESP,sp+4)
    for a in [0x42026d1b,0x42031040,0x41da7c5c]:u.hook_add(UC_HOOK_CODE,stub,begin=a,end=a)
    count=0
    for trial in range(1600):
        yaw=f32(rng.uniform(-7200,7200));variant=trial%8
        context,owner,var,current,anim,previous=[DATA+x for x in [0x18000,0x19000,0x1b000,0x1c000,0x1d000,0x1e000]]
        def dword(p,v):u.mem_write(p,struct.pack('<I',v))
        u.mem_write(context,struct.pack('<IIIII',owner,var,current-4,anim-4,previous))
        dword(current-4,current);dword(anim-4,anim);dword(previous,0);dword(var,variant)
        u.mem_write(current+0x2c,packed(yaw));u.mem_write(anim+0x80,packed(12345))
        sp=STACK+0x10000;u.mem_write(sp,struct.pack('<III',STOP,0,0))
        for reg,value in [(UC_X86_REG_ESP,sp),(UC_X86_REG_ECX,context),(UC_X86_REG_EDX,0),(UC_X86_REG_EFLAGS,2)]:u.reg_write(reg,value)
        u.emu_start(0x41339870,STOP,count=200000)
        assert u.reg_read(UC_X86_REG_EIP)==STOP
        output=F32(12345);written=lib.probe_donor(yaw,variant,C.byref(output))
        assert written==(variant!=0)
        assert bytes(u.mem_read(anim+0x80,4))==packed(output.value),(yaw,variant,output.value)
        count+=1
    return count

def main():
    p=argparse.ArgumentParser();p.add_argument('--donor');args=p.parse_args()
    lib=host();rng=random.Random(8802);image=(ROOT/'source/skeet/Binary/skeet.bin').read_bytes()
    image_buffer=C.create_string_buffer(image)
    machine=Machine(image);fp_limitation=machine.calibrate_fxrestore();plan=Plan()
    assert lib.probe_plan(image_buffer,len(image),SHIM,machine.exports['probe_bridge'],C.byref(plan))
    assert len(bytes(plan.code)[:plan.length])==plan.length<=128
    assert (SITE+5+struct.unpack('<i',bytes(plan.jump)[1:5])[0])&0xffffffff==SHIM
    assert (SHIM+plan.length+struct.unpack('<i',bytes(plan.code)[plan.length-4:plan.length])[0])&0xffffffff==CONT
    compatibility=0
    for size in [0,len(image)-1,len(image)+1]:
        assert not lib.probe_plan(image_buffer,size,SHIM,1,C.byref(Plan()));compatibility+=1
    assert not lib.probe_plan(None,len(image),SHIM,1,C.byref(Plan()));compatibility+=1
    for off in [0xeac08,0xeb4b8,0xeb4bd,0xeb4be,0xeb4ca,0xeb4cb,0xeb4d6]:
        changed=bytearray(image);changed[off]^=1;buf=C.create_string_buffer(bytes(changed))
        assert not lib.probe_plan(buf,len(image),SHIM,1,C.byref(Plan()));compatibility+=1
    for address in CALLERS:assert lib.probe_caller(address)
    for address in [0,0xffffffff,SITE,CONT]+[a-1 for a in CALLERS]:assert not lib.probe_caller(address)
    adaptation=0
    for trial in range(6000):
        yaw=f32(rng.uniform(-7200,7200));variant=trial%3
        low=f32(rng.uniform(-180,0));high=f32(rng.uniform(0,180));out=F32(12345)
        assert lib.probe_adapt(yaw,variant,low,high,C.byref(out))
        delta=max(low,min(high,[60,-30,-60][variant]))
        expected=normalize(f32(yaw+delta))
        assert packed(out.value)==packed(expected),(yaw,variant,low,high,out.value,expected)
        adaptation+=1
    invalid=[(0,3,-58,58),(0,0,1,58),(0,0,-58,-1),(0,0,-181,58),(0,0,-58,181)]
    for x in [float('nan'),float('inf'),-float('inf'),7201,-7201]:invalid.append((x,0,-58,58))
    for x in [float('nan'),float('inf'),-float('inf')]:invalid.extend([(0,0,x,58),(0,0,-58,x)])
    for arguments in invalid:
        out=F32(12345);assert not lib.probe_adapt(*arguments,C.byref(out));assert out.value==12345
    shim_count=0
    for caller in CALLERS:
        for variant in range(3):
            for df in [False,True]:
                # Common entry; preceding normalization store; native JBE
                # bypass directly to common entry (CF is set in test flags).
                for entry in [SITE,BASE+0xeb4b8,BASE+0xeb483]:
                    yaw=rng.uniform(-540,540);low,high=-58.0,58.0
                    status,result=machine.run_shim(plan,rng,variant,yaw,low,high,caller,df,entry)
                    expected=F32();assert lib.probe_adapt(yaw,variant,low,high,C.byref(expected))
                    assert result==packed(expected.value)
                    assert status[4]==1 and status[5]==0 and status[6]==variant and status[7]==123456
                    shim_count+=1
    for arguments in [(0,0,-58,58,CONT),(9,0,-58,58,CALLERS[0]),(0,float('nan'),-58,58,CALLERS[1]),
                      (0,0,-58,-2,CALLERS[2]),(0,0,-181,58,CALLERS[3])]:
        status,result=machine.run_shim(plan,rng,*arguments,True)
        assert status[4]==0 and status[5]==1;shim_count+=1
    report={'passed':True,'adapter_cases':adaptation,'invalid_adapter_cases':len(invalid),
            'compatibility_rejections':compatibility,'compiled_x86_bridge_shim_cases':shim_count,
            'bridge_guards_tested':['seven native callers','three variants','finite/range checks','direction flag'],
            'preserved_state':['general registers','ESP','EFLAGS','XMM upper lanes','other XMM registers','x87 stack/control','MXCSR'],
            'core_sha256':hashlib.sha256(image).hexdigest(),'shim_length':plan.length,
            'scope':'Compiled C++ plus x86 shim in Unicorn; fmod runtime stub; no DllMain, game or hit-rate test.',
            'game_runtime_tested':False,'accuracy_improvement_measured':False}
    subprocess.run(['g++','-O2',str(ROOT/'tests/fxrestore_host.cpp'),'-o',str(ROOT/'build/fxrestore_host')],check=True)
    report['real_host_fxsave_fxrstor']=subprocess.check_output([str(ROOT/'build/fxrestore_host')],text=True).strip()
    report['emulator_limitation']={'calibration_differing_offsets':fp_limitation,
        'excluded_bridge_comparison_offsets':[8,9,10,11],
        'reason':'Unicorn 2.1.4 does not restore x87 FIP; real-host independent round trip compared all 512 bytes.'}
    if args.donor:report['donor_branch_bitwise_matches']=donor_cases(args.donor,lib,rng)
    (ROOT/'build/hypotheses_validation.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))

if __name__=='__main__':main()
