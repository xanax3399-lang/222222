#pragma once
#include <windows.h>
namespace nl_points_patch {
struct Status {
    unsigned version,mode;
    volatile LONG installed,calls,generated,fallback,filtered,pool_full;
    unsigned head_percent,body_percent,reduced_head;
    volatile LONG native_calls,kept,empty_fallback,centroid_restores;
    volatile LONG last_hitbox,last_original,last_added;
    volatile LONG head_kept,head_added;
};
static_assert(sizeof(Status)==80);
}
