#pragma once
#include <cstring>
#include <cstdint>
namespace nl_points_mean {
inline constexpr unsigned site=0x4ea97,continuation=0x4335ea9f;
inline constexpr unsigned char original[]={0x83,0xa4,0x24,0x60,2,0,0,0};
struct Plan {unsigned char code[128]{},jump[8]{};unsigned length{};};
inline bool compatible(const unsigned char* image) {
    constexpr unsigned char next[]={0xf3,0x0f,0x11,0xb4,0x24,0x54,2,0,0};
    return !std::memcmp(image+site,original,8)&&!std::memcmp(image+site+8,next,sizeof(next));
}
inline Plan make(unsigned location,unsigned callback) {
    Plan p{};unsigned n=0;
    const auto dword=[&](unsigned value){std::memcpy(p.code+n,&value,4);n+=4;};
    // Preserve complete flags/GPR/x87/SSE state; callback edits only the three
    // low XMM lanes holding the primary center used by the native caller.
    constexpr unsigned char save[]={0x9c,0x60,0x89,0xe6,0x81,0xec,0x10,2,0,0,
        0x83,0xe4,0xf0,0x0f,0xae,4,0x24,0xdb,0xe3,0x68,0x80,0x1f,0,0,
        0x0f,0xae,0x14,0x24,0x83,0xc4,4,0x89,0xe7,0xfc,0x83,0xec,8,0x57,0x56,0xb8};
    std::memcpy(p.code,save,sizeof(save));n=sizeof(save);dword(callback);
    constexpr unsigned char restore[]={0xff,0xd0,0x83,0xc4,0x10,0x0f,0xae,0x0f,0x89,0xf4,0x61,0x9d};
    std::memcpy(p.code+n,restore,sizeof(restore));n+=sizeof(restore);
    std::memcpy(p.code+n,original,8);n+=8;
    p.code[n++]=0xe9;dword(continuation-(location+n+4));p.length=n;
    std::memset(p.jump,0x90,8);p.jump[0]=0xe9;
    const unsigned displacement=location-(0x43310000+site+5);
    std::memcpy(p.jump+1,&displacement,4);return p;
}
}
