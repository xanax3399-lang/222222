#define NOMINMAX
#include "accuracy_patch.h"
#define API extern "C" __declspec(dllexport)
API native_accuracy::Status sr_accuracy_status={1,1,1,0};
API bool accuracy_prepare(unsigned char* image,unsigned size,unsigned mode,unsigned check,unsigned brake) {
    nl_hypotheses::selected_mode=mode;sr_accuracy_status.check_enabled=check;sr_accuracy_status.brake_enabled=brake;
    return native_accuracy::apply(image,size);
}
