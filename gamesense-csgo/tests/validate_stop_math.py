"""Compare recovery-only C++ against original CS:GO NL arithmetic instructions.

Executes bounded blocks, not the whole movement function. ConVar results, warm
TLS and player state are explicit fixtures. No game, injection or DllMain.
"""
import argparse
import ctypes as C
import hashlib
import json
import math
from pathlib import Path
import random
import struct

from unicorn import Uc, UC_ARCH_X86, UC_MODE_32, UC_HOOK_CODE
from unicorn.x86_const import (UC_X86_REG_EBP, UC_X86_REG_EBX, UC_X86_REG_ESP,
                              UC_X86_REG_EIP, UC_X86_REG_XMM3, UC_X86_REG_XMM4,
                              UC_X86_REG_MXCSR)

ROOT = Path(__file__).resolve().parents[1]
BASE, DATA, STACK = 0x412a0000, 0x20000000, 0x30000000
SHA = '682ce73b371349f87da6fd9365f8550e240dcdb97951e80445e70286275ad96e'

def floats(*v): return struct.pack('<' + 'f' * len(v), *v)
def words(*v): return struct.pack('<' + 'I' * len(v), *v)
def xmm(*v): return int.from_bytes(floats(*v, *([0.0] * (4-len(v)))), 'little')
def lane(u, reg, index=0):
    return struct.unpack('<4f', u.reg_read(reg).to_bytes(16, 'little'))[index]

