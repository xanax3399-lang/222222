#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <windows.h>
#define EXPORT extern "C" __declspec(dllexport)
#else
#define EXPORT extern "C"
#endif
#include "../source/skeet/nl_hypotheses_patch.h"
#ifdef _WIN32
#include "../source/skeet/crash_report.h"
extern "C" __declspec(dllexport) nl_hypotheses::Status skeet_nl_hypotheses_status={1,0,0,0,0,0,-1,0,0,0};
extern "C" __declspec(dllexport) nl_points_patch::Status skeet_nl_points_status={1,0,0,0,0,0,0,0,80,80,0};
EXPORT void probe_crash_initialize(unsigned module){crash_report::initialize(reinterpret_cast<HMODULE>(module));}
EXPORT bool probe_crash_snapshot(unsigned code,unsigned eip,unsigned ecx,unsigned esp,unsigned kind,unsigned target) {
    CONTEXT context{};context.Eip=eip;context.Ecx=ecx;context.Esp=esp;context.Ebp=esp+0x200;
    context.Eax=0x12345678;context.Ebx=0x87654321;context.EFlags=0x202;
    EXCEPTION_RECORD exception{};exception.ExceptionCode=code;exception.NumberParameters=2;
    exception.ExceptionInformation[0]=kind;exception.ExceptionInformation[1]=target;
    EXCEPTION_POINTERS pointers{&exception,&context};return crash_report::write(&pointers);
}
extern "C" __declspec(dllexport) unsigned probe_sealed_hash=0,probe_seal_calls=0;
EXPORT bool probe_prepare(unsigned char* image,unsigned size,unsigned mode) {
    nl_hypotheses::selected_mode=mode;
    return nl_hypotheses_patch::prepare(image,size,[] {
        ++probe_seal_calls;
        using Hash=unsigned(__fastcall*)(unsigned,unsigned);
        probe_sealed_hash=reinterpret_cast<Hash>(0x4333d6a2)(0x4331e000,0x105b12);
    });
}
EXPORT const char* probe_install_error(){return nl_hypotheses_patch::last_error();}
EXPORT void probe_bridge(unsigned char* registers,unsigned char* fx) {
    nl_hypotheses_patch::bridge(registers,fx);
}
#endif
EXPORT bool probe_donor(float yaw,unsigned variant,float* output) {
    return nl_hypotheses::donor_yaw(yaw,variant,*output);
}
EXPORT bool probe_adapt(float yaw,unsigned variant,float low,float high,float* output) {
    return nl_hypotheses::adapt(yaw,variant,low,high,*output);
}
EXPORT bool probe_plan(const unsigned char* image,unsigned size,unsigned address,unsigned callback,
                       nl_hypotheses_patch::Plan* plan) {
    return nl_hypotheses_patch::make(image,size,address,callback,*plan);
}
EXPORT bool probe_caller(unsigned address) {return nl_hypotheses::known_caller(address);}
