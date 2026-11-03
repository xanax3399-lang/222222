#pragma once
#include <windows.h>
#include <cmath>
#include <cstring>
#include "nl_hypotheses.h"
#include "nl_stop_math.h"
#include "nl_stop_status.h"
#include "nl_stop_shim.h"
extern "C" __declspec(dllexport) nl_stop_patch::Status skeet_nl_stop_status;
namespace nl_stop_patch {
inline const char* install_error="NL brake setup did not finish.";
inline const char* last_error(){return install_error;}

inline bool __cdecl apply_brake(unsigned* registers,void*) {
    auto& status=skeet_nl_stop_status;InterlockedIncrement(&status.calls);
    // PUSHAD layout: EDI,ESI,EBP,ESP,EBX,EDX,ECX,EAX; +36 recovers ESP
    // before PUSHFD/PUSHAD. This is the native stop function's aligned frame.
    const auto* frame=reinterpret_cast<const unsigned char*>(registers)+36;
    auto* command=reinterpret_cast<unsigned char*>(registers[1]); // native ESI
    const unsigned entity=registers[0]; // native EDI after acceleration helper
    float speed,wish,accelerate,before;
    std::memcpy(&speed,frame+0x1c,4);std::memcpy(&wish,frame+8,4);
    std::memcpy(&accelerate,frame+0x20,4);
    const auto reject=[&](){InterlockedIncrement(&status.fallback);return false;};
    if(!command||entity<0x10000)return reject();
    const unsigned flags_pointer=*reinterpret_cast<const unsigned*>(0x434688d0);
    const unsigned interval_pointer=*reinterpret_cast<const unsigned*>(0x4346a338);
    if(flags_pointer<0x10000||interval_pointer<0x10000)return reject();
    // Same resolved m_fFlags offset used by the original acceleration helper.
    const unsigned offset=*reinterpret_cast<const unsigned*>(flags_pointer)^
        *reinterpret_cast<const unsigned*>(0x43468c24)^0xe2fbe695u;
    if(offset>0xfffc||offset%4)return reject();
    const bool grounded=(*reinterpret_cast<const unsigned*>(entity+offset)&1)!=0;
    const float interval=*reinterpret_cast<const float*>(interval_pointer);
    if(!std::isfinite(speed)||!std::isfinite(wish)||!std::isfinite(accelerate)||
       !std::isfinite(interval)||speed<0||speed>2000||wish<0||wish>1000||
       accelerate<0||accelerate>100||interval<.0001f||interval>.1f)return reject();
    // GS has already performed friction and prepared counter-velocity angles.
    // Its effective wishspeed/acceleration include its own weapon/duck/walk
    // rules. Unit surface factor follows the native GS acceleration model;
    // NL's separate surface-dependent prediction is not integrated here.
    nl_stop_recovery::Axes result;
    if(!nl_stop_recovery::brake_axes({{1,0},speed,wish,accelerate,interval,1,grounded},result))
        return reject();
    std::memcpy(&before,command+0x24,4);
    if(!std::isfinite(before))return reject();
    std::memcpy(command+0x24,&result.x,4); // sidemove and native angles stay intact
    status.speed=speed;status.max_speed=wish;status.accelerate=accelerate;
    status.interval=interval;status.before=before;status.after=result.x;
    status.last_grounded=grounded;InterlockedIncrement(&status.applied);return true;
}

inline bool apply(unsigned char* image,unsigned size) {
    auto& status=skeet_nl_stop_status;status.mode=nl_hypotheses::selected_mode;
    if(!(status.mode&nl_hypotheses::NlPoints)||!status.enabled)return true;
    if(size!=0x2fc000||reinterpret_cast<unsigned>(image)!=0x43310000||
       !nl_stop_shim::compatible(image)) {
        install_error="NL brake: unsupported GS stop contract.";
        SetLastError(ERROR_REVISION_MISMATCH);return false;
    }
    auto* shim=static_cast<unsigned char*>(VirtualAlloc(nullptr,4096,MEM_RESERVE|MEM_COMMIT,PAGE_READWRITE));
    if(!shim){install_error="NL brake: cannot allocate bridge.";return false;}
    const auto plan=nl_stop_shim::make(reinterpret_cast<unsigned>(shim),reinterpret_cast<unsigned>(apply_brake));
    std::memcpy(shim,plan.code,plan.length);DWORD previous=0;
    if(!VirtualProtect(shim,4096,PAGE_EXECUTE_READ,&previous)||
       !FlushInstructionCache(GetCurrentProcess(),shim,plan.length)) {
        VirtualFree(shim,0,MEM_RELEASE);install_error="NL brake: cannot prepare bridge.";return false;
    }
    std::memcpy(image+nl_stop_shim::site,plan.jump,6);
    if(!FlushInstructionCache(GetCurrentProcess(),image,size)) {
        std::memcpy(image+nl_stop_shim::site,nl_stop_shim::original,6);
        FlushInstructionCache(GetCurrentProcess(),image,size);VirtualFree(shim,0,MEM_RELEASE);
        install_error="NL brake: cannot flush core instructions.";return false;
    }
    InterlockedExchange(&status.installed,1);return true;
}
}
