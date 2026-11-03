#pragma once
#include <windows.h>
namespace v3_fire {
struct Status {
    unsigned version,guard_enabled,recharge_enabled,mode;
    volatile LONG installed,commands,dt_releases,guard_calls,unchanged,rechecks,
        canceled,dt_bypass,manual_bypass,fallback,recharge_checks,recharge_overrides;
    LONG last_command,last_dt_mode,last_charge,last_desired;
    float last_probability;
};
static_assert(sizeof(Status)==84,"Stable v3 fire diagnostic ABI");
}
