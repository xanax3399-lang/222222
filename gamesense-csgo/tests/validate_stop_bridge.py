"""Run the compiled production stop bridge inside the actual GS stop function.

Game entity/vtable/ConVars and the external CRT atan2 are fixtures. Original GS
friction, acceleration helper, counter-angle flow and return/cleanup execute.
NL arithmetic expectations come from its original x86 block, not a Python port.
"""
import argparse
import json
import math
import struct
from validate_points_bridge import Machine,ROOT,BASE,DATA,STACK,STOP,SHIM,words,floats
from validate_stop_math import NativeBlocks
from unicorn import UC_HOOK_CODE
from unicorn.x86_const import *

SITE,CONT,DONE=0x433886e4,0x433886ea,0x433886f8
ORIGINAL=bytes.fromhex('f30f1044240c')
CALLERS=[0x433702fb,0x43372c65,0x433ce122]

class StopMachine(Machine):
    def __init__(self,fault=None):
        super().__init__(fault,'stop_bridge_probe.dll')
        self.command=DATA+0x10000;self.entity=DATA+0x20000
        self.frame=STACK+0x10000;self.snapshots=[]
        self.u.mem_map(0x77509000,4096)
        self.u.hook_add(UC_HOOK_CODE,self.atan2,begin=0x77509ee0,end=0x77509ee0)
        self.u.hook_add(UC_HOOK_CODE,self.observe,begin=SITE,end=SITE)
        self.u.hook_add(UC_HOOK_CODE,self.observe,begin=DONE,end=DONE)
        self.u.mem_write(STOP+0x800,b'\xff\x23') # fixture spoof-return gadget
        self.store(0x43476448,STOP+0x800)
        self.store(self.entity,DATA+0x25000)
        self.store(DATA+0x25000+0x450,STOP+0x900)
        self.u.mem_write(STOP+0x900,b'\xdd\x05'+words(DATA+0x26000)+b'\xc3')
        self.u.mem_write(DATA+0x26000,struct.pack('<d',250.0))
        self.convar(0x43467124,0xc5c9925e,DATA+0x30000,80)
        self.convar(0x4346a820,0xeaaec541,DATA+0x30100,5.2)
        self.convar(0x43467968,0x1632541c,DATA+0x30200,5.5)
        self.convar(0x43467e28,0xe80c95f9,DATA+0x30300,0)
        self.store(0x434688d0,DATA+0x40000)
        self.store(DATA+0x40000,0x104^0xe2fbe695);self.store(0x43468c24,0)
        self.store(0x4346a398,DATA+0x40010)
        self.store(DATA+0x40010,0x108^0x6b1a59b5);self.store(0x4346a564,0)
        self.store(0x434685cc,DATA+0x40020)
        self.store(DATA+0x40020,0x200^0x3eb71843);self.store(0x43468a84,0)
        self.store(0x4346a338,DATA+0x40030)
        self.u.mem_write(DATA+0x40030,floats(1/64))
        self.u.mem_write(self.entity+0x200,floats(250))

    def convar(self,address,key,node,value):
        self.store(address,node^key);self.store(node+0x1c,node)
        bits=struct.unpack('<I',floats(value))[0]
        self.store(node+0x2c,node^bits);self.store(node+0x30,node)

    def atan2(self,u,a,size,_):
        val=lambda reg:struct.unpack('<d',u.reg_read(reg).to_bytes(16,'little')[:8])[0]
        result=math.atan2(val(UC_X86_REG_XMM0),val(UC_X86_REG_XMM1))
        u.reg_write(UC_X86_REG_XMM0,int.from_bytes(struct.pack('<d',result)+bytes(8),'little'))
        sp=u.reg_read(UC_X86_REG_ESP)
        u.reg_write(UC_X86_REG_EIP,self.word(sp));u.reg_write(UC_X86_REG_ESP,sp+4)

    def state(self):
        regs=[UC_X86_REG_EAX,UC_X86_REG_EBX,UC_X86_REG_ECX,UC_X86_REG_EDX,
              UC_X86_REG_ESI,UC_X86_REG_EDI,UC_X86_REG_EBP,UC_X86_REG_ESP,
              UC_X86_REG_EFLAGS,UC_X86_REG_FPCW,UC_X86_REG_FPSW,UC_X86_REG_FPTAG,
              UC_X86_REG_MXCSR,*range(UC_X86_REG_XMM0,UC_X86_REG_XMM7+1)]
        return [self.u.reg_read(r) for r in regs]

    def observe(self,u,address,size,_):
        if address==SITE:
            sp=u.reg_read(UC_X86_REG_ESP)
            self.sample=struct.unpack('<f',u.mem_read(sp+0x1c,4))[0],struct.unpack('<f',u.mem_read(sp+8,4))[0],struct.unpack('<f',u.mem_read(sp+0x20,4))[0]
            self.pre=self.state()
        else:
            self.completed=self.state()

    def prepare(self,mode=2,enabled=1):
        return bool(self.call('stop_prepare',[BASE,len(self.image),mode,enabled])&255)

    def status(self):
        return struct.unpack('<8I6f',self.u.mem_read(self.exports['skeet_nl_stop_status'],56))

    def run_native(self,velocity,grounded=True,caller=0,invalid=False,buttons=0x401):
        u=self.u;self.store(self.entity+0x104,int(grounded))
        self.store(self.entity+0x108,0)
        self.store(self.command+0x30,buttons) # attack + unrelated buttons survive
        u.mem_write(self.command+0x24,floats(123,-19))
        u.mem_write(self.command+0xc,floats(11,37,0))
        angles=DATA+0x27000;u.mem_write(angles,b'\xa5'*16)
        sp=STACK+0x18000;u.mem_write(sp,words(angles,0xaaaaaaaa,0xbbbbbbbb))
        u.reg_write(UC_X86_REG_ESP,sp);u.reg_write(UC_X86_REG_ECX,self.entity)
        u.reg_write(UC_X86_REG_EDX,self.command)
        for reg,v in zip([UC_X86_REG_XMM0,UC_X86_REG_XMM1,UC_X86_REG_XMM2],velocity):
            u.reg_write(reg,int.from_bytes(floats(v)+bytes(12),'little'))
        nonvol=[UC_X86_REG_EBX,UC_X86_REG_ESI,UC_X86_REG_EDI,UC_X86_REG_EBP]
        values=[0x12345678,0x22334455,0x33445566,0x44556677]
        for reg,v in zip(nonvol,values):u.reg_write(reg,v)
        u.reg_write(UC_X86_REG_FPCW,0x37f);u.reg_write(UC_X86_REG_MXCSR,0x1f80)
        u.reg_write(UC_X86_REG_EFLAGS,0x202)
        self.sample=None;self.completed=None
        u.emu_start(CALLERS[caller],CALLERS[caller]+5,count=100000)
        assert u.reg_read(UC_X86_REG_EIP)==CALLERS[caller]+5
        assert u.reg_read(UC_X86_REG_ESP)==sp+4,'Wrong RET 4 cleanup'
        assert [u.reg_read(r) for r in nonvol]==values
        assert self.word(self.command+0x30)==(buttons&0xfffff9e5),'Attack/buttons changed'
        assert bytes(u.mem_read(angles+12,4))==b'\xa5'*4
        return bool(u.reg_read(UC_X86_REG_EAX)&255),struct.unpack('<2f',u.mem_read(self.command+0x24,8)),bytes(u.mem_read(angles,12))

