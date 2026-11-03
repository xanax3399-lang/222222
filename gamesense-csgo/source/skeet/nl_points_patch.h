#pragma once
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <windows.h>
#include <intrin.h>
#include <new>
#include <cstring>
#include "nl_points.h"
#include "core_image.h"
#include "nl_hypotheses.h"
#include "nl_points_status.h"
#include "nl_points_mean.h"
extern "C" __declspec(dllexport) nl_points_patch::Status skeet_nl_points_status;

namespace nl_points_patch {
using nl_points::Vec3;
using nl_points::Capsule;
struct NativePoint { Vec3 position;float weight;unsigned group,flags; };
static_assert(sizeof(NativePoint)==0x18);
struct NativeVector { NativePoint *begin,*end,*capacity;unsigned reserved;NativePoint in_place[3]; };
static_assert(sizeof(void*)!=4||sizeof(NativeVector)==0x58);
struct Slot { NativeVector* owner{};unsigned caller{};NativePoint points[10]{};Vec3 native_mean{}; };
struct MainSlot { NativeVector* owner{};NativePoint points[256]{}; };
struct Pool { Slot slots[8]{};MainSlot main[8]{}; };
inline DWORD pool_key=FLS_OUT_OF_INDEXES;
inline const char* install_error="NL points setup did not finish.";
inline bool enabled(){return (nl_hypotheses::selected_mode&2u)!=0;}
inline const char* last_error(){return install_error;}
}

