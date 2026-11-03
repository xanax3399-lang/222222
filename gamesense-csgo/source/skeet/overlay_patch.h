#pragma once
#include <cstddef>
#include <cstdint>

namespace overlay_patch {
inline constexpr int return_pattern[] = {
    0x3d,-1,-1,-1,-1,0x73,0x1a,0x68,-1,-1,-1,-1,0xe8,-1,-1,-1,-1,
    0x8b,0x0d,-1,-1,-1,-1,0x83,0xc4,0x04,0x8b,0x01,0x6a,0x00,
    0xff,0x50,0x14,0x3b,-1,0x3c
};
inline constexpr int reference_pattern[] = {
    0x89,0x1d,-1,-1,-1,-1,0xf3,0x0f,0x10,0x83
};
struct Matches { std::size_t offset = 0, count = 0; };
template<std::size_t N>
Matches find(const std::uint8_t* data, std::size_t size, const int (&pattern)[N]) {
    Matches result;
    if (!data || size < N || N == 0) return result;
    for (std::size_t i = 0; i <= size - N; ++i) {
        bool equal = true;
        for (std::size_t j = 0; j < N; ++j) {
            if (pattern[j] >= 0 && data[i+j] != pattern[j]) { equal = false; break; }
        }
        if (equal) {
            result.offset = i;
            if (++result.count == 2) break; // Ambiguous signatures must fail.
        }
    }
    return result;
}
inline bool patch_calls(std::uint8_t* image, std::size_t size) {
    constexpr std::size_t a = 0x741a7, b = 0x741bc;
    if (!image || size < b + 3) return false;
    if (image[a] != 0xff || image[a+1] != 0x50 ||
        image[b] != 0xff || image[b+1] != 0x50) return false;
    const bool original = image[a+2] == 0x24 && image[b+2] == 0x28;
    const bool updated = image[a+2] == 0x28 && image[b+2] == 0x2c;
    if (!original && !updated) return false;
    image[a+2] = 0x28;
    image[b+2] = 0x2c;
    return true;
}
}
