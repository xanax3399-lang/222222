#pragma once
#include "dt_status.h"
#include "dt_fast_status.h"
#include <cstddef>
#include <cstring>
#include <initializer_list>

namespace native_accuracy {
// Immutable identity of one approved HC call, carried on its own stack.
// No global current-call token, TLS lookup or floating-point state is needed.
struct DtScope {unsigned context,command,number,weapon,candidate,hc_context;};
static_assert(sizeof(DtScope)==24);
}

namespace dt_fast_shim {
struct Plan {unsigned char code[512]{},gate[32]{},jump[8]{};unsigned length{},gate_length{},return_address{};};
inline Plan make(unsigned location,unsigned gate,unsigned status) {
    Plan p{};unsigned n=0;
    const auto b=[&](unsigned char value){p.code[n++]=value;};
    const auto d=[&](unsigned value){std::memcpy(p.code+n,&value,4);n+=4;};
    const auto raw=[&](const unsigned char* data,unsigned count){std::memcpy(p.code+n,data,count);n+=count;};
    // __fastcall(context ECX, scope EDX, weapon, candidate, probability).
    // Keep scope below the native arguments: HC's EBP+14 points to it.
    const unsigned char gate_code[]={0x52,0xff,0x74,0x24,0x10,0xff,0x74,0x24,0x10,0xff,0x74,0x24,0x10,0xe8};
    std::memcpy(p.gate,gate_code,sizeof(gate_code));
    const unsigned call_delta=0x4341b4c2-(gate+18);std::memcpy(p.gate+14,&call_delta,4);
    const unsigned char tail[]={0x83,0xc4,4,0xc2,0x0c,0};std::memcpy(p.gate+18,tail,sizeof(tail));
    p.gate_length=24;p.return_address=gate+18;
    // All instructions below are integer-only. Preserve all GPRs and flags;
    // XMM/x87/MXCSR are never touched. Native XOR/MOVZX are replayed last.
    b(0x9c);b(0x60);
    unsigned failures[12]{},count=0;
    const auto jcc=[&](unsigned char condition){b(0x0f);b(condition);failures[count++]=n;d(0);};
    const auto inc=[&](unsigned offset){b(0xf0);b(0xff);b(0x05);d(status+offset);};
    const auto store_edx=[&](unsigned offset){b(0x89);b(0x15);d(status+offset);};
    // Reject ordinary native calls before touching the extra scope slot.
    b(0x81);b(0x7d);b(4);d(p.return_address);
    b(0x0f);b(0x85);const unsigned foreign=n;d(0);
    const unsigned char identity[]={0x8b,0x45,0x14,0x3b,0x70,0x0c};raw(identity,sizeof(identity));jcc(0x85);
    const unsigned char candidate[]={0x3b,0x78,0x10};raw(candidate,sizeof(candidate));jcc(0x85);
    const unsigned char context[]={0x8b,0x54,0x24,0x58,0x3b,0x50,0x14};raw(context,sizeof(context));jcc(0x85);
    const unsigned char owner[]={0x8b,0x08,0x81,0x39};raw(owner,sizeof(owner));d(0x4346edd4);jcc(0x85);
    const unsigned char mode[]={0x83,0xb9,0xf4,0,0,0,1,0x0f,0x84};raw(mode,sizeof(mode));const unsigned active=n;d(0);
    const unsigned char idle[]={0x83,0xb9,0xf4,0,0,0,0};raw(idle,sizeof(idle));jcc(0x85);
    const unsigned char pending[]={0xf6,0x41,0x14,8};raw(pending,sizeof(pending));jcc(0x84);
    const unsigned active_target=n;
    const unsigned active_delta=active_target-(active+4);std::memcpy(p.code+active,&active_delta,4);
    const unsigned char command[]={0x8b,0x50,4,0x8b,0x52,4,0x3b,0x50,8};raw(command,sizeof(command));jcc(0x85);
    store_edx(offsetof(native_accuracy::DtStatus,last_command));
    const unsigned char weapon[]={0x8b,0x96,0xd8,0,0,0,0x83,0xfa,11,0x0f,0x84};raw(weapon,sizeof(weapon));const unsigned weapon_ok=n;d(0);
    b(0x83);b(0xfa);b(38);jcc(0x85);
    const unsigned weapon_delta=n-(weapon_ok+4);std::memcpy(p.code+weapon_ok,&weapon_delta,4);
    store_edx(offsetof(native_accuracy::DtStatus,last_weapon));
    const unsigned char tier[]={0x8b,0x54,0x24,0x34,0x83,0xfa,32,0x0f,0x84};raw(tier,sizeof(tier));const unsigned reduced=n;d(0);
    b(0x83);b(0xfa);b(64);jcc(0x85);
    inc(offsetof(native_accuracy::DtStatus,already_full));b(0xe9);const unsigned full=n;d(0);
    const unsigned reduced_delta=n-(reduced+4);std::memcpy(p.code+reduced,&reduced_delta,4);
    const unsigned char promote[]={0xc7,0x44,0x24,0x34,64,0,0,0};raw(promote,sizeof(promote));
    inc(offsetof(native_accuracy::DtStatus,boosted));
    const unsigned full_delta=n-(full+4);std::memcpy(p.code+full,&full_delta,4);
    store_edx(offsetof(native_accuracy::DtStatus,last_before));
    b(0xc7);b(0x05);d(status+offsetof(native_accuracy::DtStatus,last_after));d(64);
    inc(offsetof(native_accuracy::DtStatus,calls));b(0xe9);const unsigned done=n;d(0);
    const unsigned fallback=n;inc(offsetof(native_accuracy::DtStatus,fallback));
    const unsigned replay=n;
    for(unsigned i=0;i<count;++i){const unsigned delta=fallback-(failures[i]+4);std::memcpy(p.code+failures[i],&delta,4);}
    for(unsigned at: {foreign,done}){const unsigned delta=replay-(at+4);std::memcpy(p.code+at,&delta,4);}
    const unsigned char restore[]={0x61,0x9d,0x33,0xd2,0x0f,0xb6,0x4c,0x24,0x0b};raw(restore,sizeof(restore));
    b(0xe9);d(0x4341bc07-(location+n+4));p.length=n;
    std::memset(p.jump,0x90,7);p.jump[0]=0xe9;const unsigned delta=location-0x4341bc00-5;std::memcpy(p.jump+1,&delta,4);
    return p;
}
}
