#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include "../source/skeet/nl_points_patch.h"
#define API extern "C" __declspec(dllexport)
API nl_points_patch::Status skeet_nl_points_status={1,0,0,0,0,0,0,0,80,80,0};
API unsigned points_sealed_hash=0;
API unsigned points_bridge_address(){return reinterpret_cast<unsigned>(nl_points_patch::bridge);}
API bool points_prepare(unsigned char* image,unsigned size,unsigned mode) {
    nl_hypotheses::selected_mode=mode;
    if(!nl_points_patch::apply(image,size))return false;
    using Hash=unsigned(__fastcall*)(unsigned,unsigned);
    points_sealed_hash=reinterpret_cast<Hash>(0x4333d6a2)(0x4331e000,0x105b12);
    return true;
}
