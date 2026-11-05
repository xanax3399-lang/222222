#include "lua_native.h"
#include "native.h"
#include <cmath>
#include <cstddef>

extern "C" __declspec(dllexport) GsnlLuaStatus gsnl_lua_status={1,1,0,0,0,0,0};
namespace {
// Offsets/ABI are specific to the pinned GS LuaJIT32 and checked against its
// original instructions. Never reinterpret an NL or GC64 state with this layout.
struct State {unsigned char header[0x10];unsigned base,top,maxstack;};
static_assert(offsetof(State,base)==0x10&&offsetof(State,top)==0x14&&offsetof(State,maxstack)==0x18);
using CFunction=int(__cdecl*)(void*);
struct Reg {const char* name;CFunction function;};
using GetTop=int(__cdecl*)(void*);
using SetTop=void(__cdecl*)(void*,int);
using FindTable=const char*(__cdecl*)(void*,int,const char*,int);
using PushClosure=void(__cdecl*)(void*,CFunction,int);
using SetField=void(__cdecl*)(void*,int,const char*);
using OpenLib=void(__cdecl*)(void*,const char*,const Reg*,int);
using PushString=void(__cdecl*)(void*,const char*);
constexpr int registry_index=-10000;

void push_number(void* state,double value) {
    auto* s=static_cast<State*>(state);
    // C functions are entered with LUA_MINSTACK=20 available slots. We use at
    // most 18 and never hold a stack pointer across an allocating GS API call.
    std::memcpy(reinterpret_cast<void*>(s->top),&value,8);s->top+=8;
}
int failure(void* state,const char* message) {
    auto* s=static_cast<State*>(state);const unsigned nil=0xffffffff;
    std::memcpy(reinterpret_cast<void*>(s->top+4),&nil,4);s->top+=8;
    reinterpret_cast<PushString>(0x434370e4)(state,message);return 2;
}
bool numbers(void* state,unsigned count,double* out) {
    const auto* s=static_cast<State*>(state);
    if(s->top<s->base||(s->top-s->base)/8!=count)return false;
    for(unsigned i=0;i<count;++i) {
        unsigned value[2];std::memcpy(value,reinterpret_cast<const void*>(s->base+i*8),8);
        if(value[1]>0xfffffff2u)return false;
        if(value[1]==0xfffffff2u)out[i]=static_cast<std::int32_t>(value[0]);
        else std::memcpy(out+i,value,8);
        if(!std::isfinite(out[i]))return false;
    }
    return true;
}
int __cdecl version(void* state){push_number(state,gsnl_abi_version());return 1;}
int __cdecl source(void* state){reinterpret_cast<PushString>(0x434370e4)(state,gsnl_source(nullptr));return 1;}
int __cdecl length(void* state){
    double a[3];if(!numbers(state,3,a))return failure(state,"GSNL length3: three finite numbers required");
    push_number(state,gsnl_length3(a[0],a[1],a[2]));return 1;
}
int __cdecl dot(void* state){
    double a[6];if(!numbers(state,6,a))return failure(state,"GSNL dot3: six finite numbers required");
    push_number(state,gsnl_dot3(a[0],a[1],a[2],a[3],a[4],a[5]));return 1;
}
int __cdecl yaw(void* state){
    double a[1];if(!numbers(state,1,a))return failure(state,"GSNL normalize_yaw: one finite number required");
    push_number(state,gsnl_normalize_yaw(a[0]));return 1;
}
int __cdecl snapshot(void* state){
    GsnlSnapshot snap{};if(!gsnl_snapshot(&snap,sizeof(snap)))return failure(state,"GSNL: snapshot unavailable");
    std::uint32_t fields[18];std::memcpy(fields,&snap,sizeof(fields));
    for(unsigned value:fields)push_number(state,value);return 18;
}
const Reg functions[]={{"abi_version",version},{"source",source},{"snapshot",snapshot},
    {"length3",length},{"dot3",dot},{"normalize_yaw",yaw},{nullptr,nullptr}};
}

extern "C" __declspec(dllexport) int __cdecl gsnl_lua_open(void* state) {
    InterlockedIncrement(&gsnl_lua_status.module_opens);
    reinterpret_cast<OpenLib>(0x43436420)(state,"gsnl_native",functions,0);
    return 1;
}
extern "C" __declspec(dllexport) void __fastcall gsnl_lua_bootstrap(void* state,void*) {
    InterlockedIncrement(&gsnl_lua_status.bootstrap_calls);
    const int top=reinterpret_cast<GetTop>(0x43434771)(state);
    const char* error=reinterpret_cast<FindTable>(0x43426632)(state,registry_index,"_PRELOAD",1);
    if(!error) {
        reinterpret_cast<PushClosure>(0x43432f73)(state,gsnl_lua_open,0);
        reinterpret_cast<SetField>(0x43435b37)(state,-2,"gsnl_native");
        InterlockedIncrement(&gsnl_lua_status.preload_registered);
    }else InterlockedIncrement(&gsnl_lua_status.errors);
    reinterpret_cast<SetTop>(0x43426bdf)(state,top);
    // Rejoin the original compat setup before any user scripts are loaded.
    reinterpret_cast<void(__thiscall*)(void*)>(0x433e8ee0)(state);
}
