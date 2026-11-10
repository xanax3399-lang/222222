#pragma once
#include <windows.h>
namespace native_accuracy {
struct DtFastStatus {
    unsigned version,enabled,profiling;
    volatile LONG installed,samples,last_us,worst_us,slow_samples,last_hc_calls,peak_hc_calls;
};
static_assert(sizeof(DtFastStatus)==40,"DT fast sampler diagnostic ABI");
}
extern "C" __declspec(dllexport) native_accuracy::DtFastStatus sr_dt_fast_status;
