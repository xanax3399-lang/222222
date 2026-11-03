"""Independent geometric invariants plus compiled GS bridge and frozen v2 cases.
Head generator baseline is a fixture; native three-matrix intersection and
native primary-center consumer execute. No real visibility, damage or game test.
"""
import ctypes as C
import json,math,random
from validate_points_bridge import Machine,ROOT,words

def main():
    rng=random.Random(880203)
    lib=C.CDLL(str(ROOT/'build/v3_head_probe.so'));fn=lib.probe_v3_head
    fn.argtypes=[C.POINTER(C.c_float),C.c_uint,C.POINTER(C.c_float)];fn.restype=C.c_bool
    for i in range(1000):
        a=[rng.uniform(-1000,1000) for _ in range(3)]
        b=[a[k]+rng.uniform(-8,8) for k in range(3)] if i%3 else a[:]
        radius=rng.uniform(.5,8);eye=[rng.uniform(-1500,1500) for _ in range(3)]
        data=(C.c_float*10)(*a,*b,radius,*eye);out=(C.c_float*9)()
        assert fn(data,rng.choice([50,80,95,99]),out)
        a=list(data[:3]);b=list(data[3:6]);r=data[6]
        axis=[y-x for x,y in zip(a,b)];aa=sum(x*x for x in axis)
        for j in range(3):
            p=list(out[j*3:j*3+3]);t=sum((p[k]-a[k])*axis[k] for k in range(3))/aa if aa else 0
            t=min(1,max(0,t))
            distance=math.sqrt(sum((p[k]-(a[k]+t*axis[k]))**2 for k in range(3)))
            assert distance<=r+0.0003,(data[:],p,distance)
            assert p[2]>=max(a[2],b[2]),'Crown candidate was below the upper cap'
    invalid=0
    for i in range(10):
        for value in [float('nan'),float('inf'),-float('inf')]:
            data=(C.c_float*10)(0,0,60,0,0,65,4,-100,0,64);data[i]=value
            out=(C.c_float*9)(*([123]*9));assert not fn(data,95,out) and list(out)==[123]*9;invalid+=1
    for percent in [0,49,100,101]:
        data=(C.c_float*10)(0,0,60,0,0,65,4,-100,0,64);out=(C.c_float*9)(*([123]*9))
        assert not fn(data,percent,out) and list(out)==[123]*9;invalid+=1
    baseline=json.loads((ROOT/'tests/v2_points_baseline.json').read_text());v2_cases=0
    for case in baseline['fixtures']:
        m=Machine();assert m.prepare(2)
        m.u.mem_write(m.exports['skeet_nl_points_status']+40,words(case['reduced_head']))
        points,_=m.run(**case['input'])
        assert [list(p) for p in points]==case['points'],'Mode 2 diverged from frozen v2'
        assert struct_status(m)[4:]==(0,0,0,0,0,0,0)
        v2_cases+=1
    cases=0;added_total=0
    for pose_z in [0,-9,-18]:
        for reduced in [0,1]:
            old=Machine();assert old.prepare(2)
            old.u.mem_write(old.exports['skeet_nl_points_status']+40,words(reduced))
            before,_=old.run(pose_z=pose_z,consume=True)
            m=Machine();assert m.prepare(6)
            m.u.mem_write(m.exports['skeet_nl_points_status']+40,words(reduced))
            points,view=m.run(pose_z=pose_z,consume=True)
            assert points[:len(before)]==before and len(points)>len(before)
            assert view[2]-view[0]==13*24
            st=struct_status(m);assert st[4]==1 and st[5]==1 and st[6]==3 and st[7]>0
            added_total+=st[7]
            # Near-target cover-height toy slice: added samples reach above a
            # height between v2's highest sample and the crown. No game trace.
            wall=(max(p[2] for p in before)+max(p[2] for p in points))/2
            assert all(p[2]<wall for p in before) and any(p[2]>wall for p in points)
            cases+=1
    m=Machine();assert m.prepare(6);points,_=m.run(shift=50,consume=True)
    assert len(points)==2 and struct_status(m)[8]==3;cases+=1
    m=Machine();assert m.prepare(6);m.u.mem_write(m.exports['skeet_v3_status']+4,words(0))
    points,view=m.run(consume=True)
    assert [list(p) for p in points]==baseline['fixtures'][0]['points'] and view[2]-view[0]==10*24;cases+=1
    m=Machine();assert m.prepare(6);m.run(hitbox=3,consume=True);assert struct_status(m)[5]==0;cases+=1
    m=Machine();m.native_count=0;assert m.prepare(6);assert not m.run()[0];cases+=1
    m=Machine();m.native_count=3;assert m.prepare(6);points,_=m.run(consume=False)
    assert len(points)==13;cases+=1
    report={'geometric_invariant_cases':1000,'invalid_cases':invalid,'frozen_v2_regression_cases':v2_cases,
        'v3_bridge_cases':cases,'crown_points_committed_in_pose_cases':added_total,
        'pose_record_height_offsets':[0,-9,-18],'native_three_matrix_intersection_executed':True,
        'native_primary_center_consumer_executed':True,'native_head_generator_mocked':True,
        'cover_height_test_is_synthetic':True,'real_visibility_or_damage_tested':False,
        'interpolation_extrapolation_changed':False,'full_nl_stop_controller_ported':False,'gameplay_tested':False}
    (ROOT/'reports/v3_head_validation.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))

def struct_status(m):
    import struct
    return struct.unpack('<11I',m.u.mem_read(m.exports['skeet_v3_status'],44))

if __name__=='__main__':main()
