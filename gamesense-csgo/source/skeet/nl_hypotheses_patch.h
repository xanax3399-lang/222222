#pragma once
#include "nl_hypotheses.h"
#include "core_image.h"
#include <cstdio>

namespace nl_hypotheses_patch {
inline constexpr unsigned site=0xeb4be,return_address=0x433fb4cb,code_size=128;
// Common join after the conditional normalization store at 0x433fb4b8.
// Both instructions are displaced intact: load slot offset, publish yaw.
inline constexpr unsigned char original[]={0x8b,0x44,0x24,0x44,0xf3,0x0f,0x11,0x8c,0x30,0xc0,0x05,0,0};
struct Plan {unsigned char code[code_size]{};unsigned char jump[sizeof(original)]{};unsigned length=0;};
inline bool compatible(const unsigned char* image,std::size_t size) {
    constexpr unsigned char prologue[]={0x55,0x8b,0xec,0x83,0xe4,0xf0,0x81,0xec,0xf8,0,0,0};
    constexpr unsigned char before[]={0xf3,0x0f,0x11,0x4c,0x24,0x14};
    constexpr unsigned char next[]={0x8b,0x44,0x24,0x34,0xf3,0x0f,0x10,0x80,0xac,0x01,0,0};
    return image&&size==core_image::image_size&&
        !std::memcmp(image+0xeac08,prologue,sizeof(prologue))&&
        !std::memcmp(image+site-sizeof(before),before,sizeof(before))&&
        !std::memcmp(image+site,original,sizeof(original))&&
        !std::memcmp(image+site+sizeof(original),next,sizeof(next));
}
inline bool make(const unsigned char* image,std::size_t size,unsigned location,unsigned callback,Plan& out) {
    if(!compatible(image,size))return false;
    Plan p{};unsigned n=0;
    auto byte=[&](unsigned char v){p.code[n++]=v;};
    auto dword=[&](unsigned v){std::memcpy(p.code+n,&v,4);n+=4;};
    // pushfd/pushad; preserve the complete native x87/SSE state in aligned
    // FXSAVE storage. Run C++ with an empty x87 stack and default masked FP
    // controls, then restore the native stack/controls. ESI/EDI retain frames.
    // Clear DF only while calling C++; popfd restores the original flags.
    constexpr unsigned char save[]={0x9c,0x60,0x89,0xe6,0x81,0xec,0x10,0x02,0,0,
        0x83,0xe4,0xf0,0x0f,0xae,0x04,0x24,0xdb,0xe3,0x68,0x80,0x1f,0,0,
        0x0f,0xae,0x14,0x24,0x83,0xc4,0x04,0x89,0xe7,0xfc,0x83,0xec,0x08,0x57,0x56,0xb8};
    std::memcpy(p.code,save,sizeof(save));n=sizeof(save);dword(callback);
    constexpr unsigned char restore[]={0xff,0xd0,0x83,0xc4,0x10,0x0f,0xae,0x0f,0x89,0xf4,0x61,0x9d};
    std::memcpy(p.code+n,restore,sizeof(restore));n+=sizeof(restore);
    std::memcpy(p.code+n,original,sizeof(original));n+=sizeof(original);
    byte(0xe9);dword(return_address-(location+n+4));p.length=n;
    std::memset(p.jump,0x90,sizeof(p.jump));p.jump[0]=0xe9;
    const unsigned displacement=location-(core_image::image_base+site+5);
    std::memcpy(p.jump+1,&displacement,4);out=p;return true;
}

#ifdef _WIN32
inline const char* install_error="NL setup did not finish.";
inline const char* last_error(){return install_error;}
// Best-effort last invocation snapshot for a fatal-error report. No file I/O
// occurs in the hot path. Phase is published after each group of fields.
struct BridgeTrace {
    DWORD registers[8]{};
    DWORD sequence=0,native_stack=0,caller=0,variant=0;
    float input=0,low=0,high=0,output=0;
    volatile LONG phase=0;
};
inline BridgeTrace last_bridge{};
inline void __cdecl bridge(unsigned char* registers,unsigned char* fx) noexcept {
    using namespace nl_hypotheses;
    auto& status=skeet_nl_hypotheses_status;
    const LONG sequence=InterlockedIncrement(reinterpret_cast<volatile LONG*>(&status.calls));
    // pushad layout: EDI,ESI,EBP,old ESP,EBX,EDX,ECX,EAX; flags follow.
    const auto ebp=read_u32(registers,8),record=read_u32(registers,4);
    auto* native_stack=registers+36;
    const auto variant=read_u32(native_stack,0x3c);
    auto& trace=last_bridge;
    std::memcpy(trace.registers,registers,sizeof(trace.registers));
    trace.sequence=sequence;trace.native_stack=reinterpret_cast<DWORD>(native_stack);
    trace.variant=variant;trace.caller=0;
    InterlockedExchange(&trace.phase,1);
    if(ebp)trace.caller=read_u32(reinterpret_cast<void*>(ebp),4);
    if(!ebp||!record||!known_caller(trace.caller)||variant>=3) {
        InterlockedExchange(&trace.phase,10);
        InterlockedIncrement(reinterpret_cast<volatile LONG*>(&status.rejected));return;
    }
    InterlockedExchange(&trace.phase,2);
    const float input=f32(reinterpret_cast<void*>(record),0x2c);
    const float low=f32(native_stack,0x54),high=f32(native_stack,0x50);
    trace.input=input;trace.low=low;trace.high=high;
    InterlockedExchange(&trace.phase,3);
    float output=0;
    if(!adapt(input,variant,low,high,output)) {
        InterlockedExchange(&trace.phase,11);
        InterlockedIncrement(reinterpret_cast<volatile LONG*>(&status.rejected));return;
    }
    // x86 FXSAVE XMM1 starts at 160+16. Change only its low float. The
    // displaced original MOVSS publishes the yaw in the record. Update the
    // native stack copy too: the following pose computation reads ESP+0x14.
    std::memcpy(fx+176,&output,4);
    std::memcpy(native_stack+0x14,&output,4);
    trace.output=output;
    InterlockedExchange(&trace.phase,5);
    std::int32_t in_bits=0,out_bits=0;std::memcpy(&in_bits,&input,4);std::memcpy(&out_bits,&output,4);
    InterlockedExchange(reinterpret_cast<volatile LONG*>(&status.last_variant),variant);
    InterlockedExchange(reinterpret_cast<volatile LONG*>(&status.last_tick),read_u32(reinterpret_cast<void*>(record),0x4c));
    InterlockedExchange(reinterpret_cast<volatile LONG*>(&status.last_input_bits),in_bits);
    InterlockedExchange(reinterpret_cast<volatile LONG*>(&status.last_output_bits),out_bits);
    InterlockedIncrement(reinterpret_cast<volatile LONG*>(&status.changed));
}
inline bool apply(unsigned char* image,std::size_t size) {
    using namespace nl_hypotheses;
    auto& status=skeet_nl_hypotheses_status;
    install_error="NL setup did not finish.";
    status.mode=selected_mode;
    if(selected_mode>NlCombined) {
        install_error="NL setup: invalid selected mode.";SetLastError(ERROR_INVALID_PARAMETER);return false;
    }
    if(!(selected_mode&NlAnimation))return true;
    if(reinterpret_cast<std::uintptr_t>(image)!=core_image::image_base) {
        install_error="NL setup: unexpected core image address.";SetLastError(ERROR_INVALID_ADDRESS);return false;
    }
    if(!compatible(image,size)) {
        install_error="NL setup: core size or animation-builder instructions differ.";
        SetLastError(ERROR_REVISION_MISMATCH);return false;
    }
    auto* code=static_cast<unsigned char*>(VirtualAlloc(nullptr,4096,MEM_RESERVE|MEM_COMMIT,PAGE_READWRITE));
    if(!code){install_error="NL setup: cannot allocate trampoline memory.";return false;}
    Plan plan{};
    if(!make(image,size,reinterpret_cast<unsigned>(code),reinterpret_cast<unsigned>(&bridge),plan)) {
        install_error="NL setup: animation-builder instructions changed during installation.";
        VirtualFree(code,0,MEM_RELEASE);SetLastError(ERROR_REVISION_MISMATCH);return false;
    }
    std::memcpy(code,plan.code,sizeof(plan.code));DWORD old=0;
    if(!VirtualProtect(code,4096,PAGE_EXECUTE_READ,&old)) {
        install_error="NL setup: cannot make trampoline executable.";
        const DWORD error=GetLastError();VirtualFree(code,0,MEM_RELEASE);SetLastError(error);return false;
    }
    if(!FlushInstructionCache(GetCurrentProcess(),code,sizeof(plan.code))) {
        install_error="NL setup: cannot flush trampoline instruction cache.";
        const DWORD error=GetLastError();VirtualFree(code,0,MEM_RELEASE);SetLastError(error);return false;
    }
    std::memcpy(image+site,plan.jump,sizeof(plan.jump));
    if(!FlushInstructionCache(GetCurrentProcess(),image+site,sizeof(plan.jump))) {
        install_error="NL setup: cannot flush patched core instruction cache.";
        const DWORD error=GetLastError();std::memcpy(image+site,original,sizeof(original));
        FlushInstructionCache(GetCurrentProcess(),image+site,sizeof(original));
        VirtualFree(code,0,MEM_RELEASE);SetLastError(error);return false;
    }
    InterlockedExchange(reinterpret_cast<volatile LONG*>(&status.installed),1);return true;
}
// This must precede the native core checksum/VM preparation. Installing a
// detour after the checksum would invalidate the image it describes.
template<class Finalize>
inline bool prepare(unsigned char* image,std::size_t size,Finalize finalize) {
    if(!apply(image,size))return false;
    finalize();return true;
}
#endif
}