namespace nl_points_patch {
// Same register/stack ABI as the original custom GS intersection: ECX result,
// EDX ray origin, XMM0 radius, two stack arguments; callee removes eight bytes.
// Native result is fraction, hit position, normal (seven floats).
__declspec(naked) inline void __cdecl native_intersection(float*,const Vec3*,const Vec3*,const Capsule*) {
    __asm {
        push ebp
        mov ebp,esp
        mov eax,[ebp+20]
        push eax
        push dword ptr [ebp+16]
        movss xmm0,dword ptr [eax+24]
        mov ecx,[ebp+8]
        mov edx,[ebp+12]
        mov eax,0x43418772
        call eax
        mov esp,ebp
        pop ebp
        ret
    }
}
inline Vec3 transform(const float* m,Vec3 p) {
    return {m[0]*p.x+m[1]*p.y+m[2]*p.z+m[3],
            m[4]*p.x+m[5]*p.y+m[6]*p.z+m[7],
            m[8]*p.x+m[9]*p.y+m[10]*p.z+m[11]};
}
template<class T> inline T read(const void* p,unsigned off) {
    T out;std::memcpy(&out,static_cast<const unsigned char*>(p)+off,sizeof(out));return out;
}
inline bool input_capsules(const void* records,const void* descriptor,const Vec3& middle,
                           Capsule& main,Capsule (&alternatives)[3],unsigned& id,unsigned& group) {
    id=read<unsigned>(descriptor,0);const void* box=read<void*>(descriptor,4);
    if(id>18||!box)return false;
    group=read<unsigned>(box,4);
    if(group<1||group>7)return false;
    main={read<Vec3>(descriptor,0x48),read<Vec3>(descriptor,0x54),read<float>(descriptor,0x70)};
    if(!nl_points::finite(main.a)||!nl_points::finite(main.b)||!std::isfinite(main.radius)||
       main.radius<=0||main.radius>64||!nl_points::finite(middle))return false;
    if(nl_points::length(middle-(main.a+main.b)*.5f)>.1f)return false;
    const Vec3 local_a=read<Vec3>(box,8),local_b=read<Vec3>(box,0x14);
    const float radius=read<float>(box,0x30);
    if(!nl_points::finite(local_a)||!nl_points::finite(local_b)||radius<=0||
       !std::isfinite(radius)||std::fabs(radius-main.radius)>.001f)return false;
    for(unsigned i=0;i<3;++i) {
        // GS stores transformed hitbox matrices indexed by HITBOX, not bone.
        const auto* matrix=reinterpret_cast<const float*>(static_cast<const unsigned char*>(records)+
                                                          (id+31)*0x30+i*0x3a0);
        for(unsigned j=0;j<12;++j)if(!std::isfinite(matrix[j]))return false;
        alternatives[i]={transform(matrix,local_a),transform(matrix,local_b),radius};
        if(!nl_points::finite(alternatives[i].a)||!nl_points::finite(alternatives[i].b))return false;
    }
    return true;
}
inline void NTAPI release_pool(void* pool){if(pool)HeapFree(GetProcessHeap(),0,pool);}
inline Pool* acquire_pool() {
    if(pool_key==FLS_OUT_OF_INDEXES)return nullptr;
    auto* pool=static_cast<Pool*>(FlsGetValue(pool_key));
    if(!pool) {
        void* allocation=HeapAlloc(GetProcessHeap(),HEAP_ZERO_MEMORY,sizeof(Pool));
        if(!allocation)return nullptr;
        pool=new(allocation) Pool{};
        if(!FlsSetValue(pool_key,pool)){release_pool(pool);return nullptr;}
    }
    return pool;
}
inline Slot* acquire(Pool& pool,NativeVector* owner,unsigned caller) {
    for(auto& slot:pool.slots)if(slot.owner==owner&&slot.caller==caller)return &slot;
    for(auto& slot:pool.slots)if(!slot.owner){slot.owner=owner;slot.caller=caller;return &slot;}
    return nullptr;
}
inline MainSlot* main_storage(Pool& pool,NativeVector* owner) {
    for(auto& slot:pool.main)if(slot.owner==owner)return &slot;
    for(auto& slot:pool.main)if(!slot.owner){slot.owner=owner;return &slot;}
    return nullptr;
}
using Generator=void(__fastcall*)(const Vec3*,void*,const void*,const void*,const Vec3*,NativeVector*,unsigned);
inline void original(const Vec3* eye,void* entity,const void* records,const void* descriptor,
                     const Vec3* middle,NativeVector* out,unsigned special) {
    reinterpret_cast<Generator>(0x433fd9b7)(eye,entity,records,descriptor,middle,out,special);
}
__declspec(noinline) inline void __fastcall bridge(const Vec3* eye,void* entity,const void* records,
               const void* descriptor,const Vec3* middle,NativeVector* out,unsigned special) {
    auto& status=skeet_nl_points_status;
    InterlockedIncrement(&status.calls);
    const unsigned caller=reinterpret_cast<unsigned>(_ReturnAddress());
    // Preserve the native result before considering any experimental additions.
    original(eye,entity,records,descriptor,middle,out,special);
    InterlockedIncrement(&status.native_calls);
    const auto fallback=[&] {InterlockedIncrement(&status.fallback);};
    // Special native branch has additional entity/pose semantics, left native.
    if(!enabled()||caller!=0x4335e9d5||special||!eye||!records||
       !descriptor||!middle||!out||!nl_points::finite(*eye)||
       out->begin!=out->in_place||out->end<out->begin||out->end>out->in_place+3||out->capacity!=out->in_place+3) {
        fallback();return;
    }
    const unsigned native_count=static_cast<unsigned>(out->end-out->begin);
    InterlockedExchange(&status.last_original,static_cast<LONG>(native_count));
    InterlockedExchange(&status.last_added,0);
    InterlockedExchangeAdd(&status.kept,static_cast<LONG>(native_count));
    if(!native_count){fallback();return;}
    NativePoint baseline[3]{};
    std::memcpy(baseline,out->begin,native_count*sizeof(NativePoint));
    const Vec3 origin=read<Vec3>(records,0x30);Vec3 sum{};
    if(!nl_points::finite(origin)){fallback();return;}
    for(unsigned i=0;i<native_count;++i) {
        if(!nl_points::finite(baseline[i].position)){fallback();return;}
        sum=sum+(baseline[i].position-origin);
    }
    const Vec3 native_mean=sum*(1.0f/static_cast<float>(native_count))+origin;
    Capsule main{},alternatives[3]{};unsigned id=0,group=0;
    if(!input_capsules(records,descriptor,*middle,main,alternatives,id,group)){fallback();return;}
    InterlockedExchange(&status.last_hitbox,static_cast<LONG>(id));
    if(id==0)InterlockedExchangeAdd(&status.head_kept,static_cast<LONG>(native_count));
    // NL's native multipoint mask has no body branch for neck/pelvis/hands.
    if(id!=0&&id!=3&&!(id>=4&&id<=12)&&!(id>=15&&id<=18)){fallback();return;}
    nl_points::Points points{};
    const unsigned percentage=id==0?status.head_percent:status.body_percent;
    if(percentage>100||!nl_points::generate(main,*eye,percentage*.01f,id==0,
                    status.reduced_head!=0,id,points)){fallback();return;}
    NativePoint accepted[10]{};unsigned count=native_count,filtered=0;
    std::memcpy(accepted,baseline,native_count*sizeof(NativePoint));
    for(unsigned i=0;i<points.count;++i) {
        const Vec3 delta=points.positions[i]-*eye;bool safe=true;
        for(const auto& capsule:alternatives) {
            float hit[8]{};hit[0]=std::numeric_limits<float>::max();
            native_intersection(hit,eye,&delta,&capsule);
            if(!std::isfinite(hit[0])||hit[0]<0||hit[0]>1){safe=false;break;}
        }
        if(!safe){++filtered;continue;}
        bool duplicate=false;
        for(unsigned j=0;j<count;++j) {
            const Vec3 difference=accepted[j].position-points.positions[i];
            if(nl_points::dot(difference,difference)<1e-8f){duplicate=true;break;}
        }
        if(!duplicate)accepted[count++]={points.positions[i],1.0f,group,3};
    }
    InterlockedExchangeAdd(&status.filtered,static_cast<LONG>(filtered));
    const unsigned added=count-native_count;
    if(!added){InterlockedIncrement(&status.empty_fallback);fallback();return;}
    auto* pool=acquire_pool();
    auto* storage=pool?acquire(*pool,out,caller):nullptr;
    // The verified caller owns a second, initially 112-element list. Redirect
    // it too: extra multipoints must never overrun its unchecked append loop.
    auto* candidates=reinterpret_cast<NativeVector*>(reinterpret_cast<unsigned char*>(out)+0xfe4);
    auto* destination=pool?main_storage(*pool,candidates):nullptr;
    if(!storage||!destination){InterlockedIncrement(&status.pool_full);fallback();return;}
    const auto first=reinterpret_cast<std::uintptr_t>(candidates->begin);
    const auto last=reinterpret_cast<std::uintptr_t>(candidates->end);
    const auto limit=reinterpret_cast<std::uintptr_t>(candidates->capacity);
    const auto local=reinterpret_cast<std::uintptr_t>(candidates)+16;
    const auto extended=reinterpret_cast<std::uintptr_t>(destination->points);
    if(last<first||(last-first)%sizeof(NativePoint)||
       !((first==local&&limit==local+112*sizeof(NativePoint))||
         (first==extended&&limit==extended+256*sizeof(NativePoint)))||last>limit) {
        fallback();return;
    }
    const auto used=(last-first)/sizeof(NativePoint);
    // Remaining stock branches fit their original 112-entry budget. Leave
    // that entire budget available in addition to all NL additions (<=20).
    if(used+count+112>256){fallback();return;}
    if(first==local)std::memcpy(destination->points,candidates->begin,used*sizeof(NativePoint));
    std::memcpy(storage->points,accepted,count*sizeof(NativePoint));
    storage->native_mean=native_mean;
    // Commit only after complete input validation, geometry and safety checks.
    // The pinned caller consumes these pointers synchronously and the native
    // destructor 0x433cce8e is RET 0: it does not free the external buffer.
    out->begin=storage->points;out->end=storage->points+count;out->capacity=storage->points+10;
    candidates->begin=destination->points;candidates->end=destination->points+used;
    candidates->capacity=destination->points+256;
    InterlockedExchangeAdd(&status.generated,static_cast<LONG>(added));
    InterlockedExchange(&status.last_added,static_cast<LONG>(added));
    if(id==0)InterlockedExchangeAdd(&status.head_added,static_cast<LONG>(added));
}
inline void __cdecl restore_mean(unsigned char* registers,unsigned char* fx) noexcept {
    auto* stack=registers+36;
    auto* out=reinterpret_cast<NativeVector*>(stack+0x26c);
    if(!enabled()||pool_key==FLS_OUT_OF_INDEXES)return;
    auto* pool=static_cast<Pool*>(FlsGetValue(pool_key));
    if(!pool)return;
    for(auto& slot:pool->slots)if(slot.owner==out&&out->begin==slot.points) {
        std::memcpy(fx+256,&slot.native_mean.x,4); // XMM6.low
        std::memcpy(fx+272,&slot.native_mean.y,4); // XMM7.low
        std::memcpy(fx+240,&slot.native_mean.z,4); // XMM5.low
        InterlockedIncrement(&skeet_nl_points_status.centroid_restores);return;
    }
}
inline constexpr unsigned sites[]={0x4e9d0};
inline bool compatible(const unsigned char* image,std::size_t size) {
    if(!image||size!=core_image::image_size)return false;
    if(!nl_points_mean::compatible(image))return false;
    constexpr unsigned char init[]={0x8d,0x41,0x10,0x89,0x41,4,0x89,1,0x83,0xc0,0x48,0x89,0x41,8,0x8b,0xc1,0xc3};
    constexpr unsigned char entry[]={0x55,0x8b,0xec,0x83,0xe4,0xf0,0x81,0xec,0xe8,3,0,0};
    constexpr unsigned char cleanup[]={0xc2,0,0};
    constexpr unsigned char main_init[]={0x8d,0x41,0x10,0x89,0x41,4,0x89,1,0x05,0x80,0x0a,0,0,0x89,0x41,8,0x8b,0xc1,0xc3};
    if(std::memcmp(image+0xc5a95,init,sizeof(init))||std::memcmp(image+0xed9b7,entry,sizeof(entry))||
       std::memcmp(image+0xbce8e,cleanup,sizeof(cleanup))||
       std::memcmp(image+0x55490,main_init,sizeof(main_init)))return false;
    for(unsigned site:sites)if(image[site]!=0xe8||
       core_image::image_base+site+5+read<unsigned>(image,site+1)!=0x433fd9b7)return false;
    return true;
}
inline bool apply(unsigned char* image,std::size_t size) {
    auto& status=skeet_nl_points_status;status.mode=nl_hypotheses::selected_mode;
    if(!enabled())return true;
    if(reinterpret_cast<std::uintptr_t>(image)!=core_image::image_base||!compatible(image,size)) {
        install_error="NL points: unsupported GS call/buffer contract.";SetLastError(ERROR_REVISION_MISMATCH);return false;
    }
    auto* shim=static_cast<unsigned char*>(VirtualAlloc(nullptr,4096,MEM_COMMIT|MEM_RESERVE,PAGE_READWRITE));
    if(!shim){install_error="NL points: cannot allocate primary-center bridge.";return false;}
    const auto plan=nl_points_mean::make(reinterpret_cast<unsigned>(shim),reinterpret_cast<unsigned>(restore_mean));
    std::memcpy(shim,plan.code,plan.length);DWORD old=0;
    if(!VirtualProtect(shim,4096,PAGE_EXECUTE_READ,&old)||
       !FlushInstructionCache(GetCurrentProcess(),shim,4096)) {
        const DWORD error=GetLastError();VirtualFree(shim,0,MEM_RELEASE);SetLastError(error);
        install_error="NL points: cannot prepare primary-center bridge.";return false;
    }
    pool_key=FlsAlloc(release_pool);
    if(pool_key==FLS_OUT_OF_INDEXES){VirtualFree(shim,0,MEM_RELEASE);install_error="NL points: cannot allocate thread storage.";return false;}
    unsigned char before[1][5]{};
    for(unsigned i=0;i<1;++i) {
        std::memcpy(before[i],image+sites[i],5);
        const unsigned displacement=reinterpret_cast<unsigned>(bridge)-(core_image::image_base+sites[i]+5);
        std::memcpy(image+sites[i]+1,&displacement,4);
    }
    std::memcpy(image+nl_points_mean::site,plan.jump,8);
    if(!FlushInstructionCache(GetCurrentProcess(),image,size)) {
        const DWORD error=GetLastError();
        for(unsigned i=0;i<1;++i)std::memcpy(image+sites[i],before[i],5);
        std::memcpy(image+nl_points_mean::site,nl_points_mean::original,8);
        FlushInstructionCache(GetCurrentProcess(),image,size);
        VirtualFree(shim,0,MEM_RELEASE);
        FlsFree(pool_key);pool_key=FLS_OUT_OF_INDEXES;SetLastError(error);
        install_error="NL points: cannot flush core instruction cache.";return false;
    }
    InterlockedExchange(&status.installed,1);return true;
}
} // namespace nl_points_patch
