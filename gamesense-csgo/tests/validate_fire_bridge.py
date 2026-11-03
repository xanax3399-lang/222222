"""Execute production hooks, the native recharge manager tail and attack commit.

Hotkey output, game globals and engine interfaces are controlled fixtures.
Hitchance outcomes are explicit fixtures, except separate native fast-path and
missing-entity ABI cases. This does not validate real spread/visibility on a map.
"""
import json,struct
from unicorn import UC_HOOK_CODE
from unicorn.x86_const import *
from validate_points_bridge import Machine,ROOT,BASE,DATA,STACK,STOP,words,floats

OBS,REC,FIRE,HC=0x433abe72,0x433ac017,0x43355ddf,0x43354bd3
SITES={OBS:bytes.fromhex('39bef4000000'),REC:bytes.fromhex('e871c80000'),
       FIRE:bytes.fromhex('8b4c241c8a542422'),HC:bytes.fromhex('e8ea680c00')}

class FireMachine(Machine):
    def __init__(self,fault=None):
        super().__init__(fault,'fire_bridge_probe.dll')
        self.ctx=DATA+0x10000;self.cmd=DATA+0x20000;self.weapon=DATA+0x30000
        self.candidate=DATA+0x40000;self.out=DATA+0x50000;self.frame=STACK+0x17000
        self.hc_context=DATA+0x60000;self.player=DATA+0x61000;self.recharging=DATA+0x62000
        self.fixture=True;self.probability=.8;self.hc_result=True;self.hc_calls=0
        self.u.hook_add(UC_HOOK_CODE,self.hitchance,begin=0x4341b4c2,end=0x4341b4c2)
        self.store(self.ctx,0x4346edd4)
        self.store(self.ctx+0x100,16);self.store(self.ctx+0xfc,14)
        self.store(self.ctx+0x10c,100)
        self.store(0x434757dc,DATA+0x70000);self.store(DATA+0x70000,0)
        self.store(0x4346a338,DATA+0x70010);self.u.mem_write(DATA+0x70010,floats(1/64))
        self.store(0x43467eb8,DATA+0x70020);self.u.mem_write(DATA+0x70020,floats(1))
        self.store(0x43475ba4,DATA+0x70030);self.store(DATA+0x70030,100)
        self.store(0x43475784,DATA+0x70040);self.store(0x43475788,DATA+0x70040)
        self.store(0x43475aac,DATA+0x71000)
        self.store(DATA+0x71000+0xbc,DATA+0x72000);self.store(DATA+0x71000+0xc0,DATA+0x72000)
        self.store(0x43475a60,DATA+0x70050);self.store(DATA+0x70050,64)
        self.store(0x43467f48,0);self.store(0x434721c4,STOP+0x200)
        self.u.mem_write(STOP+0x200,bytes.fromhex('b001c3')) # active aim hotkey
        self.u.mem_write(0x43467224,b'\x01')
        # Missing-entity native HC exit: thiscall entity list GetClientEntity.
        self.store(0x4346a890,DATA+0x73000);self.store(DATA+0x73000,DATA+0x73100)
        self.store(DATA+0x73100+0xc,STOP+0x300)
        self.u.mem_write(STOP+0x300,bytes.fromhex('31c0c20400'))
        self.u.mem_write(self.weapon+0xdc,floats(1,2,64))
        self.u.mem_write(self.candidate+0xc,floats(100,2,64))

    def hitchance(self,u,a,size,_):
        self.hc_calls+=1
        sp=u.reg_read(UC_X86_REG_ESP)
        assert u.reg_read(UC_X86_REG_ECX)==self.hc_context
        assert self.word(sp+4)==self.weapon and self.word(sp+8)==self.candidate
        if not self.fixture:return
        u.mem_write(self.word(sp+12),floats(self.probability))
        u.reg_write(UC_X86_REG_EAX,int(self.hc_result))
        u.reg_write(UC_X86_REG_ECX,0x12345678);u.reg_write(UC_X86_REG_EDX,0x87654321)
        u.reg_write(UC_X86_REG_ESP,sp+16);u.reg_write(UC_X86_REG_EIP,self.word(sp))

    def prepare(self,mode=6,guard=1,recharge=1):
        return bool(self.call('fire_prepare',[BASE,len(self.image),mode,guard,recharge])&255)

    def status(self):
        raw=bytes(self.u.mem_read(self.exports['skeet_v3_fire_status'],84))
        names=['version','guard_enabled','recharge_enabled','mode','installed','commands','dt_releases',
               'guard_calls','unchanged','rechecks','canceled','dt_bypass','manual_bypass','fallback',
               'recharge_checks','recharge_overrides','last_command','last_dt_mode','last_charge','last_desired','probability']
        return dict(zip(names,struct.unpack('<20If',raw)))

    def set_command(self,number=100,mode=1,charge=0,flags=0,buttons=0):
        self.store(self.ctx+0xf4,mode);self.store(self.ctx+0x104,charge)
        self.store(self.ctx+0x14,flags);self.store(self.cmd+4,number)
        self.store(self.cmd+8,12345);self.store(self.cmd+0x30,buttons)

    def native_frame(self):
        u=self.u;sp=self.frame
        u.mem_write(sp,words(0x11111111,0x22222222,0x33333333,0,0,0,self.player,STOP,0,self.cmd,self.recharging))
        u.reg_write(UC_X86_REG_ESP,sp);u.reg_write(UC_X86_REG_ESI,self.ctx)
        u.reg_write(UC_X86_REG_EBX,self.player);u.reg_write(UC_X86_REG_EDI,0)
        u.reg_write(UC_X86_REG_EDX,1);u.reg_write(UC_X86_REG_EAX,1)
        u.reg_write(UC_X86_REG_FPCW,0x37f);u.reg_write(UC_X86_REG_MXCSR,0x1f80)

    def observe(self):
        self.native_frame();self.u.emu_start(OBS,OBS+6,count=100000)
        assert self.u.reg_read(UC_X86_REG_EIP)==OBS+6
        assert self.u.reg_read(UC_X86_REG_ESP)==self.frame

    def sample(self):
        u=self.u;sp=self.frame
        u.mem_write(sp,words(self.weapon,self.candidate,self.out))
        u.reg_write(UC_X86_REG_ESP,sp);u.reg_write(UC_X86_REG_ECX,self.hc_context)
        u.reg_write(UC_X86_REG_EDX,0x55555555)
        values=[0x11111111,0x22222222,0x33333333,0x44444444]
        regs=[UC_X86_REG_EBX,UC_X86_REG_ESI,UC_X86_REG_EDI,UC_X86_REG_EBP]
        for r,v in zip(regs,values):u.reg_write(r,v)
        u.emu_start(HC,HC+5,count=1000000)
        assert u.reg_read(UC_X86_REG_EIP)==HC+5 and u.reg_read(UC_X86_REG_ESP)==sp+12
        assert [u.reg_read(r) for r in regs]==values

    def fire(self,allow=True):
        u=self.u;sp=self.frame
        u.mem_write(sp,bytes(0xc0));self.store(sp+0x18,self.candidate)
        self.store(sp+0x1c,DATA+0x80000);self.store(sp+0x28,self.cmd)
        u.mem_write(sp+0x22,bytes([int(allow)]))
        u.reg_write(UC_X86_REG_ESP,sp);u.reg_write(UC_X86_REG_EDI,self.weapon)
        u.reg_write(UC_X86_REG_ESI,0x11223344);u.reg_write(UC_X86_REG_EBX,0x22334455)
        u.reg_write(UC_X86_REG_EBP,0x33445566)
        u.reg_write(UC_X86_REG_FPCW,0x37f);u.reg_write(UC_X86_REG_MXCSR,0x1f80)
        for i in range(8):u.reg_write(UC_X86_REG_XMM0+i,(i+123)<<32)
        before=[u.reg_read(UC_X86_REG_XMM0+i) for i in range(8)]
        reached=[]
        def stop(uc,a,size,_):reached.append(a);uc.emu_stop()
        h=u.hook_add(UC_HOOK_CODE,stop,begin=0x43355e07,end=0x43355e07)
        h2=u.hook_add(UC_HOOK_CODE,stop,begin=0x43356146,end=0x43356146)
        try:u.emu_start(FIRE,STOP,count=1000000)
        finally:u.hook_del(h);u.hook_del(h2)
        assert reached and u.reg_read(UC_X86_REG_ESP)==sp
        assert [u.reg_read(UC_X86_REG_XMM0+i) for i in range(8)]==before
        assert u.reg_read(UC_X86_REG_ESI)==0x11223344 and u.reg_read(UC_X86_REG_EBX)==0x22334455
        assert u.reg_read(UC_X86_REG_EBP)==0x33445566 and u.reg_read(UC_X86_REG_EDI)==self.weapon
        assert u.reg_read(UC_X86_REG_FPCW)==0x37f and u.reg_read(UC_X86_REG_MXCSR)==0x1f80
        return reached[0]==0x43355e07

    def charge(self):
        self.native_frame();self.u.emu_start(OBS,STOP,count=1000000)
        assert self.u.reg_read(UC_X86_REG_EIP)==STOP
        assert self.u.reg_read(UC_X86_REG_ESP)==self.frame+44,'native RET 12 cleanup'
        return self.word(self.ctx+0x104)