class NativeBlocks:
    def __init__(self, path):
        image = Path(path).read_bytes()
        if hashlib.sha256(image).hexdigest() != SHA:
            raise ValueError('Unsupported CS:GO NL donor')
        self.u = u = Uc(UC_ARCH_X86, UC_MODE_32)
        for base, size in [(BASE,len(image)),(DATA,0x10000),(STACK,0x10000),(0,0x1000)]:
            u.mem_map(base, (size+4095)&-4096)
        u.mem_write(BASE, image)  # No instruction patches or normalization.
        self.frame = STACK + 0x8000
        u.reg_write(UC_X86_REG_EBP, self.frame)
        u.reg_write(UC_X86_REG_ESP, STACK+0x6000)
        u.reg_write(UC_X86_REG_EBX, DATA+0x4000)
        u.reg_write(UC_X86_REG_MXCSR, 0x1f80)
        u.mem_write(0x4223ca04, words(DATA))
        u.mem_write(0x424b040c, words(DATA+0x1000))
        # Fixtures for the one warm-static-cache read in the brake block.
        u.mem_write(0x2c, words(DATA+0x2000))
        u.mem_write(0x42518540, words(0))
        u.mem_write(DATA+0x2000, words(DATA+0x3000))
        u.mem_write(DATA+0x3008, words(0x7fffffff))
        u.mem_write(0x424afd68, words(DATA+0x5000))
        u.mem_write(DATA+0x5000, words(0))
        u.mem_write(0x424f6398, words(DATA+0x6000))
        self.ends = set()
        u.hook_add(UC_HOOK_CODE, self.guard)

    def guard(self, u, address, size, _):
        if address in self.ends:
            u.emu_stop()
        elif not (0x414a09b7 <= address < 0x414a09c6 or
                  0x414a0a6a <= address < 0x414a0abe or
                  0x414a0d43 <= address < 0x414a0e1d or
                  0x414a1094 <= address < 0x414a10e8):
            raise RuntimeError(f'Unexpected native block at {address:#x}')

    def run(self, start, *ends):
        self.ends = set(ends)
        self.u.emu_start(start, 0xffffffff, count=500)
        if self.u.reg_read(UC_X86_REG_EIP) not in self.ends:
            raise RuntimeError('Native block instruction budget exceeded')

    def friction(self, data):
        u = self.u
        x,y,speed,stop,friction,interval,surface = data
        u.mem_write(self.frame-0x80, floats(stop))
        u.mem_write(self.frame-0x34, floats(speed))
        u.mem_write(self.frame-0x7c, floats(friction))
        u.mem_write(self.frame-0x50, floats(x,y,0,0))
        u.mem_write(self.frame-0x20, floats(0))
        u.mem_write(DATA+0x20, floats(interval))
        u.mem_write(DATA+0x1238, floats(surface))
        u.reg_write(UC_X86_REG_XMM4, xmm(x,y))
        self.run(0x414a09b7, 0x414a09c6)
        self.run(0x414a0a6a, 0x414a0abe, 0x414a0e20)
        return [lane(u,UC_X86_REG_XMM4),lane(u,UC_X86_REG_XMM4,1),lane(u,UC_X86_REG_XMM3)]

    def brake(self, data, grounded):
        u = self.u
        forward,side,speed,max_speed,accelerate,interval,surface = data
        # This multiply occurs at 414A0B70..414A0B78 before block entry.
        surface_tick = C.c_float(surface*interval).value
        for offset,value in [(0x50,surface_tick),(0x68,accelerate),(0x58,max_speed),
                             (0x34,speed),(0x54,side),(0x20,forward)]:
            u.mem_write(self.frame-offset, floats(value))
        u.mem_write(DATA+0x6000, bytes([int(grounded)]))
        self.run(0x414a0d43, 0x414a10e8)
        return struct.unpack('<2f',u.mem_read(DATA+0x4000,8))

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--donor',required=True)
    args=parser.parse_args()
    oracle=NativeBlocks(args.donor)
    lib=C.CDLL(str(ROOT/'build/stop_math_probe.so'))
    friction=lib.probe_stop_friction
    friction.argtypes=[C.POINTER(C.c_float),C.POINTER(C.c_float)]
    friction.restype=C.c_bool
    brake=lib.probe_stop_brake
    brake.argtypes=[C.POINTER(C.c_float),C.c_bool,C.POINTER(C.c_float)]
    brake.restype=C.c_bool
    rng=random.Random(880203)
    friction_cases=[];brake_cases=[]
    # Rest, no-friction, full stop, below/above sv_stopspeed and small intervals.
    for speed in [0,-0.0,.001,.1,1,79.99,80,80.01,250,450]:
        for surface in [0,.1,1,2]:
            friction_cases.append([speed,0,speed,80,5.2,1/64,surface])
    for i in range(1000):
        speed=rng.uniform(.01,500);angle=rng.uniform(-math.pi,math.pi)
        friction_cases.append([speed*math.cos(angle),speed*math.sin(angle),speed,
                               rng.uniform(0,120),rng.uniform(0,10),
                               rng.choice([1/64,1/128,1/1000]),rng.uniform(0,2)])
        brake_cases.append(([math.cos(angle),math.sin(angle),speed,rng.uniform(1,500),
                             rng.uniform(0,20),rng.choice([1/64,1/128]),rng.uniform(0,2)],bool(i%2)))
    # Cross available-acceleration threshold 1, zero acceleration and axis clamps.
    for grounded in [False,True]:
        for speed in [0,.001,1,2.9062495,2.90625,2.9062505,40,250]:
            for accelerate in [0,1,5.5,100]:
                for direction in [(1,0),(0,1),(-1,-1),(2,-2)]:
                    brake_cases.append(([*direction,speed,250,accelerate,1/64,1],grounded))
    exact=0;maximum=0.0
    for values in friction_cases:
        data=(C.c_float*7)(*values);out=(C.c_float*3)()
        assert friction(data,out)
        native=oracle.friction(list(data))
        error=max(abs(a-b) for a,b in zip(out,native));maximum=max(maximum,error)
        assert floats(*out)==floats(*native),('friction',list(data),list(out),native)
        exact+=1
    for values,grounded in brake_cases:
        data=(C.c_float*7)(*values);out=(C.c_float*2)()
        assert brake(data,grounded,out)
        native=oracle.brake(list(data),grounded)
        error=max(abs(a-b) for a,b in zip(out,native));maximum=max(maximum,error)
        assert floats(*out)==floats(*native),('brake',list(data),grounded,list(out),native)
        exact+=1
    invalid=0
    for index in range(7):
        for value in [float('nan'),float('inf'),-float('inf')]:
            for fn in [friction,brake]:
                data=(C.c_float*7)(1,0,100,250,5.5,1/64,1);data[index]=value
                out=(C.c_float*3)(123,456,789)
                ok=fn(data,out) if fn==friction else fn(data,True,out)
                assert not ok and list(out)==[123,456,789]
                invalid+=1
    report={
        'donor_sha256':SHA,'friction_cases':len(friction_cases),'brake_cases':len(brake_cases),
        'bitwise_equal_cases':exact,'maximum_error':maximum,'invalid_cases':invalid,
        'native_instruction_bytes_modified':False,'scope':'arithmetic blocks with explicit inputs',
        'convar_reads_and_tls_initialization_executed':False,
        'direction_trigonometry_executed':False,'stop_eligibility_or_timing_recovered':False,
        'gs_adapter_installed':False,'gameplay_tested':False}
    (ROOT/'reports/stop_math_validation.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report))

if __name__=='__main__':main()
