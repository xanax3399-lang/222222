"""Offline x86 oracle for the supplied CS:GO NL image. Never runs DllMain.

Geometry-only mode replaces the scale helper with an explicit float input;
the native capsule intersection and native point generator execute unmodified.
This does not establish compatibility with the GameSense caller.
"""
from pathlib import Path
import hashlib
import json
import math
import struct
from unicorn import Uc, UC_ARCH_X86, UC_MODE_32, UC_HOOK_CODE
from unicorn.x86_const import *

BASE, DATA, STACK, STOP = 0x412a0000, 0x20000000, 0x30000000, 0x50000000
SHA = '682ce73b371349f87da6fd9365f8550e240dcdb97951e80445e70286275ad96e'
def pack(*v): return struct.pack('<'+'f'*len(v), *v)
def words(*v): return struct.pack('<'+'I'*len(v), *v)

class NativePoints:
    def __init__(self, path):
        image = Path(path).read_bytes()
        if hashlib.sha256(image).hexdigest() != SHA:
            raise ValueError('Unsupported NL donor image')
        self.uc = u = Uc(UC_ARCH_X86, UC_MODE_32)
        for base, size in [(BASE,len(image)),(DATA,0x100000),(STACK,0x20000),(STOP,0x1000)]:
            u.mem_map(base, (size+4095)&-4096)
        u.mem_write(BASE,image)
        # Existing wrapper's flow/NOP normalization, without its game startup.
        patches=json.loads(Path(__file__).with_name('nl_geometry_patches.json').read_text())
        for patch in patches['patches']:
            address=int(patch['address'],16);before=bytes.fromhex(patch['before'])
            if bytes(u.mem_read(address,len(before)))!=before:
                raise ValueError('Normalization precondition failed')
            u.mem_write(address,bytes.fromhex(patch['after']))
        self.image=image
        self.capsule_uc=None
        for address in (0x1331e88d,0x977f4f15,0xb35c1b6c):
            u.mem_map(address&-4096,4096);u.mem_write(address,b'\xc3')
        u.mem_write(0x424f639c, words(DATA))
        u.mem_write(DATA+0x5d64, words(DATA+0x30000))
        u.mem_write(DATA+0x30000+0x2cc, words(0))
        u.mem_write(DATA+0x605c, words(63))
        u.mem_write(DATA+0x6164, words(80))
        u.mem_write(DATA+0x627c, words(80))
        u.mem_write(0x424b040c, words(DATA+0x50000))
        u.mem_write(STOP+0x100,b'\xd9\x05'+words(DATA+0x70000)+b'\xc3')
        u.hook_add(UC_HOOK_CODE,self.runtime)
        self.scale_override = None
        self.intersections = []
        self.fallback_spread=0.0
        self.fallback_calls=0

    def fraction(self,capsule,start,delta):
        if self.capsule_uc is None:
            self.capsule_uc=u=Uc(UC_ARCH_X86,UC_MODE_32)
            for base,size in [(BASE,len(self.image)),(DATA,0x10000),(STACK,0x10000),(STOP,0x1000)]:
                u.mem_map(base,(size+4095)&-4096)
            u.mem_write(BASE,self.image)
        u=self.capsule_uc
        u.mem_write(DATA,pack(1)+bytes(28));u.mem_write(DATA+0x100,pack(*start))
        u.mem_write(DATA+0x200,pack(*delta));u.mem_write(DATA+0x300,pack(*capsule[:6]))
        sp=STACK+0x8000
        u.mem_write(sp,words(STOP,DATA,DATA+0x100,DATA+0x200,DATA+0x300)+pack(capsule[6]))
        u.reg_write(UC_X86_REG_ESP,sp);u.reg_write(UC_X86_REG_FPCW,0x37f)
        u.reg_write(UC_X86_REG_MXCSR,0x1f80)
        u.emu_start(0x4149f0b0,STOP,count=50000)
        if u.reg_read(UC_X86_REG_EIP)!=STOP:raise RuntimeError('Capsule instruction budget exhausted')
        return struct.unpack('<f',u.mem_read(DATA,4))[0]

    def runtime(self,u,address,size,_):
        if address == 0x4149f0b0:
            sp=u.reg_read(UC_X86_REG_ESP)
            out,start,delta,bounds,r=struct.unpack('<IIIIf',u.mem_read(sp+4,20))
            self.intersections.append((struct.unpack('<3f',u.mem_read(start,12)),
                                       struct.unpack('<3f',u.mem_read(delta,12))))
        if address == 0x41da7c5c:
            sp=u.reg_read(UC_X86_REG_ESP)
            u.reg_write(UC_X86_REG_EIP,struct.unpack('<I',u.mem_read(sp,4))[0])
            u.reg_write(UC_X86_REG_ESP,sp+4)
        elif address == 0x4149ed20 and self.scale_override is not None:
            u.mem_write(DATA+0x70000,pack(self.scale_override))
            u.reg_write(UC_X86_REG_EIP,STOP+0x100)
        elif address == 0x412c0bf0:
            self.fallback_calls+=1
            u.mem_write(DATA+0x70000,pack(self.fallback_spread))
            u.reg_write(UC_X86_REG_EIP,STOP+0x100)
        elif address in (0x1331e88d,0x977f4f15,0xb35c1b6c):
            sp=u.reg_read(UC_X86_REG_ESP)
            ret,delta,bounds,r=struct.unpack('<IIIf',u.mem_read(sp,16))
            out=u.reg_read(UC_X86_REG_ECX);start_address=u.reg_read(UC_X86_REG_EDX)
            start=struct.unpack('<3f',u.mem_read(start_address,12));d=struct.unpack('<3f',u.mem_read(delta,12))
            capsule=struct.unpack('<6f',u.mem_read(bounds,24))+(r,)
            t=self.fraction(capsule,start,d)
            position=tuple(x+y*t for x,y in zip(start,d))
            u.mem_write(out,pack(t,*position))
            # This donor call site uses register arguments plus caller-owned
            # stack slots. Its callee must leave the three stack arguments.
            u.reg_write(UC_X86_REG_ESP,sp+4);u.reg_write(UC_X86_REG_EIP,ret)
            u.reg_write(UC_X86_REG_EAX,1)

    def scale(self,radius,distance,inaccuracy,spread,percent,max_scale,
              fallback_spread=0.0,override_spread=None):
        u=self.uc;box=DATA+0x40000;eye=DATA+0x48000
        self.scale_override=None;self.fallback_spread=fallback_spread;self.fallback_calls=0
        u.mem_write(box,bytes(0x80));u.mem_write(box+0x48,pack(radius))
        u.mem_write(eye,pack(-distance,0,0))
        u.mem_write(DATA+0x6164,words(percent&0xffffffff))
        u.mem_write(DATA+0x50000+0xe4,pack(inaccuracy,spread))
        u.mem_write(0x42505215,b'\0')
        u.mem_write(0x4250527c,words(int(override_spread is not None)))
        u.mem_write(0x42505280,pack(override_spread or 0.0))
        sp=STACK+0x18000
        # FSTP result at the stop stub, preserving the caller's native x87 return.
        u.mem_write(STOP+0x200,b'\xd9\x1d'+words(DATA+0x71000))
        u.mem_write(sp,words(STOP+0x200,box,eye)+pack(max_scale))
        u.reg_write(UC_X86_REG_ESP,sp);u.reg_write(UC_X86_REG_FPCW,0x37f)
        u.reg_write(UC_X86_REG_MXCSR,0x1f80)
        u.emu_start(0x4149ed20,STOP+0x206,count=200000)
        if u.reg_read(UC_X86_REG_EIP)!=STOP+0x206:raise RuntimeError('Scale instruction budget exhausted')
        return struct.unpack('<f',u.mem_read(DATA+0x71000,4))[0]
    def head(self,a,b,radius,eye,scale=0.8,reduced=False,body_hitbox=None):
        u=self.uc; hitbox=DATA+0x40000; record=DATA+0x41000; context=DATA+0x42000
        vec=DATA+0x43000; points=DATA+0x44000; origin=DATA+0x48000
        u.mem_write(hitbox,bytes(0x90));u.mem_write(hitbox+0x30,pack(*a,*b,radius)+words(body_hitbox or 0))
        u.mem_write(record,bytes(0x100));u.mem_write(record+0xa5,b'\1')
        u.mem_write(context,words(0,record));u.mem_write(origin,pack(*eye))
        u.mem_write(vec,words(points,points,points+80*32));u.mem_write(points,bytes(80*32))
        self.scale_override=scale;self.intersections=[]
        sp=STACK+0x18000
        u.mem_write(sp,words(STOP,hitbox,context,vec,origin,int(reduced)))
        u.reg_write(UC_X86_REG_ESP,sp);u.reg_write(UC_X86_REG_FPCW,0x37f)
        u.reg_write(UC_X86_REG_MXCSR,0x1f80)
        u.emu_start(0x414ac630 if body_hitbox is None else 0x41490fa0,STOP,count=200000)
        if u.reg_read(UC_X86_REG_EIP)!=STOP:raise RuntimeError('Instruction budget exhausted')
        end=struct.unpack('<I',u.mem_read(vec+4,4))[0]
        return [struct.unpack('<3f',u.mem_read(p,12)) for p in range(points,end,80)]

if __name__=='__main__':
    import sys,json
    oracle=NativePoints(sys.argv[1])
    result=oracle.head((0,0,60),(0,0,65),4,(-100,0,64))
    print(json.dumps({'points':result,'capsule_rays':oracle.intersections},indent=2))
