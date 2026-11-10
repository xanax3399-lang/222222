#pragma once
#include <windows.h>
#include "../source/skeet/v3_fire_shim.h"
namespace stock_feedback {
constexpr unsigned hook_site=0x43355ef1;
constexpr unsigned char hook_bytes[]={0x56,0x89,0x81,0x68,1,0,0};
inline bool install_hook(unsigned char* image,unsigned size,unsigned callback,bool enabled) {
    if(!enabled)return true;
    if(reinterpret_cast<unsigned>(image)!=0x43310000||size!=0x2fc000||
       std::memcmp(image+hook_site-0x43310000,hook_bytes,7))return false;
    constexpr unsigned char call[]={0xe8,0xc5,0x69,0x0b,0};
    if(std::memcmp(image+0x45efa,call,5))return false;
    auto* memory=static_cast<unsigned char*>(VirtualAlloc(nullptr,4096,MEM_RESERVE|MEM_COMMIT,PAGE_READWRITE));
    if(!memory)return false;
    auto plan=v3_fire_shim::make(reinterpret_cast<unsigned>(memory),hook_site,hook_bytes,7,hook_site+7,hook_site+7,callback);
    std::memcpy(memory,plan.code,plan.length);DWORD old=0;
    if(!VirtualProtect(memory,4096,PAGE_EXECUTE_READ,&old)||!FlushInstructionCache(GetCurrentProcess(),memory,4096)){VirtualFree(memory,0,MEM_RELEASE);return false;}
    std::memcpy(image+hook_site-0x43310000,plan.jump,7);
    if(!FlushInstructionCache(GetCurrentProcess(),image,size)) {
        std::memcpy(image+hook_site-0x43310000,hook_bytes,7);FlushInstructionCache(GetCurrentProcess(),image,size);
        VirtualFree(memory,0,MEM_RELEASE);return false;
    }return true;
}
}
