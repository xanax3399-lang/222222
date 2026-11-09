#include "model.h"
#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <vector>
#include <limits>
using namespace stock_resolver;
static unsigned checks=0;
static void check(bool value,const char* message){++checks;if(!value){std::fprintf(stderr,"FAIL: %s\n",message);std::exit(1);}}
static Snapshot input(unsigned player,unsigned tick,float eye=60) {
    Snapshot s{};s.player=player;s.identity=1000+player;s.flags=Ground|Pose|Lby;
    s.interval=1.f/64;s.simulation_time=10+tick*s.interval;s.now=s.simulation_time+.1f;
    s.latency=.1f;s.lerp=1.f/64;s.max_unlag=.2f;s.eye_yaw=eye;s.pose_yaw=-eye;s.velocity_x=100;s.origin_x=float(tick)*1.5625f;return s;
}
int main() {
    Engine e;Decision d{};
    for(unsigned t=0;t<12;++t){auto s=input(2,t);check(e.feed(s,.65f,d),"valid record");if(t<3)check(!d.apply,"history support required");}
    check(d.apply&&d.offset==-60&&d.confidence>=.65f,"supported moving side selected");
    const auto gen=d.generation;check(e.hit(2,1002,gen),"positive head feedback");check(!e.hit(2,1002,gen),"duplicate feedback rejected");check(!e.hit(2,999,gen),"identity feedback checked");
    auto count=e.stats().records;
    for(unsigned i=0;i<20;++i){auto s=input(2,11);check(e.feed(s,.99f,d)&&!d.apply,"threshold honored on cached record");}
    check(e.stats().records==count,"duplicate updates do not append");
    for(unsigned t=12;t<60;++t){auto s=input(2,t);e.feed(s,.65f,d);}
    Snapshot history[16]{};check(e.history(2,history,16)==16,"bounded history");
    for(unsigned i=1;i<16;++i)check(history[i].simulation_time>history[i-1].simulation_time,"chronological history");
    auto s=input(2,60);s.identity=42;e.feed(s,.65f,d);check(d.records==1&&!d.apply,"identity reset");
    s=input(2,61);s.identity=42;s.origin_x+=1000;e.feed(s,.65f,d);check(d.records==1&&!d.apply,"teleport reset");
    s=input(2,3);s.identity=42;e.feed(s,.65f,d);check(d.records==1,"simulation rollback reset");
    s=input(2,4);s.now+=2;check(!e.feed(s,.65f,d)&&d.reason==Stale,"stale record rejected");
    s=input(0,4);check(!e.feed(s,.65f,d),"player bounds");
    s=input(2,4);s.eye_yaw=std::numeric_limits<float>::quiet_NaN();check(!e.feed(s,.65f,d),"NaN rejected");
    e.reset();for(unsigned t=0;t<12;++t){s=input(3,t,-60);e.feed(s,.65f,d);}check(d.apply&&d.offset==60,"opposite side");
    e.reset();for(unsigned t=0;t<12;++t){s=input(3,t);s.flags=Pose|Lby;e.feed(s,.65f,d);check(!d.apply,"air fallback");}
    e.reset();for(unsigned t=0;t<20;++t){s=input(4,t);s.velocity_x=0;e.feed(s,.65f,d);check(!d.apply,"uncertain static fallback");}
    e.reset();for(unsigned t=0;t<12;++t){s=input(4,t,t%2?60:-60);s.velocity_x=0;e.feed(s,.65f,d);}check(d.apply&&distance(s.eye_yaw+d.offset,0)<.01f,"jitter world orientation stable");
    e.reset();for(unsigned t=0;t<12;++t){s=input(5,t,-121);s.lower_body_yaw=179;s.velocity_x=-100;s.velocity_y=1.7455f;s.pose_yaw=-60;e.feed(s,.65f,d);}check(d.apply&&d.offset==-60,"yaw wraps circularly");
    for(unsigned player=1;player<=64;++player){s=input(player,20);e.feed(s,.65f,d);}check(e.stats().slots==64,"64 slots");check(e.stats().memory_bytes<256*1024,"bounded native memory");
    e.reset();for(unsigned i=0;i<100;++i)e.frame(.01f);e.frame(.1f);e.frame(0);e.frame(std::numeric_limits<float>::quiet_NaN());auto f=e.frame_stats();check(f.count==101&&f.spikes==1&&f.p95_ms==10&&f.max_ms==100,"frame percentiles retain stalls");
    std::printf("{\"checks\":%u,\"native_memory_bytes\":%u,\"gameplay_tested\":false,\"host_benchmarks\":[",checks,e.stats().memory_bytes);
    const unsigned counts[]={5,10,32,64};
    for(unsigned n=0;n<4;++n){e.reset();std::vector<double> times;times.reserve(2048);
        for(unsigned tick=0;tick<2048;++tick){auto begin=std::chrono::steady_clock::now();for(unsigned p=1;p<=counts[n];++p){auto v=input(p,tick,tick%2?60:-60);e.feed(v,.65f,d);}times.push_back(std::chrono::duration<double,std::micro>(std::chrono::steady_clock::now()-begin).count());}
        std::sort(times.begin(),times.end());std::printf("%s{\"enemies\":%u,\"updates\":2048,\"p50_us\":%.3f,\"p95_us\":%.3f,\"max_us\":%.3f}",n?",":"",counts[n],times[1023],times[1945],times.back());}
    std::puts("]}");
}
