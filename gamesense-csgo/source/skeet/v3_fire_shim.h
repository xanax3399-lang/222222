#pragma once
#include <cstring>
namespace v3_fire_shim {
struct Plan {unsigned char code[192]{},jump[8]{};unsigned length{};};
// All hooks run inside an already aligned native frame. Restore its complete
// x87/SSE/GPR/flags state before replaying instructions or taking an alternative.
inline Plan make(unsigned location,unsigned site,const unsigned char* replay,
                 unsigned count,unsigned normal,unsigned alternative,unsigned callback,
                 unsigned original_call=0) {
    Plan p{};unsigned n=0;
    const auto bytes=[&](const unsigned char* b,unsigned size){std::memcpy(p.code+n,b,size);n+=size;};
    const auto dword=[&](unsigned v){std::memcpy(p.code+n,&v,4);n+=4;};
    const auto branch=[&](unsigned target,unsigned char op){p.code[n++]=op;const unsigned next=location+n+4;dword(target-next);};
    constexpr unsigned char save[]={0x9c,0x60,0x89,0xe6,0x81,0xec,0x10,2,0,0,
        0x83,0xe4,0xf0,0x0f,0xae,4,0x24,0xdb,0xe3,0x68,0x80,0x1f,0,0,
        0x0f,0xae,0x14,0x24,0x83,0xc4,4,0x89,0xe7,0xfc,0x83,0xec,8,0x57,0x56,0xb8};
    constexpr unsigned char restore[]={0x0f,0xae,0x0f,0x89,0xf4,0x61,0x9d};
    bytes(save,sizeof(save));dword(callback);
    constexpr unsigned char call[]={0xff,0xd0,0x83,0xc4,0x10,0x84,0xc0,0x74,12};
    bytes(call,sizeof(call));bytes(restore,sizeof(restore));branch(alternative,0xe9);
    bytes(restore,sizeof(restore));
    if(original_call)branch(original_call,0xe8);else bytes(replay,count);
    branch(normal,0xe9);p.length=n;
    std::memset(p.jump,0x90,count);p.jump[0]=0xe9;
    const unsigned displacement=location-site-5;std::memcpy(p.jump+1,&displacement,4);
    return p;
}
}
