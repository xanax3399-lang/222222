// Linux LuaJIT contract fixture. Shares production native math and embedded
// source. Process/module discovery and counter values are controlled fixtures.
#define GSNL_IMPLEMENT_MATH
#include "../source/api_bridge/native.h"
#include "embedded.h"
#include <cstring>
static int fixture_failure=0;
GSNL_EXPORT void gsnl_fixture_failure(int value){fixture_failure=value;}
GSNL_EXPORT const char* gsnl_source(unsigned* size){if(size)*size=sizeof(gsnl_embedded_source)-1;return gsnl_embedded_source;}
GSNL_EXPORT int gsnl_snapshot(GsnlSnapshot* out,unsigned size){
    if(!out||size!=sizeof(*out))return 0;
    *out={sizeof(*out),0x10000,2,6,1,123,456,1,1,100,1,1,30,1,1,2,0,0};return 1;
}
GSNL_EXPORT void* GetModuleHandleA(const char* name){return fixture_failure==1||std::strcmp(name,"skeet.dll")?nullptr:reinterpret_cast<void*>(1);}
GSNL_EXPORT void* GetProcAddress(void*,const char* name){
    if(fixture_failure==2)return nullptr;
#define ENTRY(symbol) if(!std::strcmp(name,#symbol))return reinterpret_cast<void*>(&symbol)
    ENTRY(gsnl_abi_version);ENTRY(gsnl_source);ENTRY(gsnl_snapshot);ENTRY(gsnl_length3);ENTRY(gsnl_dot3);ENTRY(gsnl_normalize_yaw);
#undef ENTRY
    return nullptr;
}
