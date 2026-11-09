"""Run the production accuracy/braking hooks and native GS comparison/commit.

Ordinary HC scene outcomes are fixtures; the original comparison, attack commit,
stop body, friction and acceleration execute. No game/server session is run.
"""
import argparse,json,struct,sys
from pathlib import Path
from unicorn import UC_HOOK_CODE
from unicorn.x86_const import *
ROOT=Path(__file__).resolve().parent.parent
sys.path.insert(0,str(ROOT/'tests'))
from validate_fire_bridge import FireMachine,OBS,FIRE,HC,REC,NATIVE_WAIT,SITES
from validate_stop_bridge import StopMachine,CALLERS,SITE,ORIGINAL
from validate_stop_math import NativeBlocks
from validate_points_bridge import BASE,DATA,STACK,STOP,words,floats

NAMES=['version','check_enabled','brake_enabled','mode','installed','commands','dt_releases',
       'guard_calls','unchanged','rechecks','canceled','dt_bypass','manual_bypass','fast_bypass',
       'unsupported','fallback','geometry_changed','precision_changed','brake_calls','brake_applied',
       'brake_fallback','last_command','last_weapon','probability','effective','threshold','speed','wish','before','after']
def status(machine):return dict(zip(NAMES,struct.unpack('<23I7f',machine.u.mem_read(machine.exports['sr_accuracy_status'],120))))
class Accuracy(FireMachine):
    def __init__(self,fault=None):
        super().__init__(fault,'accuracy_probe.dll');self.minimum=.65;self.scale=1
        self.store(self.weapon+0xd8,38)
        self.u.hook_add(UC_HOOK_CODE,self.config,begin=FIRE,end=FIRE)
    def config(self,u,a,size,unused):
        sp=u.reg_read(UC_X86_REG_ESP);u.mem_write(sp+0x2c,floats(self.minimum));u.mem_write(sp+0x90,floats(self.scale))
    def prepare(self,mode=8,check=1,brake=0):return bool(self.call('accuracy_prepare',[BASE,len(self.image),mode,check,brake])&255)
    def status(self):return status(self)
    def native_comparison(self,probability,threshold,scale,scaled):
        # Actual instructions at 43354C0F apply the same threshold/multiplier.
        u=self.u;sp=self.frame;self.store(self.candidate+0x34,0x20 if scaled else 0)
        u.mem_write(sp+0x2c,floats(threshold));u.mem_write(sp+0x90,floats(scale))
        u.reg_write(UC_X86_REG_ESP,sp);u.reg_write(UC_X86_REG_EAX,self.candidate)
        u.reg_write(UC_X86_REG_XMM0,int.from_bytes(floats(probability)+bytes(12),'little'))
        reached=[]
        def end(uc,address,size,unused):reached.append(address);uc.emu_stop()
        handles=[u.hook_add(UC_HOOK_CODE,end,begin=at,end=at) for at in (0x43354c35,0x43354c5c)]
        try:u.emu_start(0x43354c0f,STOP,count=10000)
        finally:
            for h in handles:u.hook_del(h)
        assert reached;return reached[0]==0x43354c5c
class Brake(StopMachine):
    def __init__(self,fault=None):super().__init__(fault,'accuracy_probe.dll')
    def prepare(self,mode=8,enabled=1):return bool(self.call('accuracy_prepare',[BASE,len(self.image),mode,0,enabled])&255)
    def status(self):return status(self)

def ready(**kwargs):
    m=Accuracy();assert m.prepare(**kwargs);m.set_command();m.observe();return m
