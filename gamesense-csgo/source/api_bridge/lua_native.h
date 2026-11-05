#pragma once
#include <windows.h>
#include <cstdint>
#include <cstring>

struct GsnlLuaStatus {
    unsigned version,enabled;
    volatile LONG installed,bootstrap_calls,preload_registered,module_opens,errors;
};
static_assert(sizeof(GsnlLuaStatus)==28);
extern "C" __declspec(dllexport) GsnlLuaStatus gsnl_lua_status;
extern "C" __declspec(dllexport) void __fastcall gsnl_lua_bootstrap(void* state,void*);
extern "C" __declspec(dllexport) int __cdecl gsnl_lua_open(void* state);

namespace gsnl_lua {
constexpr unsigned image_base=0x43310000,callsite=0x433ec5c0;
inline constexpr unsigned char original[]={0xe8,0x1b,0xc9,0xff,0xff};
inline const char* error_message="Native Lua bridge setup did not finish.";
inline bool apply(unsigned char* image,unsigned size) {
    if(!gsnl_lua_status.enabled)return true;
    if(reinterpret_cast<std::uintptr_t>(image)!=image_base||size!=0x2fc000||
        std::memcmp(image+callsite-image_base,original,5)) {
        error_message="Native Lua bridge: unsupported GS bootstrap call.";
        SetLastError(ERROR_REVISION_MISMATCH);return false;
    }
    unsigned char patch[5]={0xe8};
    const auto target=static_cast<unsigned>(reinterpret_cast<std::uintptr_t>(&gsnl_lua_bootstrap));
    const unsigned delta=target-callsite-5;std::memcpy(patch+1,&delta,4);
    std::memcpy(image+callsite-image_base,patch,5);
    if(!FlushInstructionCache(GetCurrentProcess(),image+callsite-image_base,5)) {
        std::memcpy(image+callsite-image_base,original,5);
        FlushInstructionCache(GetCurrentProcess(),image+callsite-image_base,5);
        error_message="Native Lua bridge: instruction cache flush failed.";return false;
    }
    InterlockedExchange(&gsnl_lua_status.installed,1);return true;
}
}
