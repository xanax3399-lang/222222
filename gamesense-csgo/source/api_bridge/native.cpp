#define GSNL_IMPLEMENT_MATH
#include "native.h"
#include "embedded.h"
#include "../loader_protocol.h"
#include "../skeet/nl_points_status.h"
#include "../skeet/nl_stop_status.h"
#include "../skeet/v3_status.h"
#include "../skeet/v3_fire_status.h"
extern "C" LoaderStatus skeet_loader_status;
extern "C" nl_points_patch::Status skeet_nl_points_status;
extern "C" nl_stop_patch::Status skeet_nl_stop_status;
extern "C" v3_patches::Status skeet_v3_status;
extern "C" v3_fire::Status skeet_v3_fire_status;

// Keep the unique descriptor in the PE text section so hosts which restrict
// signature scans to executable sections can still find it. It is immutable
// after normal loader relocations; no RWX allocation or runtime patch is used.
#if defined(__GNUC__) && defined(__i386__)
// GNU COFF otherwise gives allocated const data non-code section flags even
// with pragma section. Emit the small relocation table with explicit RX flags.
asm(".section .text$gsnl,\"xr\"\n"
    ".p2align 2\n.globl _gsnl_api_table\n_gsnl_api_table:\n"
    ".ascii \"GSNL_API_V1_TAB!\"\n.long 65536\n.long 48\n"
    ".long _gsnl_abi_version\n.long _gsnl_source\n.long _gsnl_snapshot\n"
    ".long _gsnl_length3\n.long _gsnl_dot3\n.long _gsnl_normalize_yaw\n.text\n");
#else
#pragma section(".text$gsnl", read, execute)
GSNL_EXPORT __declspec(allocate(".text$gsnl")) const GsnlApiTable gsnl_api_table=GSNL_TABLE_INITIALIZER;
#endif

GSNL_EXPORT const char* gsnl_source(unsigned* length){
    if(length)*length=sizeof(gsnl_embedded_source)-1;
    return gsnl_embedded_source;
}
GSNL_EXPORT int gsnl_snapshot(GsnlSnapshot* output,unsigned size){
    if(!output||size!=sizeof(GsnlSnapshot))return 0;
    const auto sample=[](volatile LONG& value){
        return static_cast<std::uint32_t>(InterlockedCompareExchange(&value,0,0));
    };
    const auto& points=skeet_nl_points_status;
    const auto& brake=skeet_nl_stop_status;
    const auto& crown=skeet_v3_status;
    const auto& fire=skeet_v3_fire_status;
    const GsnlSnapshot snapshot={sizeof(GsnlSnapshot),0x10000u,
        sample(skeet_loader_status.state),fire.mode,
        static_cast<unsigned>(points.installed),static_cast<unsigned>(points.calls),static_cast<unsigned>(points.generated),
        brake.enabled,static_cast<unsigned>(brake.installed),static_cast<unsigned>(brake.applied),
        crown.head_enabled,static_cast<unsigned>(crown.installed),static_cast<unsigned>(crown.added),
        static_cast<unsigned>(fire.installed),fire.guard_enabled,static_cast<unsigned>(fire.canceled),
        fire.recharge_enabled,static_cast<unsigned>(fire.recharge_overrides)};
    *output=snapshot;return 1;
}
