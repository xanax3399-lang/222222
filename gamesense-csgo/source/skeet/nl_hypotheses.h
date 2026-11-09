#pragma once
#include <cstdint>
#include <cstddef>
#include <cmath>
#include <cstring>

// Finite-angle branch recovered from donor nl.bin, 0x41339870 / EDX==0.
// This is an animation-hypothesis addition, not a complete NL resolver.
namespace nl_hypotheses {
enum Mode : std::uint32_t { Stock = 0, NlAnimation = 1, NlPoints = 2, NlCombined = 3, V3Patches = 6, StockResolver = 8 };
inline bool valid_mode(std::uint32_t mode){return mode<=NlCombined||mode==V3Patches||mode==StockResolver;}
struct Status {
    std::uint32_t version, mode;
    volatile std::int32_t installed, calls, changed, rejected;
    volatile std::int32_t last_variant, last_tick;
    volatile std::int32_t last_input_bits, last_output_bits;
};
static_assert(sizeof(Status)==40);
inline std::uint32_t selected_mode=Stock;

inline float normalize(float angle) {
    float value=static_cast<float>(std::fmod(static_cast<double>(angle),360.0));
    if(value>180.0f)value=value+-360.0f;
    if(value< -180.0f)value=value+360.0f;
    return value;
}
inline bool donor_yaw(float yaw,std::uint32_t variant,float& output) {
    if(variant==0)return false;
    if(variant==1)yaw=yaw+60.0f;
    else if(variant==2)yaw=yaw+-60.0f;
    else if(variant==3)yaw=yaw+-30.0f;
    output=normalize(yaw);return true;
}
// Explicit adapter policy: retain GS ordering (positive, middle, negative).
// The donor no-history branch supplies +60, -30, -60 in that order. Keep the
// native GS animation range that was already computed at this exact call.
inline bool adapt(float eye_yaw,unsigned gs_variant,float low,float high,float& output) {
    if(gs_variant>=3||!std::isfinite(eye_yaw)||std::fabs(eye_yaw)>7200.f||
       !std::isfinite(low)||!std::isfinite(high)||low>0||high<0||low< -180||high>180)return false;
    constexpr unsigned variants[]={1,3,2};float yaw=0;
    if(!donor_yaw(eye_yaw,variants[gs_variant],yaw))return false;
    float difference=normalize(yaw-normalize(eye_yaw));
    if(difference<low)difference=low;
    if(difference>high)difference=high;
    output=normalize(eye_yaw+difference);return true;
}
inline std::uint32_t read_u32(const void* p,std::size_t off) {
    std::uint32_t value;std::memcpy(&value,static_cast<const unsigned char*>(p)+off,4);return value;
}
inline float f32(const void* p,std::size_t off) {
    float value;std::memcpy(&value,static_cast<const unsigned char*>(p)+off,4);return value;
}
// All seven direct internal callers of the original pose-alternative builder.
inline bool known_caller(std::uint32_t address) {
    switch(address) {
    case 0x43345e34:case 0x4336a702:case 0x4336d838:case 0x43387cf7:
    case 0x43398e1b:case 0x43416476:case 0x4341672b:return true;
    default:return false;
    }
}
}

#ifdef _WIN32
extern "C" __declspec(dllexport) nl_hypotheses::Status skeet_nl_hypotheses_status;
#endif
