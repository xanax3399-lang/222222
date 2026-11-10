#pragma once
#include <windows.h>
namespace stock_native {
struct BootstrapStatus {
    unsigned version,phase,polls,ready_mask,client,engine,entities,time,interval,entry,slot,core_globals,original_changed,callbacks;
};
static_assert(sizeof(BootstrapStatus)==56);
}
extern "C" __declspec(dllexport) stock_native::BootstrapStatus sr_bootstrap_status;
