#pragma once
namespace stock_native {
struct YawProperty {char table[48],name[64];int type,offset,elements,stride;};
struct YawStatus {unsigned version,ready,method;int offset;unsigned count,truncated;YawProperty properties[16];};
static_assert(sizeof(YawProperty)==128&&sizeof(YawStatus)==2072);
}
#ifdef _WIN32
#include <windows.h>
extern "C" __declspec(dllexport) stock_native::YawStatus sr_yaw_status;
#endif
