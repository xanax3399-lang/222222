#include "native_controller.h"
#include <cstdio>
#include <cstdlib>
using namespace stock_native;
unsigned checks=0;
void check(bool v,const char* why){++checks;if(!v){std::fprintf(stderr,"FAIL: %s\n",why);std::exit(1);}}
int main() {
    stock_resolver::Engine engine;Controller control(engine);FrameInput frame;
    std::array<unsigned char,65*stride> data;data.fill(0x5a);Controls storage{data.data()};
    for(unsigned p=1;p<=64;++p)storage.set(p,false,17);
    const auto before=data;
    auto& input=frame.players[2];input.valid=true;
    auto& s=input.sample;s.player=2;s.identity=42;s.flags=7;s.interval=1.f/64;s.latency=.1f;s.lerp=.03125f;s.max_unlag=.2f;s.eye_yaw=60;s.pose_yaw=-60;s.velocity_x=100;
    auto tick=[&](unsigned n){s.simulation_time=10+static_cast<float>(n)/64;s.now=s.simulation_time+.1f;s.origin_x=static_cast<float>(n)*1.5625f;control.update(frame,storage,.65f);};
    for(unsigned n=0;n<8;++n)tick(n);
    bool enabled=false;int value=0;check(storage.get(2,enabled,value)&&enabled&&value==-60,"native controller applies evidence to GS layout");
    check(control.applied==1&&control.tracked==1,"active counts");
    for(unsigned i=0;i<data.size();++i)if(i!=2*stride+5&&(i<2*stride+8||i>=2*stride+12))check(data[i]==before[i],"unrelated GS controls preserved");
    auto count=engine.stats().records;for(unsigned i=0;i<20;++i)tick(7);
    check(engine.stats().records==count&&engine.stats().duplicates==20,"duplicates deduplicated in native path");
    storage.set(2,true,29);tick(8);check(storage.get(2,enabled,value)&&enabled&&value==29&&control.blocked==1,"later manual override retained");
    control.reset(storage);check(storage.get(2,enabled,value)&&enabled&&value==29,"reset preserves manual edit");
    storage.set(2,false,17);s.identity=43;for(unsigned n=0;n<8;++n)tick(n);
    input.valid=false;control.update(frame,storage,.65f);check(storage.get(2,enabled,value)&&!enabled&&value==17,"dormancy/death releases our settings");
    input.valid=true;for(unsigned n=0;n<8;++n)tick(n);s.identity=44;tick(8);
    check(storage.get(2,enabled,value)&&!enabled&&value==17&&engine.stats().slots==1,"new identity requires new evidence");
    for(unsigned n=9;n<16;++n)tick(n);
    control.reset(storage);
    check(storage.get(2,enabled,value)&&!enabled&&value==17,"owned control restored on reset");
    storage.set(2,true,31);for(unsigned n=0;n<8;++n)tick(n);
    check(storage.get(2,enabled,value)&&enabled&&value==31&&control.applied==0,"pre-existing manual override wins");
    check(!storage.get(0,enabled,value)&&!storage.get(65,enabled,value),"player bounds");
    std::printf("{\"checks\":%u,\"external_lua_required\":false,\"gameplay_tested\":false}\n",checks);
}
