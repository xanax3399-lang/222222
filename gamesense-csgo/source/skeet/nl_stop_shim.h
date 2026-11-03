#pragma once
#include <cstring>
namespace nl_stop_shim {
inline constexpr unsigned site=0x786e4,continuation=0x433886ea,success=0x433886f8;
inline constexpr unsigned char original[]={0xf3,0x0f,0x10,0x44,0x24,0x0c};
struct Plan {unsigned char code[160]{},jump[6]{};unsigned length{};};
inline bool compatible(const unsigned char* image) {
    constexpr unsigned char next[]={0x0f,0x2f,0x44,0x24,0x1c,0x76,0x07,
        0xc7,0x46,0x24,0x6f,0x12,0x83,0x3a,0xb0,0x01};
    constexpr unsigned char call[]={0xe8,0xdc,0x42,0x02,0x00};
    return !std::memcmp(image+site,original,6)&&
           !std::memcmp(image+site+6,next,sizeof(next))&&
           !std::memcmp(image+site-5,call,sizeof(call));
}
inline Plan make(unsigned location,unsigned callback) {
    Plan p{};unsigned n=0;
    const auto dword=[&](unsigned value){std::memcpy(p.code+n,&value,4);n+=4;};
    constexpr unsigned char save[]={0x9c,0x60,0x89,0xe6,0x81,0xec,0x10,2,0,0,
        0x83,0xe4,0xf0,0x0f,0xae,4,0x24,0xdb,0xe3,0x68,0x80,0x1f,0,0,
        0x0f,0xae,0x14,0x24,0x83,0xc4,4,0x89,0xe7,0xfc,0x83,0xec,8,0x57,0x56,0xb8};
    std::memcpy(p.code,save,sizeof(save));n=sizeof(save);dword(callback);
    // cdecl callback(registers, fxsave); select the continuation before restoring
    // all GPR, flags and x87/SSE state. The callback only changes command memory.
    constexpr unsigned char decide[]={0xff,0xd0,0x83,0xc4,0x10,0x84,0xc0,0x74,23};
    constexpr unsigned char restore[]={0x0f,0xae,0x0f,0x89,0xf4,0x61,0x9d};
    std::memcpy(p.code+n,decide,sizeof(decide));n+=sizeof(decide);
    std::memcpy(p.code+n,restore,sizeof(restore));n+=sizeof(restore);
    // Reproduce the original return-side XMM0 and COMISS flags even when the
    // old 0.001 impulse write is bypassed. Callers see native machine state.
    constexpr unsigned char compare[]={0x0f,0x2f,0x44,0x24,0x1c};
    std::memcpy(p.code+n,original,6);n+=6;
    std::memcpy(p.code+n,compare,sizeof(compare));n+=sizeof(compare);
    p.code[n++]=0xe9;dword(success-(location+n+4));
    std::memcpy(p.code+n,restore,sizeof(restore));n+=sizeof(restore);
    std::memcpy(p.code+n,original,6);n+=6;
    p.code[n++]=0xe9;dword(continuation-(location+n+4));p.length=n;
    std::memset(p.jump,0x90,6);p.jump[0]=0xe9;
    const unsigned displacement=location-(0x43310000+site+5);
    std::memcpy(p.jump+1,&displacement,4);return p;
}
}
