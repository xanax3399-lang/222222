#pragma once
#include <windows.h>
namespace native_accuracy {
struct Status {
    unsigned version,check_enabled,brake_enabled,mode;
    volatile LONG installed,commands,dt_releases,guard_calls,unchanged,rechecks,
        canceled,dt_bypass,manual_bypass,fast_bypass,unsupported,fallback,
        geometry_changed,precision_changed,brake_calls,brake_applied,brake_fallback;
    LONG last_command,last_weapon;
    float last_probability,last_effective,last_threshold,speed,wish,before,after;
};
static_assert(sizeof(Status)==120,"Native accuracy diagnostic ABI");
}
extern "C" __declspec(dllexport) native_accuracy::Status sr_accuracy_status;
