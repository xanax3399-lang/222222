#pragma once
#include <windows.h>
#include <cmath>
#include <cstring>
#include "nl_hypotheses.h"
#include "v3_fire_status.h"
#include "v3_fire_shim.h"
extern "C" __declspec(dllexport) v3_fire::Status skeet_v3_fire_status;
namespace v3_fire {
inline DWORD storage=FLS_OUT_OF_INDEXES;
inline const char* install_error="V3 firing/recharge setup did not finish.";
inline const char* last_error(){return install_error;}
inline unsigned read(const void* p,unsigned offset){unsigned v;std::memcpy(&v,static_cast<const unsigned char*>(p)+offset,4);return v;}
struct State {
    unsigned context,command,number,previous_mode;
    bool release,have_sample;
    void *hc_context,*weapon,*candidate;
    unsigned eye[3],point[3];
};
inline void WINAPI cleanup(void* p){if(p)HeapFree(GetProcessHeap(),0,p);}
inline State* state() {
    auto* s=static_cast<State*>(FlsGetValue(storage));if(s)return s;
    s=static_cast<State*>(HeapAlloc(GetProcessHeap(),HEAP_ZERO_MEMORY,sizeof(State)));
    if(s&&!FlsSetValue(storage,s)){cleanup(s);s=nullptr;}return s;
}
inline unsigned char* frame(unsigned* registers){return reinterpret_cast<unsigned char*>(registers)+36;}
inline bool valid_context(unsigned context) {
    return context>=0x10000&&read(reinterpret_cast<void*>(context),0)==0x4346edd4;
}
// At 433abe72 the native hotkey selection and connection/capacity gates have
// already run. Mode 1 is the native double-shot path in 4336663f; mode 0 flushes
// remaining commands when its key is released. Never infer this from key codes.
inline bool __cdecl observe(unsigned* registers,void*) {
    auto& st=skeet_v3_fire_status;auto* s=state();
    const unsigned context=registers[1],command=read(frame(registers),0x24);
    if(!s||!valid_context(context)||command<0x10000){InterlockedIncrement(&st.fallback);return false;}
    const unsigned number=read(reinterpret_cast<void*>(command),4);
    const unsigned mode=read(reinterpret_cast<void*>(context),0xf4);
    // Duplicate visits to the same command must retain its release exemption.
    if(s->context!=context||s->number!=number||s->command!=command) {
        const bool sequential=s->context==context&&number>s->number&&number-s->number<=150;
        s->release=sequential&&s->previous_mode==1&&mode!=1;
        s->have_sample=false;
        if(s->release)InterlockedIncrement(&st.dt_releases);
    }
    s->context=context;s->command=command;s->number=number;s->previous_mode=mode;
    st.last_command=number;st.last_dt_mode=mode;
    st.last_charge=read(reinterpret_cast<void*>(context),0x104);
    st.last_desired=read(reinterpret_cast<void*>(context),0xfc);
    InterlockedIncrement(&st.commands);return false;
}
inline bool protected_dt(const State& s) {
    const auto* context=reinterpret_cast<const void*>(s.context);
    return s.release||(read(context,0x14)&8)!=0||
        (read(context,0xf4)==0&&static_cast<int>(read(context,0x104))>0);
}
using Hitchance=bool(__thiscall*)(void*,void*,void*,float*);
inline bool __fastcall sample(void* context,void*,void* weapon,void* candidate,float* probability) {
    const bool result=reinterpret_cast<Hitchance>(0x4341b4c2)(context,weapon,candidate,probability);
    auto* s=state();
    if(s&&s->command&&weapon&&candidate) {
        s->hc_context=context;s->weapon=weapon;s->candidate=candidate;
        std::memcpy(s->eye,static_cast<unsigned char*>(weapon)+0xdc,12);
        std::memcpy(s->point,static_cast<unsigned char*>(candidate)+0xc,12);
        s->have_sample=true;
    }
    return result;
}
// The earlier native HC can precede the eye-height correction at 4335595d.
// Revalidate only this observed geometric change, immediately before GS commits
// its automatic attack. No second HC pass is needed for unchanged input.
inline bool __cdecl guard(unsigned* registers,void*) {
    auto& st=skeet_v3_fire_status;auto* f=frame(registers);
    if(!st.guard_enabled||!f[0x22])return false;
    InterlockedIncrement(&st.guard_calls);auto* s=state();
    const unsigned command=read(f,0x28);
    if(!s||!s->have_sample||s->command!=command||command<0x10000||
       read(reinterpret_cast<void*>(command),4)!=s->number||!valid_context(s->context)||
       read(f,0x18)!=reinterpret_cast<unsigned>(s->candidate)||
       registers[0]!=reinterpret_cast<unsigned>(s->weapon)) {
        InterlockedIncrement(&st.fallback);return false;
    }
    if(protected_dt(*s)){InterlockedIncrement(&st.dt_bypass);return false;}
    if(read(reinterpret_cast<void*>(command),0x30)&0x801) {
        InterlockedIncrement(&st.manual_bypass);return false;
    }
    if(!std::memcmp(s->eye,static_cast<unsigned char*>(s->weapon)+0xdc,12)&&
       !std::memcmp(s->point,static_cast<unsigned char*>(s->candidate)+0xc,12)) {
        InterlockedIncrement(&st.unchanged);return false;
    }
    const float* eye=reinterpret_cast<const float*>(static_cast<unsigned char*>(s->weapon)+0xdc);
    const float* point=reinterpret_cast<const float*>(static_cast<unsigned char*>(s->candidate)+0xc);
    for(unsigned i=0;i<3;++i)if(!std::isfinite(eye[i])||!std::isfinite(point[i])) {
        InterlockedIncrement(&st.fallback);return false;
    }
    InterlockedIncrement(&st.rechecks);
    float probability=NAN;
    const bool result=reinterpret_cast<Hitchance>(0x4341b4c2)(s->hc_context,s->weapon,s->candidate,&probability);
    if(!std::isfinite(probability)||probability<0||probability>1) {
        InterlockedIncrement(&st.fallback);return false;
    }
    st.last_probability=probability;
    if(!result||probability==0) {
        f[0x22]=0;InterlockedIncrement(&st.canceled);
    }
    return false; // replay native MOVs/TEST/JZ; native no-fire path handles state
}
// The old hook skipped both the pending-shot predicate and the post-shot delay.
// That was not justified by the local shift flag: it can clear before the shot
// has finished processing. Enter only AFTER the original predicate returns false,
// and bypass only the aim/peek gate. The original cooldown and charge path stay.
inline bool __cdecl recharge(unsigned* registers,void*) {
    auto& st=skeet_v3_fire_status;InterlockedIncrement(&st.recharge_checks);
    if(!st.recharge_enabled)return false;
    auto* s=state();const unsigned context=registers[1],command=registers[4];
    if(!s||s->context!=context||s->command!=command||!valid_context(context)||
       command<0x10000||read(reinterpret_cast<void*>(command),4)!=s->number)return false;
    const auto* p=reinterpret_cast<const void*>(context);
    const int charged=static_cast<int>(read(p,0x104)),desired=static_cast<int>(read(p,0xfc)),
        capacity=static_cast<int>(read(p,0x100));
    if(read(p,0xf4)!=1||protected_dt(*s)||charged<0||desired<1||desired>15||
       capacity<7||capacity>64||charged>=desired||desired>=capacity||
       (read(reinterpret_cast<void*>(command),0x30)&0x801))return false;
    // No early recharge during a movement/duck/jump command. Zero input alone
    // does not prove zero physical speed; the native pending-shot and cooldown
    // guards above/below this hook must therefore remain authoritative too.
    if(read(reinterpret_cast<void*>(command),0x30)&0x79e)return false;
    constexpr unsigned movement_offsets[]={0x24,0x28,0x2c};
    for(unsigned offset:movement_offsets) {
        float movement;std::memcpy(&movement,reinterpret_cast<const unsigned char*>(command)+offset,4);
        if(!std::isfinite(movement)||movement!=0.0f)return false;
    }
    const unsigned player=read(frame(registers),0x18);
    const unsigned flags_pointer=*reinterpret_cast<const unsigned*>(0x434688d0);
    if(player<0x10000||flags_pointer<0x10000)return false;
    // Same resolved m_fFlags contract as the production GS stop helper.
    const unsigned flags_offset=*reinterpret_cast<const unsigned*>(flags_pointer)^
        *reinterpret_cast<const unsigned*>(0x43468c24)^0xe2fbe695u;
    if(flags_offset>0xfffc||flags_offset%4||
       (read(reinterpret_cast<void*>(player),flags_offset)&3)!=1)return false;
    InterlockedIncrement(&st.recharge_overrides);return true;
}
struct Site {unsigned address,size,normal,alternative;unsigned char original[8];};
inline constexpr Site sites[]={
    {0x433abe72,6,0x433abe78,0x433abe78,{0x39,0xbe,0xf4,0,0,0}},
    {0x433ac024,6,0x433ac02a,0x433ac16d,{0x38,0x05,0x24,0x72,0x46,0x43}},
    {0x43355ddf,8,0x43355de7,0x43355de7,{0x8b,0x4c,0x24,0x1c,0x8a,0x54,0x24,0x22}}
};
// The first candidate usually succeeds; later calls retry alternate points.
inline constexpr unsigned hc_sites[]={0x43354b55,0x43354b9a,0x43354bd3};
inline constexpr unsigned char hc_calls[][5]={{0xe8,0x68,0x69,0x0c,0},
    {0xe8,0x23,0x69,0x0c,0},{0xe8,0xea,0x68,0x0c,0}};
inline bool apply(unsigned char* image,unsigned size) {
    auto& st=skeet_v3_fire_status;st.mode=nl_hypotheses::selected_mode;
    if(st.mode!=nl_hypotheses::V3Patches||(!st.guard_enabled&&!st.recharge_enabled))return true;
    const auto reject=[&](const char* message){install_error=message;SetLastError(ERROR_REVISION_MISMATCH);return false;};
    if(size!=0x2fc000||reinterpret_cast<unsigned>(image)!=0x43310000)return reject("V3 fire: unsupported core.");
    for(const auto& s:sites)if(std::memcmp(image+s.address-0x43310000,s.original,s.size))
        return reject("V3 fire: native hook contract differs.");
    constexpr unsigned char native_wait[]={0xe8,0x71,0xc8,0,0,0x84,0xc0,0x0f,0x85,0x7a,2,0,0};
    if(std::memcmp(image+0x9c017,native_wait,sizeof(native_wait)))
        return reject("V3 fire: native pending-shot wait differs.");
    for(unsigned i=0;i<3;++i)if(std::memcmp(image+hc_sites[i]-0x43310000,hc_calls[i],5))
        return reject("V3 fire: HC call differs.");
    storage=FlsAlloc(cleanup);if(storage==FLS_OUT_OF_INDEXES){install_error="V3 fire: FLS allocation failed.";return false;}
    auto* shim=static_cast<unsigned char*>(VirtualAlloc(nullptr,4096,MEM_COMMIT|MEM_RESERVE,PAGE_READWRITE));
    const auto release=[&](){if(shim)VirtualFree(shim,0,MEM_RELEASE);FlsFree(storage);storage=FLS_OUT_OF_INDEXES;};
    if(!shim){release();install_error="V3 fire: bridge allocation failed.";return false;}
    const unsigned callbacks[]={reinterpret_cast<unsigned>(observe),reinterpret_cast<unsigned>(recharge),reinterpret_cast<unsigned>(guard)};
    v3_fire_shim::Plan plans[3];
    for(unsigned i=0;i<3;++i) {
        const auto& s=sites[i];plans[i]=v3_fire_shim::make(reinterpret_cast<unsigned>(shim)+i*256,
            s.address,s.original,s.size,s.normal,s.alternative,callbacks[i]);
        std::memcpy(shim+i*256,plans[i].code,plans[i].length);
    }
    DWORD previous=0;
    if(!VirtualProtect(shim,4096,PAGE_EXECUTE_READ,&previous)||!FlushInstructionCache(GetCurrentProcess(),shim,4096)) {
        release();install_error="V3 fire: bridge protection/flush failed.";return false;
    }
    const bool active[]={true,st.recharge_enabled!=0,st.guard_enabled!=0};
    for(unsigned i=0;i<3;++i)if(active[i])
        std::memcpy(image+sites[i].address-0x43310000,plans[i].jump,sites[i].size);
    if(st.guard_enabled)for(unsigned site:hc_sites) {
        unsigned char call[5]={0xe8};const unsigned delta=reinterpret_cast<unsigned>(sample)-site-5;
        std::memcpy(call+1,&delta,4);std::memcpy(image+site-0x43310000,call,5);
    }
    if(!FlushInstructionCache(GetCurrentProcess(),image,size)) {
        for(unsigned i=0;i<3;++i)if(active[i])
            std::memcpy(image+sites[i].address-0x43310000,sites[i].original,sites[i].size);
        if(st.guard_enabled)for(unsigned i=0;i<3;++i)std::memcpy(image+hc_sites[i]-0x43310000,hc_calls[i],5);
        FlushInstructionCache(GetCurrentProcess(),image,size);
        release();install_error="V3 fire: core flush failed.";return false;
    }
    InterlockedExchange(&st.installed,1);return true;
}
}