def ready(mode=6,guard=1,recharge=1):
    m=FireMachine();assert m.prepare(mode,guard,recharge);m.set_command();return m

def main():
    cases=0
    for mode,g,r in [(0,1,1),(1,1,1),(2,1,1),(3,1,1),(6,0,0)]:
        m=FireMachine();assert m.prepare(mode,g,r)
        assert all(bytes(m.u.mem_read(a,len(b)))==b for a,b in SITES.items())
        assert not m.status()['installed'];cases+=1
    for fault in ['allocate','protect','flush','flush_core','fls']:
        m=FireMachine(fault);assert not m.prepare()
        assert all(bytes(m.u.mem_read(a,len(b)))==b for a,b in SITES.items())
        assert not m.status()['installed'];cases+=1
    for a,b in SITES.items():
        m=FireMachine();m.u.mem_write(a,b'\xcc');assert not m.prepare();cases+=1
    # Unchanged data never repeats expensive native HC; normal attack executes.
    m=ready();m.observe();m.sample();assert m.fire() and m.hc_calls==1
    assert m.status()['unchanged']==1 and m.word(m.cmd+0x30)==1;cases+=1
    # Eye or target point changes after candidate selection: fresh native HC
    # result is checked before the real native OR [cmd+30],IN_ATTACK instruction.
    for target_changed in [False,True]:
        for probability,result,expected in [(0,False,False),(0,True,False),(.8,True,True),(.1,False,False),(float('nan'),False,True)]:
            m=ready();m.observe();m.sample()
            changed=m.candidate+0x14 if target_changed else m.weapon+0xe4
            m.u.mem_write(changed,floats(62));m.probability=probability;m.hc_result=result
            assert m.fire()==expected and m.hc_calls==2
            assert m.status()['rechecks']==1
            assert m.word(m.cmd+0x30)==int(expected);cases+=1
    # Falling edge is the key RELEASE, not the double-shot. Repeated visits
    # retain its exemption; charged inactive mode and active burst are protected.
    for mode,charge,flags,release in [(0,0,0,True),(0,5,0,False),(1,5,8,False),(3,0,0,True)]:
        m=ready()
        if release:m.observe();m.set_command(101,mode,charge,flags)
        else:m.set_command(101,mode,charge,flags)
        m.observe();m.observe();m.sample();m.u.mem_write(m.weapon+0xe4,floats(62))
        m.probability=0;m.hc_result=False
        assert m.fire() and m.hc_calls==1 and m.status()['dt_bypass']==1;cases+=1
    # Exemption ends next command; release without remaining charge is not sticky.
    m=ready();m.observe();m.set_command(101,0);m.observe();m.set_command(102,0);m.observe()
    m.sample();m.u.mem_write(m.weapon+0xe4,floats(62));m.probability=0;m.hc_result=False
    assert not m.fire() and m.status()['dt_releases']==1;cases+=1
    for buttons in [1,0x800,0x801]:
        m=ready();m.set_command(buttons=buttons);m.observe();m.sample()
        m.u.mem_write(m.weapon+0xe4,floats(62));m.probability=0;m.hc_result=False
        assert m.fire() and m.hc_calls==1 and m.word(m.cmd+0x30)&buttons==buttons
        assert m.status()['manual_bypass']==1;cases+=1
    for defect in ['no_observation','no_sample','stale_command','foreign_candidate','nonfinite_eye','disabled','native_not_ready']:
        m=ready(guard=0 if defect=='disabled' else 1)
        if defect!='no_observation':m.observe()
        if defect!='no_sample':m.sample()
        m.u.mem_write(m.weapon+0xe4,floats(float('nan') if defect=='nonfinite_eye' else 62))
        if defect=='stale_command':m.store(m.cmd+4,101)
        if defect=='foreign_candidate':m.candidate+=0x1000
        m.probability=0;m.hc_result=False
        assert m.fire(allow=defect!='native_not_ready')==(defect!='native_not_ready');cases+=1
    for fault in ['heap','set']:
        m=FireMachine(fault);assert m.prepare();m.set_command();m.observe();m.sample()
        m.u.mem_write(m.weapon+0xe4,floats(62));m.probability=0;m.hc_result=False
        assert m.fire() and m.hc_calls==1;cases+=1
    for probability,expected in [(0,False),(.8,True)]:
        m=ready();m.store(m.weapon,0x800);m.observe();m.sample()
        m.u.mem_write(m.weapon+0xe4,floats(62));m.probability=probability;m.hc_result=expected
        assert m.fire()==expected and m.word(m.cmd+0x30)==(0x800 if expected else 0);cases+=1
    # Actual original HC fast path, including its huge aligned frame / RET 12.
    m=ready();m.fixture=False;m.store(m.weapon,0x4000);m.observe();m.sample()
    m.u.mem_write(m.weapon+0xe4,floats(62));assert m.fire() and m.hc_calls==2
    assert m.status()['probability']==1;cases+=1
    # Original missing-entity HC exit does not write probability. Fail open.
    m=ready();m.observe();m.sample();m.fixture=False
    m.u.mem_write(m.weapon+0xe4,floats(62));assert m.fire() and m.status()['fallback']==1;cases+=1
    recharge_cases=0
    for guard in ['cooldown','open_target','both','recent_shot','clear']:
        for unsafe in [False,True]:
            m=ready(recharge=int(unsafe));m.set_command(mode=1)
            if guard in ['cooldown','both']:m.u.mem_write(m.ctx+0x124,floats(.5))
            if guard in ['open_target','both']:m.store(0x434759c0,0x2008)
            if guard=='recent_shot':
                m.store(DATA+0x71000+0xc0,DATA+0x72024)
                m.u.mem_write(DATA+0x72000,bytes(0x24));m.store(DATA+0x72000,7)
                m.u.mem_write(DATA+0x72010,floats(1));m.u.mem_write(DATA+0x72020,floats(1))
            before=bytes(m.u.mem_read(m.ctx+0x124,4))
            expected=1 if unsafe or guard=='clear' else 0
            assert m.charge()==expected,(guard,unsafe,m.status())
            assert bytes(m.u.mem_read(m.ctx+0x124,4))==before,'cooldown state mutated'
            assert m.word(m.cmd+8)==(0x7f7fffff if expected else 12345)
            assert m.word(m.recharging)&255==expected
            assert m.word(m.cmd+0x30)==0;recharge_cases+=1
    # Native budget/completion sequence; subsequent commands stop at full charge.
    m=ready();m.store(0x434759c0,0x2008);m.u.mem_write(m.ctx+0x124,floats(.5))
    for n in range(16):
        m.set_command(100+n,1,min(n,14))
        assert m.charge()==min(n+1,14)
    assert m.word(m.ctx+0x11c)==114 and m.word(m.ctx+0x108)==113
    recharge_cases+=16
    # Native module notification receives the real command and saved player.
    m=ready();module=DATA+0x74000;vtable=DATA+0x74100;observed=DATA+0x74200
    m.store(module,vtable);m.store(vtable+4,STOP+0x400)
    m.store(DATA+0x70040,module);m.store(0x43475788,DATA+0x70044)
    m.u.mem_write(STOP+0x400,b'\x8b\x44\x24\x04\xa3'+words(observed)+b'\x89\x15'+words(observed+4)+b'\x89\x0d'+words(observed+8)+b'\xc2\x04\x00')
    m.store(0x434759c0,0x2008);assert m.charge()==1
    assert [m.word(observed+i*4) for i in range(3)]==[100,m.player,module]
    recharge_cases+=1
    # The original full-budget ring reconciliation still owns its corrections.
    m=ready();m.set_command(charge=14);m.store(DATA+0x70030,101)
    m.store(m.ctx+0x1c4,8);m.store(m.ctx+0x1c0,3)
    for i in range(8):m.store(m.ctx+0x1c8+i*4,5)
    assert m.charge()==6 and m.word(m.ctx+0x11c)==0x7fffffff
    assert m.status()['recharge_overrides']==0;recharge_cases+=1
    for mode,charged,flags,choke in [(0,0,0,0),(0,5,0,0),(2,0,0,0),(3,0,0,0),(1,0,8,0),(1,0,0,1)]:
        m=ready();m.set_command(mode=mode,charge=charged,flags=flags)
        m.store(DATA+0x70000,choke);m.store(0x434759c0,0x2008)
        m.u.mem_write(m.ctx+0x124,floats(.5));assert m.charge()==charged
        assert m.status()['recharge_overrides']==0;recharge_cases+=1
    # Attack rejection is also explicit in the override, after the native attack
    # gate (native throwable-type exceptions can reach this site).
    for buttons in [1,0x800,0x801]:
        m=ready();m.set_command(buttons=buttons);m.observe()
        m.native_frame();m.u.reg_write(UC_X86_REG_EBX,m.cmd)
        m.store(0x434759c0,0x2008)
        m.u.emu_start(REC,STOP,count=1000000)
        assert m.word(m.ctx+0x104)==0 and m.status()['recharge_overrides']==0
        assert m.word(m.cmd+0x30)==buttons;recharge_cases+=1
    # Each thread owns its observed command and HC context.
    m=ready();m.observe();m.sample();m.u.mem_write(m.weapon+0xe4,floats(62))
    m.thread=2;m.probability=0;m.hc_result=False
    assert m.fire() and m.hc_calls==1;cases+=1
    # VM preparation must not overwrite any of the native hook contracts.
    for group in json.loads((ROOT/'source/skeet/VM/bytecode.json').read_text()):
        for entry in [group['main'],*group['others']]:
            for a,b in SITES.items():assert entry['vip']+entry['size']<=a or entry['vip']>=a+len(b)
    report={'hook_abi_guards_release_and_failure_cases':cases,'native_recharge_cases':recharge_cases,
            'native_attack_commit_executed':True,'native_recharge_bookkeeping_executed':True,
            'native_hc_fast_and_missing_entity_paths_executed':True,'normal_hc_outcomes_controlled':True,
            'dt_key_release_and_pending_burst_exempt':True,'mode2_hook_bytes_unchanged':True,
            'full_nl_recharge_port':False,'gameplay_tested':False}
    (ROOT/'reports/v3_fire_validation.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report))

if __name__=='__main__':main()
