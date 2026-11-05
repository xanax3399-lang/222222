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