def main():
    p=argparse.ArgumentParser();p.add_argument('--donor',required=True);args=p.parse_args()
    oracle=NativeBlocks(args.donor);cases=0;native_cases=0
    for mode,enabled in [(0,1),(1,1),(2,0),(3,0)]:
        m=StopMachine();assert m.prepare(mode,enabled)
        assert bytes(m.u.mem_read(SITE,6))==ORIGINAL and m.status()[3]==0
        cases+=1
    for fault in ['allocate','protect','flush','flush_core']:
        m=StopMachine(fault);assert not m.prepare()
        assert bytes(m.u.mem_read(SITE,6))==ORIGINAL and m.status()[3]==0
        cases+=1
    m=StopMachine();m.u.mem_write(SITE,b'\xcc');assert not m.prepare();cases+=1
    # Run each real call instruction through the actual native GS stop body.
    for caller in range(3):
        for grounded in [True,False]:
            for velocity in [(0,0,0),(1,0,0),(10,0,0),(25,0,0),(120,90,0),(-260,90,0)]:
                stock=StopMachine();assert stock.prepare(0)
                old,old_axes,old_angles=stock.run_native(velocity,grounded,caller)
                m=StopMachine();assert m.prepare(2 if caller%2==0 else 3)
                ret,axes,angles=m.run_native(velocity,grounded,caller)
                assert ret==old and angles==old_angles
                assert m.completed==stock.completed,'Native return GPR/flags/x87/SSE state changed'
                st=m.status()
                if m.sample is None:
                    assert axes==old_axes and st[4:7]==(0,0,0)
                else:
                    speed,wish,accel=m.sample
                    expected=oracle.brake([1,0,speed,wish,accel,1/64,1],grounded)[0]
                    assert floats(axes[0])==floats(expected),(velocity,grounded,axes,expected,st)
                    assert axes[1]==old_axes[1] and st[4:7]==(1,1,0)
                    assert st[8]==speed and st[9]==wish and st[10]==accel
                native_cases+=1
    for caller in range(3):
        for buttons in [0x405,0x20401,0x20405]: # duck, walk, duck+walk
            for speed in [10,25,150]:
                stock=StopMachine();assert stock.prepare(0)
                old,old_axes,old_angles=stock.run_native((speed,0,0),caller=caller,buttons=buttons)
                m=StopMachine();assert m.prepare()
                ret,axes,angles=m.run_native((speed,0,0),caller=caller,buttons=buttons)
                assert ret==old and angles==old_angles and m.completed==stock.completed
                assert m.sample is not None
                v,w,a=m.sample
                expected=oracle.brake([1,0,v,w,a,1/64,1],True)[0]
                assert floats(axes[0])==floats(expected) and axes[1]==old_axes[1]
                native_cases+=1
    # Invalid numeric inputs after native helper must preserve native overshoot.
    m=StopMachine();assert m.prepare()
    m.convar(0x43467968,0x1632541c,DATA+0x30200,101)
    old=StopMachine();assert old.prepare(0)
    old.convar(0x43467968,0x1632541c,DATA+0x30200,101)
    result=m.run_native((250,0,0),invalid=True)
    original=old.run_native((250,0,0),invalid=True)
    assert result==original and m.status()[6]==1,(result,original,m.status());cases+=1
    # Ensure VM preparation cannot overwrite the bridge site.
    for group in json.loads((ROOT/'source/skeet/VM/bytecode.json').read_text()):
        for entry in [group['main'],*group['others']]:
            assert entry['vip']+entry['size']<=SITE or entry['vip']>=SITE+6
    report={'native_gs_stop_cases':native_cases,'guards_modes_and_rollback_cases':cases,
        'native_gs_friction_and_acceleration_executed':True,'three_native_call_instructions_executed':True,
        'expected_brake_from_original_nl_x86':True,'native_counter_angles_and_attack_preserved':True,
        'fxsave_gpr_and_flags_preserved_at_success':True,'gs_eligibility_and_friction_retained':True,
        'full_nl_stop_controller_ported':False,'gameplay_tested':False}
    (ROOT/'reports/stop_bridge_validation.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report))

if __name__=='__main__':main()
