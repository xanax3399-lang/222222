#pragma once
#include <cmath>
#include <cstdint>
#include <limits>

#if defined(GSNL_API_DECL_ONLY)
#define GSNL_EXPORT extern "C"
#elif defined(_WIN32)
#define GSNL_EXPORT extern "C" __declspec(dllexport)
#else
#define GSNL_EXPORT extern "C" __attribute__((visibility("default")))
#endif

// Fixed-width, read-only diagnostic ABI. Values are individually sampled,
// not a synchronized game-state snapshot. Counts do not measure accuracy.
struct GsnlSnapshot {
    std::uint32_t size,abi,loader_state,mode;
    std::uint32_t points_installed,points_calls,points_added;
    std::uint32_t brake_enabled,brake_installed,brake_applied;
    std::uint32_t crown_enabled,crown_installed,crown_added;
    std::uint32_t fire_installed,guard_enabled,guard_canceled;
    std::uint32_t recharge_enabled,recharge_overrides;
};
static_assert(sizeof(GsnlSnapshot)==72);
GSNL_EXPORT unsigned gsnl_abi_version();
GSNL_EXPORT const char* gsnl_source(unsigned* length);
GSNL_EXPORT int gsnl_snapshot(GsnlSnapshot* output,unsigned size);
GSNL_EXPORT double gsnl_length3(double x,double y,double z);
GSNL_EXPORT double gsnl_dot3(double x,double y,double z,double a,double b,double c);
GSNL_EXPORT double gsnl_normalize_yaw(double yaw);

// Explicit bridge capability table. GS removes ffi.load and external ffi.C
// resolution; the Lua loader discovers this table in our already loaded DLL.
struct GsnlApiTable {
    char magic[16];
    std::uint32_t abi,size;
    unsigned (*version)();
    const char* (*source)(unsigned*);
    int (*snapshot)(GsnlSnapshot*,unsigned);
    double (*length3)(double,double,double);
    double (*dot3)(double,double,double,double,double,double);
    double (*normalize_yaw)(double);
};
static_assert(sizeof(GsnlApiTable)==(sizeof(void*)==4?48:72));
GSNL_EXPORT const GsnlApiTable gsnl_api_table;
#define GSNL_TABLE_INITIALIZER {{'G','S','N','L','_','A','P','I','_','V','1','_','T','A','B','!'}, \
    0x10000u,sizeof(GsnlApiTable),gsnl_abi_version,gsnl_source,gsnl_snapshot,gsnl_length3,gsnl_dot3,gsnl_normalize_yaw}

#ifdef GSNL_IMPLEMENT_MATH
GSNL_EXPORT unsigned gsnl_abi_version(){return 0x10000u;}
GSNL_EXPORT double gsnl_length3(double x,double y,double z){return std::hypot(x,y,z);}
GSNL_EXPORT double gsnl_dot3(double x,double y,double z,double a,double b,double c){return x*a+y*b+z*c;}
GSNL_EXPORT double gsnl_normalize_yaw(double yaw){
    if(!std::isfinite(yaw))return std::numeric_limits<double>::quiet_NaN();
    double result=std::fmod(yaw+180.0,360.0);
    if(result<0.0)result+=360.0;
    return result-180.0;
}
#endif
