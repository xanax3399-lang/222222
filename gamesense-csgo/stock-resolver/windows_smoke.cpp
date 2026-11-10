#define NOMINMAX
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <string>
#include "model.h"
#include "../source/loader_protocol.h"
#include "../source/skeet/nl_stop_status.h"
#include "../source/skeet/v3_fire_status.h"
#include "native_driver.h"
#include "accuracy_status.h"
#include "dt_status.h"
#include "dt_fast_status.h"
#include "feedback_status.h"
#include <filesystem>
using namespace stock_resolver;
static unsigned checks=0;
static void check(bool value,const char* label){++checks;if(!value){std::fprintf(stderr,"FAIL: %s (Win32 %lu)\n",label,GetLastError());std::exit(1);}}
template<class F> F symbol(HMODULE module,const char* name) {
    auto value=GetProcAddress(module,name);check(value!=nullptr,name);
    return reinterpret_cast<F>(value);
}
int wmain(int argc,wchar_t** argv) {
    if(argc!=3)return 2;
    HMODULE module=LoadLibraryW(argv[1]);check(module!=nullptr,"actual packaged DLL loads");
    auto version=symbol<unsigned(*)()>(module,"sr_abi_version");
    auto snapshot_size=symbol<unsigned(*)()>(module,"sr_snapshot_bytes");
    auto decision_size=symbol<unsigned(*)()>(module,"sr_decision_bytes");
    auto mode=symbol<unsigned(*)()>(module,"sr_mode_enabled");
    auto reset=symbol<void(*)()>(module,"sr_reset");
    auto feed=symbol<unsigned(*)(const Snapshot*,float,Decision*)>(module,"sr_feed");
    auto stats=symbol<void(*)(Stats*)>(module,"sr_stats");
    auto history=symbol<unsigned(*)(unsigned,Snapshot*,unsigned)>(module,"sr_history");
    auto hit=symbol<unsigned(*)(unsigned,unsigned,unsigned)>(module,"sr_head_hit");
    auto forget=symbol<void(*)(unsigned)>(module,"sr_forget");
    auto frame=symbol<void(*)(float)>(module,"sr_frame");
    auto frames=symbol<void(*)(FrameStats*)>(module,"sr_frame_stats");
    auto* driver=reinterpret_cast<stock_native::DriverStatus*>(GetProcAddress(module,"sr_driver_status"));
    check(driver&&driver->version==1&&driver->installed==0,"integrated native driver export");
    auto* accuracy=reinterpret_cast<native_accuracy::Status*>(GetProcAddress(module,"sr_accuracy_status"));
    check(accuracy&&accuracy->version==1&&accuracy->check_enabled==1&&accuracy->brake_enabled==1&&!accuracy->installed,"integrated accuracy settings/export");
    check(version()==0x00010001&&snapshot_size()==sizeof(Snapshot)&&decision_size()==sizeof(Decision),"x86 C ABI sizes");
    Sleep(200);
    auto* dt=reinterpret_cast<native_accuracy::DtStatus*>(GetProcAddress(module,"sr_dt_status"));
    check(dt&&dt->version==1&&dt->enabled==1&&!dt->installed,"DT sampler configuration/export");
    auto* fast=reinterpret_cast<native_accuracy::DtFastStatus*>(GetProcAddress(module,"sr_dt_fast_status"));
    check(fast&&fast->version==1&&fast->enabled==1&&fast->profiling==1&&!fast->installed&&!fast->samples,"DT fast sampler configuration/export");
    auto* feedback=reinterpret_cast<stock_feedback::Status*>(GetProcAddress(module,"sr_feedback_status"));
    auto* log=reinterpret_cast<stock_feedback::Log*>(GetProcAddress(module,"sr_feedback_log"));
    check(feedback&&feedback->version==1&&feedback->enabled==1&&feedback->learning==1&&!feedback->installed&&log&&log->version==1&&log->count==256,"native shot feedback exports");
    auto* loader=reinterpret_cast<LoaderStatus*>(GetProcAddress(module,"skeet_loader_status"));
    check(loader&&loader->state==LoaderWaiting&&mode()==0,"no game modules: waiting, bridge disabled");
    auto* stop=reinterpret_cast<nl_stop_patch::Status*>(GetProcAddress(module,"skeet_nl_stop_status"));
    auto* fire=reinterpret_cast<v3_fire::Status*>(GetProcAddress(module,"skeet_v3_fire_status"));
    check(stop&&fire&&stop->enabled==0&&fire->guard_enabled==0&&fire->recharge_enabled==0,"stock distribution configuration read");
    reset();Decision decision{};Snapshot sample{};
    sample.player=2;sample.identity=42;sample.flags=Ground|Pose|Lby;sample.interval=1.f/64;
    sample.latency=.1f;sample.lerp=.03125f;sample.max_unlag=.2f;sample.eye_yaw=60;sample.pose_yaw=-60;sample.velocity_x=100;
    for(unsigned tick=0;tick<24;++tick) {
        sample.simulation_time=10+static_cast<float>(tick)/64;sample.now=sample.simulation_time+.1f;sample.origin_x=static_cast<float>(tick)*1.5625f;
        check(feed(&sample,.65f,&decision)!=0,"actual x86 exported feed");
    }
    check(decision.apply==1&&decision.offset==-60,"integrated model produces supported override");
    check(hit(2,42,decision.generation)==1&&hit(2,42,decision.generation)==0,"head feedback credited once");
    Stats status{};stats(&status);check(status.records==24&&status.head_feedback==1&&status.memory_bytes<262144,"real DLL counters");
    Snapshot saved[16]{};check(history(2,saved,16)==16&&saved[0].simulation_time<saved[15].simulation_time,"bounded DLL history");
    for(unsigned i=0;i<100;++i)frame(.01f);frame(.1f);FrameStats timings{};frames(&timings);
    check(timings.count==101&&timings.spikes==1&&timings.p95_ms==10,"x86 percentile calculation");
    forget(2);stats(&status);check(status.slots==0,"forget export");
    std::ofstream report{std::filesystem::path(argv[2])};report<<"{\"checks\":"<<checks<<",\"actual_packaged_x86_dll_loaded\":true,\"gameplay_tested\":false}\n";
    check(static_cast<bool>(report),"Windows evidence saved");
    std::printf("Passed %u checks on actual packaged Windows x86 DLL; CS:GO was not run.\n",checks);
    // The core's waiting worker ends with this test process. Never FreeLibrary it live.
    return 0;
}
