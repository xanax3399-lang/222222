#pragma once
#include <cstddef>
#include <cstdint>
namespace core_image {
inline constexpr std::uint32_t image_base=0x43310000;
inline constexpr std::size_t image_size=0x2fc000;
// Pinned to the supplied, unmodified Binary/skeet.bin, not skeet_cv.bin.
inline constexpr std::uint64_t image_fingerprint=0xfccb1ee3ec02b498ULL;
inline bool matches_original(const void* data, std::size_t size) {
    if (!data || size != image_size) return false;
    auto* bytes = static_cast<const std::uint8_t*>(data);
    std::uint64_t hash = 0xcbf29ce484222325ULL;
    for (std::size_t i = 0; i < size; ++i) hash = (hash ^ bytes[i]) * 0x100000001b3ULL;
    // Compatibility fingerprint; this is not a cryptographic integrity check.
    return hash == image_fingerprint;
}

}
