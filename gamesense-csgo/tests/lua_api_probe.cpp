// Compile the production native Lua module with controlled counter fixtures.
#define GSNL_IMPLEMENT_MATH
#include "../source/api_bridge/native.h"
#include "../source/api_bridge/lua_native.h"
#include "embedded.h"
GSNL_EXPORT const GsnlApiTable gsnl_api_table=GSNL_TABLE_INITIALIZER;
GSNL_EXPORT const char* gsnl_source(unsigned* size){if(size)*size=sizeof(gsnl_embedded_source)-1;return gsnl_embedded_source;}
GSNL_EXPORT int gsnl_snapshot(GsnlSnapshot* out,unsigned size){
    if(!out||size!=sizeof(*out))return 0;
    *out={72,0x10000,2,6,1,123,456,1,1,100,1,1,30,1,1,2,0,0};return 1;
}
GSNL_EXPORT int lua_probe_apply(unsigned char* image,unsigned size){return gsnl_lua::apply(image,size);}
