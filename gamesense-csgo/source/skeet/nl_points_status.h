#pragma once
#include <windows.h>
namespace nl_points_patch {
struct Status {
    unsigned version,mode;
    volatile LONG installed,calls,generated,fallback,filtered,pool_full;
    unsigned head_percent,body_percent,reduced_head;
};
static_assert(sizeof(Status)==44);
}
