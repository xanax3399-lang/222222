#pragma once
#include <windows.h>
#include "model.h"
namespace stock_native {
enum State : unsigned { Off=0,Prepared=1,Waiting=2,Active=3,Failed=4 };
enum Error : unsigned { None=0,CoreContract=1,ClientInterface=2,Netvars=3,WaitHook=4,Protect=5,HookLost=6,InvalidInput=7 };
struct DriverStatus {
    unsigned version,enabled,state,error,installed,callbacks,updates,frames;
    unsigned tracked,applied,blocked,invalid_controls,netvar_mask,previous,client,slot;
    unsigned feeds,records,duplicates,rejected,selected,fallback,memory_bytes;
    float threshold,last_update_ms,worst_update_ms;
};
static_assert(sizeof(DriverStatus)==104);
stock_resolver::Engine& shared_engine();
bool prepare(unsigned char* image,unsigned size,HMODULE module);
bool start();
const char* last_error();
}
extern "C" __declspec(dllexport) stock_native::DriverStatus sr_driver_status;
