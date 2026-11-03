#!/usr/bin/env python3
"""Steam text fixtures and bounded native launcher API/cleanup fixtures.
CreateProcess/ResumeThread are mocked. No game, Steam or uploaded EXE runs.
"""
from pathlib import Path
import subprocess,os,sys,struct,json,hashlib
import pefile
from unicorn import Uc,UC_ARCH_X86,UC_MODE_32,UC_HOOK_CODE
from unicorn.x86_const import *
ROOT=Path(__file__).resolve().parents[1];B=ROOT/'build'
subprocess.run(['g++','-std=c++17','-O2',str(ROOT/'tests/launcher_policy.cpp'),'-o',str(B/'launcher_policy')],check=True)
portable=subprocess.check_output([str(B/'launcher_policy')],text=True).strip()
env=os.environ.copy();env.setdefault('ZIG_GLOBAL_CACHE_DIR','/workspace/skeet-motion-bt-8802/.cache/global')
subprocess.run([sys.executable,'-m','ziglang','c++','-target','x86-windows-gnu','-std=c++23','-O2','-shared','-Wl,--image-base,0x30000000',str(ROOT/'tests/launcher_probe.cpp'),'-o',str(B/'launcher_probe.dll')],env=env,check=True)
pe=pefile.PE(str(B/'launcher_probe.dll'));pb=pe.OPTIONAL_HEADER.ImageBase
entry=next(pb+s.address for s in pe.DIRECTORY_ENTRY_EXPORT.symbols if s.name and b'launch_probe' in s.name)
checks=0
for create_ok,explicit,resume_fail in [(True,False,False),(True,True,False),(False,False,False),(False,True,False),(True,True,True)]:
    u=Uc(UC_ARCH_X86,UC_MODE_32);u.mem_map(pb,pe.OPTIONAL_HEADER.SizeOfImage);u.mem_write(pb,pe.get_memory_mapped_image());u.mem_map(0x100000,0x100000)
    def word(a):return struct.unpack('<I',u.mem_read(a,4))[0]
    def store(a,v):u.mem_write(a,struct.pack('<I',v&0xffffffff))
    def wide(a):
        data=bytearray()
        while True:
            ch=bytes(u.mem_read(a+len(data),2))
            if ch==b'\0\0':return data.decode('utf-16le')
            data.extend(ch)
    imports={}
    for lib in pe.DIRECTORY_ENTRY_IMPORT:
        for item in lib.imports:
            a=0x101000+len(imports)*16;store(item.address,a);imports[a]=item.name.decode() if item.name else str(item.ordinal)
    heap=[0x130000];events=[];resume=[0]
    original='PATH=C:\\Windows\0SteamAppId=123\0SteamGameId=456\0=C:=C:\\Steam\0\0'
    u.mem_write(0x110000,original.encode('utf-16le'));u.mem_write(0x112000,'C:\\Steam\\csgo.exe\0'.encode('utf-16le'))
    def hook(u,a,size,user):
        if a==0x100000:u.emu_stop();return
        if a not in imports:return
        sp=u.reg_read(UC_X86_REG_ESP);ret=word(sp);name=imports[a];cleanup=4;result=0
        if name in ['malloc','calloc','realloc']:
            n=word(sp+4)
            if name=='calloc':n*=word(sp+8)
            if name=='realloc':n=word(sp+8)
            result=heap[0];heap[0]+=(n+31)&~15;assert heap[0]<0x1c0000
            if name=='realloc' and word(sp+4):u.mem_write(result,bytes(u.mem_read(word(sp+4),min(n,512))))
        elif name in ['free']:pass
        elif name in ['memcpy','memmove']:
            dst,src,n=[word(sp+i) for i in [4,8,12]];u.mem_write(dst,bytes(u.mem_read(src,n)));result=dst
        elif name=='memset':
            dst,v,n=[word(sp+i) for i in [4,8,12]];u.mem_write(dst,bytes([v&255])*n);result=dst
        elif name=='wcslen':result=len(wide(word(sp+4)))
        elif name=='towlower':result=ord(chr(word(sp+4)).lower())
        elif name=='GetEnvironmentStringsW':result=0x110000
        elif name=='FreeEnvironmentStringsW':assert word(sp+4)==0x110000;result=1;cleanup=8
        elif name=='CreateProcessW':
            app,cmd,pa,ta,inherit,flags,environment,cwd,si,pi=[word(sp+i*4) for i in range(1,11)]
            assert wide(app)=='C:\\Steam\\csgo.exe' and wide(cmd)=='"C:\\Steam\\csgo.exe" -steam -insecure -console'
            assert not pa and not ta and not inherit and flags==0x404 and wide(cwd)=='C:\\Steam'
            entries=[];p=environment
            while word(p)&65535:
                v=wide(p);entries.append(v);p+=(len(v)+1)*2
            assert 'SteamAppId=730' in entries and 'SteamGameId=730' in entries
            assert 'PATH=C:\\Windows' in entries and '=C:=C:\\Steam' in entries
            assert not any(e in entries for e in ['SteamAppId=123','SteamGameId=456'])
            assert word(si)==68
            if create_ok:u.mem_write(pi,struct.pack('<IIII',0x900,0x901,999,777))
            events.append('create');result=int(create_ok);cleanup=44
        elif name=='ResumeThread':
            assert word(sp+4)==0x901;resume[0]+=1;result=0xffffffff if resume_fail and resume[0]==1 else 1;events.append('resume');cleanup=8
        elif name=='CloseHandle':events.append(('close',word(sp+4)));result=1;cleanup=8
        else:raise AssertionError(('unexpected import',name,hex(a)))
        u.reg_write(UC_X86_REG_EAX,result);u.reg_write(UC_X86_REG_ESP,sp+cleanup);u.reg_write(UC_X86_REG_EIP,ret)
    u.hook_add(UC_HOOK_CODE,hook)
    sp=0x1f0000
    for i,v in enumerate([0x100000,0x112000,int(explicit)]):store(sp+i*4,v)
    u.reg_write(UC_X86_REG_ESP,sp);u.emu_start(entry,0x100001,count=2000000)
    assert u.reg_read(UC_X86_REG_EIP)==0x100000
    assert u.reg_read(UC_X86_REG_EAX)==(1 if create_ok and resume_fail else (999 if create_ok else 0))
    assert resume[0]==(2 if create_ok and resume_fail else int(create_ok))
    assert events.count(('close',0x901))==int(create_ok) and events.count(('close',0x900))==int(create_ok)
    assert bytes(u.mem_read(0x110000,len(original)*2))==original.encode('utf-16le');checks+=1
report={'passed':True,'portable_policy_result':portable,'native_launch_and_cleanup_cases':checks,'starts_only_csgo_exe_pe32':True,'steam_library_manifest_discovery':True,'child_only_steam_app_ids':730,'startup_flags':['-steam','-insecure','-console'],'reserve_before_resume':True,'startup_module_timeout_seconds':120,'mocked_apis':['CreateProcessW','ResumeThread','environment','heap'],'game_or_steam_executed':False,'windows_loader_tested':False,'scope':__doc__}
(B/'launcher_validation.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
