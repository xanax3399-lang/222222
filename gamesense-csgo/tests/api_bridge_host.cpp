// Linux LuaJIT contract fixture. Shares production native math and embedded
// source. Process/module discovery and counter values are controlled fixtures.
#define GSNL_IMPLEMENT_MATH
#include "../source/api_bridge/native.h"
#include "embedded.h"
#include <cstring>
static int fixture_failure=0;
GSNL_EXPORT void gsnl_fixture_failure(int value){fixture_failure=value;}
GSNL_EXPORT const GsnlApiTable gsnl_api_table=GSNL_TABLE_INITIALIZER;
GSNL_EXPORT const GsnlApiTable* gsnl_fixture_table(){
    static GsnlApiTable invalid{};
    if(fixture_failure==1)return nullptr;
    if(fixture_failure==2){invalid=gsnl_api_table;invalid.magic[0]='X';return &invalid;}
    if(fixture_failure==3){invalid=gsnl_api_table;invalid.source=nullptr;return &invalid;}
    return &gsnl_api_table;
}
GSNL_EXPORT const char* gsnl_source(unsigned* size){if(size)*size=sizeof(gsnl_embedded_source)-1;return gsnl_embedded_source;}
GSNL_EXPORT int gsnl_snapshot(GsnlSnapshot* out,unsigned size){
    if(!out||size!=sizeof(*out))return 0;
    *out={sizeof(*out),0x10000,2,6,1,123,456,1,1,100,1,1,30,1,1,2,0,0};return 1;
}
