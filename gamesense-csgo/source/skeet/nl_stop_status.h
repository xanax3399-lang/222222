#pragma once
#include <windows.h>
namespace nl_stop_patch {
struct Status {
    unsigned version,enabled,mode;
    volatile LONG installed,calls,applied,fallback,last_grounded;
    float speed,max_speed,accelerate,interval,before,after;
};
static_assert(sizeof(Status)==56);
}
