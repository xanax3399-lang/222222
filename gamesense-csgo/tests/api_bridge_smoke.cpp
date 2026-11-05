#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <cmath>
#include <cstdio>
#include <cstring>
#define GSNL_API_DECL_ONLY
#include "../source/api_bridge/native.h"

int wmain(int argc,wchar_t** argv){
    if(argc!=2)return 1;
    HMODULE module=LoadLibraryW(argv[1]);if(!module)return 2;
    const auto version=reinterpret_cast<unsigned(*)()>(GetProcAddress(module,"gsnl_abi_version"));
    const auto source=reinterpret_cast<const char*(*)(unsigned*)>(GetProcAddress(module,"gsnl_source"));
    const auto snapshot=reinterpret_cast<int(*)(GsnlSnapshot*,unsigned)>(GetProcAddress(module,"gsnl_snapshot"));
    const auto length=reinterpret_cast<double(*)(double,double,double)>(GetProcAddress(module,"gsnl_length3"));
    const auto yaw=reinterpret_cast<double(*)(double)>(GetProcAddress(module,"gsnl_normalize_yaw"));
    const auto table=reinterpret_cast<const GsnlApiTable*>(GetProcAddress(module,"gsnl_api_table"));
    if(!version||!source||!snapshot||!length||!yaw||version()!=0x10000)return 3;
    if(!table||std::memcmp(table->magic,"GSNL_API_V1_TAB!",16)||table->abi!=0x10000||table->size!=48||
        table->version!=version||table->source!=source||table->snapshot!=snapshot||
        table->length3!=length||table->normalize_yaw!=yaw)return 8;
    unsigned size=0;const char* code=source(&size);
    if(!code||size<20000||size>=1048576||code[size]!=0||!std::strstr(code,"return function(native, gs)")||
        !std::strstr(code,"rage_exploit:force_charge")||std::strstr(code,"__GSNL_INVENTORY__"))return 4;
    GsnlSnapshot status{};
    if(snapshot(nullptr,sizeof(status))||snapshot(&status,sizeof(status)-1))return 5;
    if(!snapshot(&status,sizeof(status))||status.size!=sizeof(status)||status.abi!=0x10000||
        status.recharge_enabled!=0||status.points_calls!=0)return 6;
    if(std::abs(length(3,4,12)-13)>1e-9||yaw(540)!=-180||yaw(-181)!=179)return 7;
    const auto lua_status=reinterpret_cast<const unsigned*>(GetProcAddress(module,"gsnl_lua_status"));
    if(!lua_status||lua_status[0]!=1||lua_status[1]!=1||lua_status[2]||lua_status[3]||lua_status[4]||lua_status[5]||lua_status[6])return 9;
    std::puts("Native API exports, embedded Lua source, snapshot guards and default recharge passed.");
    // Process exit closes the waiting loader worker; never unload beneath it.
    return 0;
}
