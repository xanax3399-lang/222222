// Offline Windows x86 experiment: original Lua subsystem only. Never executes
// the cheat entry point, host bootstrap, game hooks or user-supplied scripts.
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <cstdio>
#include <cstring>
#include <cstdint>
#include "../../source/skeet/Binary/imports.h"
#include "../../source/skeet/core_image.h"

static const char* phase="startup";
static LONG CALLBACK exception_report(EXCEPTION_POINTERS* p){
    std::printf("GS_VM_EXCEPTION phase=%s code=%08lx eip=%08lx\n",phase,
        p->ExceptionRecord->ExceptionCode,p->ContextRecord->Eip);std::fflush(stdout);
    ExitProcess(90);return EXCEPTION_CONTINUE_SEARCH;
}
int wmain(int argc,wchar_t** argv){
    if(argc!=2)return 1;
    AddVectoredExceptionHandler(1,exception_report);
    phase="load_wrapper";HMODULE dll=LoadLibraryW(argv[1]);if(!dll)return 2;
    auto resource=FindResourceW(dll,MAKEINTRESOURCEW(102),MAKEINTRESOURCEW(10));if(!resource)return 3;
    auto bytes=LoadResource(dll,resource);const auto raw=LockResource(bytes);
    if(!core_image::matches_original(raw,SizeofResource(dll,resource)))return 4;
    phase="map_original_image";
    auto image=static_cast<unsigned char*>(VirtualAlloc(reinterpret_cast<void*>(0x43310000),
        0x2fc000,MEM_RESERVE|MEM_COMMIT,PAGE_EXECUTE_READWRITE));
    if(!image)return 5;
    std::memcpy(image,raw,0x2fc000);unsigned fixed=0;
    phase="resolve_standard_imports";
    for(const auto& item:imports){
        if(_stricmp(item.lib.c_str(),"kernel32.dll")&&_stricmp(item.lib.c_str(),"ntdll.dll")&&
            _stricmp(item.lib.c_str(),"msvcrt.dll")&&_stricmp(item.lib.c_str(),"user32.dll"))continue;
        auto proc=GetProcAddress(LoadLibraryA(item.lib.c_str()),item.name.c_str());
        if(!proc){
            if(item.rip>=0x43420000&&item.rip<0x43460000){std::printf("Missing required %s!%s\n",item.lib.c_str(),item.name.c_str());return 6;}
            continue;
        }
        auto location=reinterpret_cast<unsigned char*>(item.rip);
        auto address=static_cast<std::uint32_t>(reinterpret_cast<std::uintptr_t>(proc));
        if(*location==0xe8||*location==0xe9)address-=item.rip+5;
        std::memcpy(location+1,&address,4);++fixed;
    }
    FlushInstructionCache(GetCurrentProcess(),image,0x2fc000);
    std::printf("GS_VM_FIXED_IMPORTS %u\n",fixed);std::fflush(stdout);
    const auto newstate=reinterpret_cast<void*(__cdecl*)()>(0x43433899);
    const auto openlibs=reinterpret_cast<void(__cdecl*)(void*)>(0x43437eb6);
    const auto close=reinterpret_cast<void(__cdecl*)(void*)>(0x4342de79);
    const auto findtable=reinterpret_cast<const char*(__cdecl*)(void*,int,const char*,int)>(0x43426632);
    using CFunction=int(__cdecl*)(void*);
    const auto pushclosure=reinterpret_cast<void(__cdecl*)(void*,CFunction,int)>(0x43432f73);
    const auto setfield=reinterpret_cast<void(__cdecl*)(void*,int,const char*)>(0x43435b37);
    const auto settop=reinterpret_cast<void(__cdecl*)(void*,int)>(0x43426bdf);
    const auto loadbuffer=reinterpret_cast<int(__cdecl*)(void*,const char*,unsigned,const char*,const char*)>(0x43436cb3);
    const auto pcall=reinterpret_cast<int(__cdecl*)(void*,int,int,int)>(0x4342d9b9);
    const auto tostring=reinterpret_cast<const char*(__cdecl*)(void*,int,unsigned*)>(0x43435597);
    const auto openmodule=reinterpret_cast<CFunction>(GetProcAddress(dll,"gsnl_lua_open"));if(!openmodule)return 7;
    phase="luaL_newstate";void* state=newstate();if(!state)return 8;
    phase="luaL_openlibs";openlibs(state);
    phase="register_native_preload";
    if(findtable(state,-10000,"_PRELOAD",1))return 9;
    pushclosure(state,openmodule,0);setfield(state,-2,"gsnl_native");settop(state,0);
    const char script[]=R"LUA(
local m=require('gsnl_native')
assert(m.abi_version()==65536)
assert(m.length3(3,4,12)==13)
assert(m.dot3(1,2,3,4,5,6)==32)
assert(m.normalize_yaw(540)==-180)
local value,err=m.length3('invalid',4,12)
assert(value==nil and type(err)=='string')
local values={m.snapshot()}
assert(#values==18 and values[1]==72 and values[2]==65536 and values[17]==0)
local text=m.source()
assert(type(text)=='string' and #text>20000 and type(loadstring(text))=='function')
)LUA";
    phase="luaL_loadbufferx";int result=loadbuffer(state,script,sizeof(script)-1,"@gsnl-vm-probe","t");
    if(!result){phase="lua_pcall_native_module";result=pcall(state,0,0,0);}
    if(result){const char* error=tostring(state,-1,nullptr);std::printf("GS_VM_LUA_ERROR %d %s\n",result,error?error:"<nonstring>");return 10;}
    phase="lua_close";close(state);
    std::puts("GS_VM_NATIVE_MODULE_PASSED original GS Lua VM, real C++ module, no game startup");
    // The wrapper worker is waiting for absent game DLLs. Process exit owns it.
    return 0;
}
