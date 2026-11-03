"""Compare reconstructed C++ head geometry with the original NL x86 routine.

NL's own intersection runs in the oracle. C++ uses an independent capsule
intersection. The scale helper is replaced by an explicit common input here;
scale recovery is validated separately. No game or loader is executed.
"""
import argparse
import ctypes as C
import json
from pathlib import Path
import random
import sys
import math

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'recovery'))
from native_points import NativePoints

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--donor',required=True)
    parser.add_argument('--cases',type=int,default=1000)
    args=parser.parse_args()
    oracle=NativePoints(args.donor)
    lib=C.CDLL(str(ROOT/'build/points_probe.so'))
    fn=lib.probe_points
    fn.argtypes=[C.POINTER(C.c_float),C.c_uint,C.c_uint,C.c_uint,C.POINTER(C.c_float)]
    fn.restype=C.c_int
    rng=random.Random(8802)
    maximum=0.0;tested=0;rejected=0;failures=[];body_cases=0
    for i in range(args.cases):
        a=tuple(rng.uniform(-100,100) for _ in range(3))
        axis=tuple(rng.uniform(-8,8) for _ in range(3))
        b=tuple(x+y for x,y in zip(a,axis));radius=rng.uniform(1,8)
        eye=tuple(rng.uniform(-800,800) for _ in range(3))
        scale=rng.choice([0,0.01,0.5,0.8,0.95,1]);reduced=bool(i%2)
        head=i%3!=0;hitbox=0 if head else rng.choice([3,4,5,6,7,8,9,10,11,12,15,16,17,18])
        data=(C.c_float*11)(*a,*b,radius,*eye,scale)
        output=(C.c_float*21)(*([12345]*21))
        count=fn(data,head,reduced,hitbox,output)
        if not count:rejected+=1;continue
        # Both implementations receive exactly the same float32 arguments.
        native=oracle.head(tuple(data[:3]),tuple(data[3:6]),data[6],tuple(data[7:10]),data[10],reduced,
                           body_hitbox=None if head else hitbox)
        body_cases+=not head
        assert len(native)==count,(i,len(native),count)
        error=max(abs(output[3*j+k]-native[j][k]) for j in range(count) for k in range(3))
        maximum=max(maximum,error);tested+=1
        if error>0.002:failures.append({'index':i,'error':error,'input':list(data),'cpp':list(output)[:3*count],'native':native})
    class ScaleInput(C.Structure):
        _fields_=[(x,C.c_float) for x in ['radius','distance','inaccuracy','spread','fallback_spread','max_scale']]+[('percent',C.c_int),('use_override_spread',C.c_bool),('override_spread',C.c_float)]
    sf=lib.probe_scale;sf.argtypes=[C.POINTER(ScaleInput),C.POINTER(C.c_float)];sf.restype=C.c_bool
    scale_error=0;fallback_calls=0
    for i in range(args.cases):
        radius=rng.choice([0,-1,rng.uniform(1,8)])
        inp=ScaleInput(radius,rng.uniform(0,2000),rng.uniform(0,0.025),rng.uniform(0,0.025),rng.uniform(0,0.01),rng.choice([.8,.9,.95]),rng.choice([0,1,25,50,80,100]),bool(i%2),rng.uniform(0,0.01))
        result=C.c_float(-999)
        assert sf(C.byref(inp),C.byref(result))
        native=oracle.scale(inp.radius,inp.distance,inp.inaccuracy,inp.spread,inp.percent,inp.max_scale,
                            inp.fallback_spread,inp.override_spread if inp.use_override_spread else None)
        fallback_calls+=oracle.fallback_calls
        error=abs(result.value-native);scale_error=max(scale_error,error)
        if error>2e-6:failures.append({'scale_index':i,'error':error,'cpp':result.value,'native':native})
    # Rejected/degenerate input must leave the caller's output untouched.
    invalid=0
    baseline=[0,0,60,0,0,65,4,-100,0,64,.8]
    for index in range(11):
        for value in [float('nan'),float('inf'),float('-inf')]:
            data=(C.c_float*11)(*baseline);data[index]=value
            out=(C.c_float*21)(*([12345]*21))
            assert fn(data,1,0,0,out)==0 and list(out)==[12345]*21
            invalid+=1
    for radius,scale in [(-1,.8),(0,.8),(4,-.01),(4,1.01)]:
        data=(C.c_float*11)(*baseline);data[6]=radius;data[10]=scale
        out=(C.c_float*21)(*([12345]*21))
        assert fn(data,1,0,0,out)==0 and list(out)==[12345]*21
        invalid+=1
    report={'head_cases':tested-body_cases,'body_cases':body_cases,'rejected':rejected,'max_coordinate_error':maximum,
            'tolerance_world_units':0.002,'failures':failures[:3],
            'geometry_scale_helper_overridden':True,'native_head_intersection':True,
            'body_client_intersection_replaced_with_nl_head_intersection':True,
            'scale_cases':args.cases,'max_scale_error':scale_error,'native_crt_sine_executed':True,
            'weapon_fallback_helper_calls_with_explicit_test_input':fallback_calls,
            'invalid_geometry_cases':invalid,
            'gs_runtime_integration_tested':False,'gameplay_tested':False}
    (ROOT/'reports/points_validation.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,ensure_ascii=False))
    if failures:raise SystemExit(1)

if __name__=='__main__':main()
