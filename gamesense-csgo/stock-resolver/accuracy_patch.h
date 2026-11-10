#pragma once
#include "accuracy_status.h"
#include "dt_status.h"
#include "../source/skeet/nl_hypotheses.h"
#include "../source/skeet/v3_fire_shim.h"
#include "../source/skeet/nl_stop_shim.h"
#include "../source/skeet/nl_stop_math.h"
#include <cmath>
#include <cstring>

namespace native_accuracy {
inline DWORD storage=FLS_OUT_OF_INDEXES;
inline const char* error_text="Native accuracy setup did not finish.";
inline unsigned read(const void* p,unsigned off=0){unsigned out;std::memcpy(&out,static_cast<const unsigned char*>(p)+off,4);return out;}
inline float real(const void* p,unsigned off){float out;std::memcpy(&out,static_cast<const unsigned char*>(p)+off,4);return out;}
inline unsigned char* frame(unsigned* registers){return reinterpret_cast<unsigned char*>(registers)+36;}
struct Inputs {unsigned geometry[6],precision[2],target,flags;};
struct State {
    unsigned context,command,number,previous_mode;
    bool release,have_sample,cached,passed,used_check;
    bool dt_latched,dt_call;
    void *dt_weapon,*dt_candidate,*dt_hc_context;
    void *hc_context,*weapon,*candidate;
    Inputs sample,checked;
    float probability,effective,threshold,scale;
};
inline void WINAPI cleanup(void* p){if(p)HeapFree(GetProcessHeap(),0,p);}
inline State* state() {
    auto* s=static_cast<State*>(FlsGetValue(storage));if(s)return s;
    s=static_cast<State*>(HeapAlloc(GetProcessHeap(),HEAP_ZERO_MEMORY,sizeof(State)));
    if(s&&!FlsSetValue(storage,s)){cleanup(s);s=nullptr;}return s;
}
inline bool context_ok(unsigned p){return p>=0x10000&&read(reinterpret_cast<void*>(p))==0x4346edd4;}
inline bool capture(void* weapon,void* candidate,Inputs& input) {
    std::memcpy(input.geometry,static_cast<unsigned char*>(weapon)+0xdc,12);
    std::memcpy(input.geometry+3,static_cast<unsigned char*>(candidate)+0xc,12);
    input.precision[0]=read(weapon,0xc4);input.precision[1]=read(weapon,0xd0);
    input.target=read(candidate,4);input.flags=read(candidate);
    for(unsigned bits:input.geometry){float value;std::memcpy(&value,&bits,4);if(!std::isfinite(value))return false;}
    for(unsigned bits:input.precision){float value;std::memcpy(&value,&bits,4);if(!std::isfinite(value)||value<0)return false;}
    return true;
}
inline bool __cdecl observe(unsigned* registers,void*) {
    auto& st=sr_accuracy_status;auto* s=state();
    const unsigned context=registers[1],command=read(frame(registers),0x24);
    if(!s||!context_ok(context)||command<0x10000){InterlockedIncrement(&st.fallback);return false;}
    const unsigned number=read(reinterpret_cast<void*>(command),4),mode=read(reinterpret_cast<void*>(context),0xf4);
    if(s->context!=context||s->command!=command||s->number!=number) {
        const bool sequential=s->context==context&&number>s->number&&number-s->number<=150;
        s->release=sequential&&s->previous_mode==1&&mode!=1;
        s->have_sample=false;s->cached=false;s->used_check=false;
        if(s->release)InterlockedIncrement(&st.dt_releases);
    }
    s->dt_latched=mode==1||(s->context==context&&mode==0&&(read(reinterpret_cast<void*>(context),0x14)&8)&&s->dt_latched&&
            (number==s->number||(number>s->number&&number-s->number<=150)));
    s->context=context;s->command=command;s->number=number;s->previous_mode=mode;
    st.last_command=number;InterlockedIncrement(&st.commands);return false;
}
inline bool active_dt(const State& s) {
    if(!s.dt_latched||!context_ok(s.context))return false;
    const auto* context=reinterpret_cast<void*>(s.context);const unsigned mode=read(context,0xf4);
    return mode==1||(mode==0&&(read(context,0x14)&8));
}
using Hitchance=bool(__thiscall*)(void*,void*,void*,float*);
inline bool run_hc(State* s,void* context,void* weapon,void* candidate,float* probability) {
    // Bound the sampler callback to the currently executing native HC call.
    const bool old_call=s&&s->dt_call;
    void *old_weapon=s?s->dt_weapon:nullptr,*old_candidate=s?s->dt_candidate:nullptr,*old_context=s?s->dt_hc_context:nullptr;
    if(s) {
        s->dt_call=sr_dt_status.enabled&&active_dt(*s)&&s->command&&
            read(reinterpret_cast<void*>(s->command),4)==s->number&&weapon&&candidate&&
            (read(weapon,0xd8)==11||read(weapon,0xd8)==38);
        s->dt_weapon=weapon;s->dt_candidate=candidate;s->dt_hc_context=context;
    }
    const bool result=reinterpret_cast<Hitchance>(0x4341b4c2)(context,weapon,candidate,probability);
    if(s){s->dt_call=old_call;s->dt_weapon=old_weapon;s->dt_candidate=old_candidate;s->dt_hc_context=old_context;}
    return result;
}
inline bool __fastcall sample(void* context,void*,void* weapon,void* candidate,float* probability) {
    auto* s=state();const bool result=run_hc(s,context,weapon,candidate,probability);
    if(s&&s->command&&read(reinterpret_cast<void*>(s->command),4)==s->number&&weapon&&candidate) {
        s->hc_context=context;s->weapon=weapon;s->candidate=candidate;
        s->have_sample=capture(weapon,candidate,s->sample);s->cached=false;
    }
    return result;
}
inline bool protected_dt(const State& s) {
    auto* context=reinterpret_cast<void*>(s.context);
    return s.release||(read(context,0x14)&8)!=0||(read(context,0xf4)==0&&static_cast<int>(read(context,0x104))>0);
}
inline bool supported(unsigned id){return id==11||id==38||id==40;}
inline bool __cdecl guard(unsigned* registers,void*) {
    auto& st=sr_accuracy_status;auto* f=frame(registers);
    if(!st.check_enabled||!f[0x22])return false;
    InterlockedIncrement(&st.guard_calls);auto* s=state();
    const unsigned command=read(f,0x28);
    if(!s||!s->have_sample||s->command!=command||command<0x10000||
       read(reinterpret_cast<void*>(command),4)!=s->number||!context_ok(s->context)||
       read(f,0x18)!=reinterpret_cast<unsigned>(s->candidate)||registers[0]!=reinterpret_cast<unsigned>(s->weapon)) {
        InterlockedIncrement(&st.fallback);return false;
    }
    const unsigned id=read(s->weapon,0xd8);st.last_weapon=id;
    if(!supported(id)){InterlockedIncrement(&st.unsupported);return false;}
    if(protected_dt(*s)){InterlockedIncrement(&st.dt_bypass);return false;}
    if(read(reinterpret_cast<void*>(command),0x30)&0x801){InterlockedIncrement(&st.manual_bypass);return false;}
    if(read(s->weapon)&0x4000){InterlockedIncrement(&st.fast_bypass);return false;}
    Inputs current{};
    const float threshold=real(f,0x2c);
    // This exact multiplier is applied by the native selection comparison at
    // 43354C0F..43354C33. It is not an additional configured HC threshold.
    const float scale=(read(s->candidate,0x34)&0x20)?real(f,0x90):1.f;
    if(!capture(s->weapon,s->candidate,current)||!std::isfinite(threshold)||threshold<0||threshold>1||!std::isfinite(scale)||scale<0) {
        InterlockedIncrement(&st.fallback);return false;
    }
    st.last_threshold=threshold;
    if(s->cached) {
        if(std::memcmp(&current,&s->checked,sizeof(current))||s->threshold!=threshold||s->scale!=scale) {
            // One additional HC per command. New unknown input gets native GS
            // behavior instead of an unbounded tracing loop in one frame.
            InterlockedIncrement(&st.fallback);return false;
        }
        if(!s->passed)f[0x22]=0;
        return false;
    }
    const bool geometry=std::memcmp(current.geometry,s->sample.geometry,sizeof(current.geometry))!=0||current.target!=s->sample.target||current.flags!=s->sample.flags;
    const bool precision=std::memcmp(current.precision,s->sample.precision,sizeof(current.precision))!=0;
    if(!geometry&&!precision){InterlockedIncrement(&st.unchanged);return false;}
    if(s->used_check){InterlockedIncrement(&st.fallback);return false;}
    s->used_check=true;
    if(geometry)InterlockedIncrement(&st.geometry_changed);
    if(precision)InterlockedIncrement(&st.precision_changed);
    InterlockedIncrement(&st.rechecks);float probability=NAN;
    const bool result=run_hc(s,s->hc_context,s->weapon,s->candidate,&probability);
    const float effective=probability*scale;
    if(!std::isfinite(probability)||probability<0||probability>1||!std::isfinite(effective)) {
        InterlockedIncrement(&st.fallback);return false;
    }
    s->cached=true;s->checked=current;s->probability=probability;s->effective=effective;s->threshold=threshold;s->scale=scale;
    s->passed=result&&effective>threshold;
    st.last_probability=probability;st.last_effective=effective;
    if(!s->passed){f[0x22]=0;InterlockedIncrement(&st.canceled);}
    else std::memcpy(static_cast<unsigned char*>(s->candidate)+0x38,&probability,4); // Same raw HC field native selection writes.
    return false; // Replay native MOV/TEST/JZ; its normal no-fire path owns state.
}
inline bool __cdecl brake(unsigned* registers,void*) {
    auto& st=sr_accuracy_status;InterlockedIncrement(&st.brake_calls);
    const auto* f=frame(registers);auto* command=reinterpret_cast<unsigned char*>(registers[1]);const unsigned player=registers[0];
    const auto reject=[&](){InterlockedIncrement(&st.brake_fallback);return false;};
    if(!command||player<0x10000)return reject();
    const unsigned flags_ptr=*reinterpret_cast<unsigned*>(0x434688d0),interval_ptr=*reinterpret_cast<unsigned*>(0x4346a338);
    if(flags_ptr<0x10000||interval_ptr<0x10000)return reject();
    const unsigned offset=*reinterpret_cast<unsigned*>(flags_ptr)^*reinterpret_cast<unsigned*>(0x43468c24)^0xe2fbe695u;
    if(offset>0xfffc||offset%4)return reject();
    const float speed=real(f,0x1c),wish=real(f,8),accelerate=real(f,0x20),interval=real(reinterpret_cast<void*>(interval_ptr),0);
    if(!std::isfinite(speed)||!std::isfinite(wish)||!std::isfinite(accelerate)||!std::isfinite(interval)||
       speed<0||speed>2000||wish<0||wish>1000||accelerate<0||accelerate>100||interval<.0001f||interval>.1f)return reject();
    const bool grounded=(read(reinterpret_cast<void*>(player),offset)&1)!=0;nl_stop_recovery::Axes axes{};
    if(!nl_stop_recovery::brake_axes({{1,0},speed,wish,accelerate,interval,1,grounded},axes))return reject();
    const float before=real(command,0x24);if(!std::isfinite(before))return reject();
    std::memcpy(command+0x24,&axes.x,4);st.speed=speed;st.wish=wish;st.before=before;st.after=axes.x;
    InterlockedIncrement(&st.brake_applied);return true;
}
// Native HC chooses 32 or 64 seed jobs and then uses a 128-entry bank.
// Promote only the reduced tier to the EXISTING 64-job path. Never exceed it,
// alter HC thresholds/probabilities, or write attack/shift/recharge state.
inline bool __cdecl dt_budget(unsigned* registers,void*) {
    auto& st=sr_dt_status;auto* s=state();
    if(!st.enabled||!s||!s->dt_call)return false;
    auto* f=frame(registers);
    if(!active_dt(*s)||!s->command||
       read(reinterpret_cast<void*>(s->command),4)!=s->number||
       registers[1]!=reinterpret_cast<unsigned>(s->dt_weapon)||registers[0]!=reinterpret_cast<unsigned>(s->dt_candidate)||
       read(f,0x34)!=reinterpret_cast<unsigned>(s->dt_hc_context)) {
        InterlockedIncrement(&st.fallback);return false;
    }
    const unsigned weapon=read(s->dt_weapon,0xd8),before=read(f,0x10);
    if((weapon!=11&&weapon!=38)||(before!=32&&before!=64)){InterlockedIncrement(&st.fallback);return false;}
    InterlockedIncrement(&st.calls);st.last_command=s->number;st.last_weapon=weapon;st.last_before=before;st.last_after=64;
    if(before==32){const unsigned full=64;std::memcpy(f+0x10,&full,4);InterlockedIncrement(&st.boosted);}
    else InterlockedIncrement(&st.already_full);
    return false;
}
struct Site {unsigned address,size;unsigned char original[8];};
inline constexpr Site observer{0x433abe72,6,{0x39,0xbe,0xf4,0,0,0}};
inline constexpr Site commit{0x43355ddf,8,{0x8b,0x4c,0x24,0x1c,0x8a,0x54,0x24,0x22}};
inline constexpr Site dt_site{0x4341bc00,7,{0x33,0xd2,0x0f,0xb6,0x4c,0x24,0x0b}};
inline constexpr unsigned hc_sites[]={0x43354b55,0x43354b9a,0x43354bd3};
inline constexpr unsigned char hc_calls[][5]={{0xe8,0x68,0x69,0x0c,0},{0xe8,0x23,0x69,0x0c,0},{0xe8,0xea,0x68,0x0c,0}};
inline bool apply(unsigned char* image,unsigned size) {
    auto& st=sr_accuracy_status;st.mode=nl_hypotheses::selected_mode;sr_dt_status.mode=st.mode;
    if(st.mode!=nl_hypotheses::StockResolver||(!st.check_enabled&&!st.brake_enabled))return true;
    const auto fail=[&](const char* message){error_text=message;SetLastError(ERROR_REVISION_MISMATCH);return false;};
    if(reinterpret_cast<unsigned>(image)!=0x43310000||size!=0x2fc000)return fail("Accuracy patch: unsupported GS image.");
    const Site sites[]={observer,commit};
    if(st.check_enabled) {
        for(const auto& s:sites)if(std::memcmp(image+(s.address-0x43310000),s.original,s.size))return fail("Accuracy patch: native call contract differs.");
        for(unsigned i=0;i<3;++i)if(std::memcmp(image+(hc_sites[i]-0x43310000),hc_calls[i],5))return fail("Accuracy patch: HC call differs.");
        constexpr unsigned char comparison[]={0xf3,0x0f,0x10,0x54,0x24,0x2c,0x0f,0x2f,0xd1,0x72,0x27};
        constexpr unsigned char a[]={0xf3,0x0f,0x10,0x8e,0xc4,0,0,0},b[]={0xf3,0x0f,0x10,0x96,0xd0,0,0,0};
        if(std::memcmp(image+0x44c2a,comparison,sizeof(comparison))||std::memcmp(image+0x10b8b1,a,8)||std::memcmp(image+0x10b8cf,b,8))
            return fail("Accuracy patch: native threshold/precision input contract differs.");
    }
    const bool dt=st.check_enabled&&sr_dt_status.enabled;
    if(dt) {
        constexpr unsigned char tier[]={0xc7,0x44,0x24,0x10,0x20,0,0,0};
        constexpr unsigned char divide[]={0xf7,0x74,0x24,0x10};
        if(std::memcmp(image+(dt_site.address-0x43310000),dt_site.original,dt_site.size)||
           std::memcmp(image+0x10bbf8,tier,8)||std::memcmp(image+0x10bc14,divide,4))
            return fail("DT HC sampler: native sample-bank contract differs.");
    }
    if(st.brake_enabled&&!nl_stop_shim::compatible(image))return fail("Accuracy patch: native braking contract differs.");
    if(st.check_enabled){storage=FlsAlloc(cleanup);if(storage==FLS_OUT_OF_INDEXES){error_text="Accuracy patch: no thread storage.";return false;}}
    auto* memory=static_cast<unsigned char*>(VirtualAlloc(nullptr,4096,MEM_RESERVE|MEM_COMMIT,PAGE_READWRITE));
    const auto release=[&](){if(memory)VirtualFree(memory,0,MEM_RELEASE);if(storage!=FLS_OUT_OF_INDEXES){FlsFree(storage);storage=FLS_OUT_OF_INDEXES;}};
    if(!memory){release();error_text="Accuracy patch: bridge allocation failed.";return false;}
    v3_fire_shim::Plan plans[2]{};
    if(st.check_enabled)for(unsigned i=0;i<2;++i){const auto& s=sites[i];plans[i]=v3_fire_shim::make(reinterpret_cast<unsigned>(memory)+i*256,s.address,s.original,s.size,s.address+s.size,s.address+s.size,reinterpret_cast<unsigned>(i==0?observe:guard));std::memcpy(memory+i*256,plans[i].code,plans[i].length);}
    v3_fire_shim::Plan dt_plan{};
    if(dt){const auto& site=dt_site;dt_plan=v3_fire_shim::make(reinterpret_cast<unsigned>(memory)+768,site.address,site.original,site.size,site.address+site.size,site.address+site.size,reinterpret_cast<unsigned>(dt_budget));std::memcpy(memory+768,dt_plan.code,dt_plan.length);}
    nl_stop_shim::Plan stop{};
    if(st.brake_enabled){stop=nl_stop_shim::make(reinterpret_cast<unsigned>(memory)+512,reinterpret_cast<unsigned>(brake));std::memcpy(memory+512,stop.code,stop.length);}
    DWORD old=0;
    if(!VirtualProtect(memory,4096,PAGE_EXECUTE_READ,&old)||!FlushInstructionCache(GetCurrentProcess(),memory,4096)){release();error_text="Accuracy patch: bridge protection failed.";return false;}
    if(st.check_enabled) {
        for(unsigned i=0;i<2;++i)std::memcpy(image+(sites[i].address-0x43310000),plans[i].jump,sites[i].size);
        for(unsigned site:hc_sites){unsigned char call[5]={0xe8};const unsigned delta=reinterpret_cast<unsigned>(sample)-site-5;std::memcpy(call+1,&delta,4);std::memcpy(image+(site-0x43310000),call,5);}
    }
    if(dt)std::memcpy(image+(dt_site.address-0x43310000),dt_plan.jump,dt_site.size);
    if(st.brake_enabled)std::memcpy(image+nl_stop_shim::site,stop.jump,6);
    if(!FlushInstructionCache(GetCurrentProcess(),image,size)) {
        if(st.check_enabled){for(const auto& s:sites)std::memcpy(image+(s.address-0x43310000),s.original,s.size);for(unsigned i=0;i<3;++i)std::memcpy(image+(hc_sites[i]-0x43310000),hc_calls[i],5);}
        if(dt)std::memcpy(image+(dt_site.address-0x43310000),dt_site.original,dt_site.size);
        if(st.brake_enabled)std::memcpy(image+nl_stop_shim::site,nl_stop_shim::original,6);
        FlushInstructionCache(GetCurrentProcess(),image,size);release();error_text="Accuracy patch: instruction flush failed, changes rolled back.";return false;
    }
    if(dt)InterlockedExchange(&sr_dt_status.installed,1);
    InterlockedExchange(&st.installed,1);return true;
}
}
