#pragma once
#include <windows.h>
namespace native_accuracy {
struct DtStatus {
    unsigned version,enabled,mode;
    volatile LONG installed,calls,boosted,already_full,fallback;
    LONG last_command,last_weapon,last_before,last_after;
};
static_assert(sizeof(DtStatus)==48,"DT sampler diagnostic ABI");
}
extern "C" __declspec(dllexport) native_accuracy::DtStatus sr_dt_status;