def main():
    parser=argparse.ArgumentParser();parser.add_argument('--donor',required=True);args=parser.parse_args()
    cases=0;comparisons=0;brake_cases=0
    for mode in (0,1,2,3,6):
        m=Accuracy();before=bytes(m.u.mem_read(BASE,len(m.image)));assert m.prepare(mode=mode,check=1,brake=1)
        assert bytes(m.u.mem_read(BASE,len(m.image)))==before and not m.status()['installed'];cases+=1
    m=Accuracy();before=bytes(m.u.mem_read(BASE,len(m.image)));assert m.prepare(check=0,brake=0)
    assert bytes(m.u.mem_read(BASE,len(m.image)))==before;cases+=1
    for fault in ('allocate','protect','flush','flush_core','fls'):
        m=Accuracy(fault);before=bytes(m.u.mem_read(BASE,len(m.image)));assert not m.prepare(check=1,brake=1)
        assert bytes(m.u.mem_read(BASE,len(m.image)))==before and not m.status()['installed'];cases+=1
    for address in (OBS,FIRE,HC,0x43354b55,0x43354b9a,0x43354c2a,0x4341b8b1,0x4341b8cf,SITE):
        m=Accuracy();m.u.mem_write(address,b'\xcc');before=bytes(m.u.mem_read(BASE,len(m.image)))
        assert not m.prepare(check=1,brake=1) and bytes(m.u.mem_read(BASE,len(m.image)))==before;cases+=1
    m=ready();m.sample();assert m.fire() and m.hc_calls==1 and m.status()['unchanged']==1;cases+=1
    m=ready(brake=1);m.sample();m.u.mem_write(m.weapon+0xc4,floats(.02));m.probability=.1
    assert not m.fire() and m.status()['canceled']==1 and bytes(m.u.mem_read(SITE,6))!=ORIGINAL;cases+=1
    m=ready();m.sample();m.u.mem_write(m.weapon+0xc4,floats(.02));m.probability=.1
    assert not m.fire();m.sample();m.u.mem_write(m.weapon+0xe4,floats(62))
    assert m.fire() and m.hc_calls==3 and m.status()['rechecks']==1,'one additional HC budget per command';cases+=1
    m=ready();m.sample();m.u.mem_write(m.weapon+0xc4,floats(.02))
    assert not m.fire(allow=False) and m.hc_calls==1;cases+=1
    # Current native threshold is respected even when HC returns true below it.
    for probability in (0,.3,.64,.65,.6501,.8,1):
        for scale,scaled in ((1,False),(.5,True),(1.2,True)):
            native=Accuracy();expected=native.native_comparison(probability,.65,scale,scaled)
            m=ready();m.scale=scale;m.store(m.candidate+0x34,0x20 if scaled else 0)
            m.sample();m.u.mem_write(m.weapon+0xc4,floats(.02));m.probability=probability;m.hc_result=True
            assert m.fire()==expected,(probability,scale,m.status())
            if expected:assert bytes(m.u.mem_read(m.candidate+0x38,4))==floats(probability),'fresh HC metadata must follow the successful recheck'
            assert m.hc_calls==2 and m.status()['precision_changed']==1
            assert m.word(m.cmd+0x30)==int(expected)
            assert bytes(m.u.mem_read(REC,6))==SITES[REC]
            assert bytes(m.u.mem_read(0x433ac017,len(NATIVE_WAIT)))==NATIVE_WAIT
            comparisons+=1
    for changed in ('eye','point','spread','target'):
        m=ready();m.sample()
        if changed=='eye':m.u.mem_write(m.weapon+0xe4,floats(62))
        elif changed=='point':m.u.mem_write(m.candidate+0x14,floats(62))
        elif changed=='spread':m.u.mem_write(m.weapon+0xd0,floats(.04))
        else:m.store(m.candidate+4,3)
        m.probability=.1;m.hc_result=True
        assert not m.fire() and m.hc_calls==2 and m.status()['canceled']==1
        assert not m.fire() and m.hc_calls==2,'duplicate guard must reuse failed result'
        # Inputs changing again in the SAME command must not trigger a trace loop.
        m.u.mem_write(m.weapon+0xe4,floats(63));assert m.fire() and m.hc_calls==2
        assert m.status()['fallback']==1;cases+=1
    for site in (HC,0x43354b55,0x43354b9a):
        m=ready();m.sample(site);m.u.mem_write(m.weapon+0xe4,floats(62));m.probability=.1;m.hc_result=False
        assert not m.fire();cases+=1
    for mode,charge,flags,release in ((0,0,0,True),(0,5,0,False),(1,5,8,False),(3,0,0,True)):
        m=ready()
        if release:m.set_command(101,mode,charge,flags)
        else:m.set_command(100,mode,charge,flags)
        m.observe();m.observe();m.sample();m.u.mem_write(m.weapon+0xe4,floats(62));m.probability=0;m.hc_result=False
        assert m.fire() and m.hc_calls==1 and m.status()['dt_bypass']==1;cases+=1
    for buttons in (1,0x800,0x801):
        m=ready();m.set_command(buttons=buttons);m.observe();m.sample();m.u.mem_write(m.weapon+0xc4,floats(.02));m.probability=0
        assert m.fire() and m.hc_calls==1 and m.status()['manual_bypass']==1;cases+=1
    for weapon in (11,38,40,1,9,31,64):
        m=ready();m.store(m.weapon+0xd8,weapon);m.sample();m.u.mem_write(m.weapon+0xc4,floats(.02));m.probability=0
        assert m.fire()==(weapon not in (11,38,40));cases+=1
    for defect in ('stale','foreign','nonfinite','invalid_threshold','invalid_probability','no_sample','heap','set'):
        m=Accuracy(defect if defect in ('heap','set') else None);assert m.prepare();m.set_command();m.observe()
        if defect!='no_sample':m.sample()
        m.u.mem_write(m.weapon+0xe4,floats(62));m.probability=0;m.hc_result=False
        if defect=='stale':m.store(m.cmd+4,101)
        elif defect=='foreign':m.candidate+=0x1000
        elif defect=='nonfinite':m.u.mem_write(m.weapon+0xc4,floats(float('nan')))
        elif defect=='invalid_threshold':m.minimum=float('nan')
        elif defect=='invalid_probability':m.probability=float('nan')
        assert m.fire() and m.status()['fallback']>=1;cases+=1
    m=ready();m.fixture=False;m.store(m.weapon,0x4000);m.sample();m.u.mem_write(m.weapon+0xe4,floats(62))
    assert m.fire() and m.hc_calls==1 and m.status()['fast_bypass']==1;cases+=1
    m=ready();m.sample();m.u.mem_write(m.weapon+0xe4,floats(62));m.fixture=False
    assert m.fire() and m.hc_calls==2 and m.status()['fallback']==1;cases+=1
    m=ready();m.sample();m.u.mem_write(m.weapon+0xe4,floats(62));m.thread=2
    assert m.fire() and m.hc_calls==1 and m.status()['fallback']==1;cases+=1
    # Original donor arithmetic, native GS movement body and all three CALL ABIs.
    oracle=NativeBlocks(args.donor)
    for caller in range(3):
        for grounded in (True,False):
            for velocity in ((0,0,0),(1,0,0),(10,0,0),(25,0,0),(120,90,0),(-260,90,0)):
                original=Brake();assert original.prepare(enabled=0);old,old_axes,old_angles=original.run_native(velocity,grounded,caller)
                m=Brake();assert m.prepare();result,axes,angles=m.run_native(velocity,grounded,caller)
                assert result==old and angles==old_angles and m.completed==original.completed
                if m.sample is None:assert axes==old_axes and m.status()['brake_calls']==0
                else:
                    speed,wish,accel=m.sample;expected=oracle.brake([1,0,speed,wish,accel,1/64,1],grounded)[0]
                    assert floats(axes[0])==floats(expected) and axes[1]==old_axes[1]
                    assert m.status()['brake_applied']==1
                brake_cases+=1
    for fault in ('allocate','protect','flush','flush_core'):
        m=Brake(fault);before=bytes(m.u.mem_read(BASE,len(m.image)));assert not m.prepare()
        assert bytes(m.u.mem_read(BASE,len(m.image)))==before;cases+=1
    for path in (ROOT/'source/skeet/VM/bytecode.json',):
        for group in json.loads(path.read_text()):
            for entry in (group['main'],*group['others']):
                for address,length in ((OBS,6),(FIRE,8),(SITE,6),*((s,5) for s in (HC,0x43354b55,0x43354b9a))):
                    assert entry['vip']+entry['size']<=address or entry['vip']>=address+length
    report={'guard_and_rollback_cases':cases,'actual_native_threshold_comparisons':comparisons,'actual_gs_stop_cases':brake_cases,
            'nl_braking_original_x86_oracle':True,'native_attack_commit_executed':True,'dt_release_and_burst_preserved':True,
            'recharge_instructions_unchanged':True,'ordinary_hitchance_outcomes':'controlled fixture',
            'fresh_hc_metadata_preserved':True,
            'full_nl_autostop_controller':False,'gameplay_tested':False}
    (ROOT/'build/stock_resolver_accuracy_validation.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))
if __name__=='__main__':main()
