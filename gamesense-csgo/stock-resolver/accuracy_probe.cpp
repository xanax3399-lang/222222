#define NOMINMAX
#include "accuracy_patch.h"
#define API extern "C" __declspec(dllexport)
API native_accuracy::Status sr_accuracy_status={1,1,1,0};
API native_accuracy::DtStatus sr_dt_status={1,0,0};
API native_accuracy::DtFastStatus sr_dt_fast_status={1,1,1,0};
API bool accuracy_prepare(unsigned char* image,unsigned size,unsigned mode,unsigned check,unsigned brake) {
    nl_hypotheses::selected_mode=mode;sr_accuracy_status.check_enabled=check;sr_accuracy_status.brake_enabled=brake;
    return native_accuracy::apply(image,size);
}

API bool accuracy_dt_prepare(unsigned char* image,unsigned size,unsigned mode,unsigned enabled) {sr_dt_status.enabled=enabled;return accuracy_prepare(image,size,mode,1,0);}

API bool accuracy_dt_fast_prepare(unsigned char* image,unsigned size,unsigned mode,unsigned enabled,unsigned fast) {sr_dt_fast_status.enabled=fast;return accuracy_dt_prepare(image,size,mode,enabled);}
