#pragma once
#include <windows.h>
namespace v3_patches {
struct Status {
    unsigned version,head_enabled,crown_percent,mode;
    volatile LONG installed,head_calls,considered,added,filtered,duplicates,geometry_fallback;
};
static_assert(sizeof(Status)==44);
}
