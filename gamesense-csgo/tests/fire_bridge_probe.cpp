#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include "../source/skeet/v3_fire_patch.h"
#define API extern "C" __declspec(dllexport)
API v3_fire::Status skeet_v3_fire_status={1,1,1,0};
API bool fire_prepare(unsigned char* image,unsigned size,unsigned mode,unsigned guard,unsigned recharge) {
    nl_hypotheses::selected_mode=mode;
    skeet_v3_fire_status.guard_enabled=guard;skeet_v3_fire_status.recharge_enabled=recharge;
    return v3_fire::apply(image,size);
}
