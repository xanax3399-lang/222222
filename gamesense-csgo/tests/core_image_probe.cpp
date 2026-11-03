#include "../source/skeet/core_image.h"
// The production header, compiled for the same Windows x86 target as the DLL.
extern "C" __declspec(dllexport) int core_matches(const void* data, unsigned size) {
    return core_image::matches_original(data, size) ? 1 : 0;
}
