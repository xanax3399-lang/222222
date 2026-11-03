#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include "../source/skeet/nl_stop_patch.h"
#define API extern "C" __declspec(dllexport)
API nl_stop_patch::Status skeet_nl_stop_status={1,1,0};
API unsigned stop_sealed_hash=0;
API bool stop_prepare(unsigned char* image,unsigned size,unsigned mode,unsigned enabled) {
    nl_hypotheses::selected_mode=mode;skeet_nl_stop_status.enabled=enabled;
    if(!nl_stop_patch::apply(image,size))return false;
    using Hash=unsigned(__fastcall*)(unsigned,unsigned);
    stop_sealed_hash=reinterpret_cast<Hash>(0x4333d6a2)(0x4331e000,0x105b12);
    return true;
}
