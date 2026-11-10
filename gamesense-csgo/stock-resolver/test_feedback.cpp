#include "native_controller.h"
#include "shot_feedback.h"
#include "feedback_status.h"
#include <cstdio>
#include <cstdlib>
using namespace stock_resolver;
using namespace stock_native;
using namespace stock_feedback;
static unsigned checks=0;
static void check(bool value,const char* name){++checks;if(!value){std::fprintf(stderr,"FAIL: %s\n",name);std::exit(1);}}
static Snapshot sample(unsigned tick) {
    Snapshot s{};s.player=2;s.identity=42;s.flags=Ground|Pose|Lby;s.interval=1.f/64;s.simulation_time=10+tick*s.interval;
    s.now=s.simulation_time+.1f;s.latency=.1f;s.lerp=1.f/64;s.max_unlag=.2f;s.eye_yaw=60;s.pose_yaw=-60;s.velocity_x=100;s.origin_x=tick*1.5625f;return s;
}
static Shot shot(unsigned cmd=100,std::uint64_t now=1000){Shot s{};s.command=cmd;s.native_id=cmd%150;s.target=2;s.weapon=38;s.record_tick=647;s.hitbox=0;s.created_ms=now;s.point[0]=100;s.hc=.8f;s.predicted_damage=120;return s;}
int main() {
    Engine e;Controller controller(e);std::array<unsigned char,65*stride> bytes{};Controls controls{bytes.data()};
    FrameInput frame;frame.players[2].valid=true;
    for(unsigned t=0;t<12;++t){frame.players[2].sample=sample(t);controller.update(frame,controls,.65f);}
    ShotToken token{},second{};
    check(controller.shot_token(2,647,controls,token),"exact earlier GS record tick resolves to owned model record");
    check(token.tick==647&&token.simulation_time==sample(7).simulation_time,"historical record is not replaced by latest generation");
    check(!controller.shot_token(2,500,controls,second),"unmatched tick cannot acquire learning token");
    controls.set(2,true,29);check(!controller.shot_token(2,647,controls,second),"manual override blocks token");controls.set(2,true,-60);
    check(controller.shot_token(2,648,controls,second),"second independent record token");
    check(e.confirm(token)&&e.learned(2,1,0)==0,"one compatible head hit cannot reinforce side");
    check(!e.confirm(token),"same record cannot be credited twice");
    check(e.confirm(second)&&e.learned(2,1,0)>0&&e.learned(2,1,0)<=.08f,"two records provide small bounded state-specific evidence");
    check(e.learned(2,2,0)==0&&e.learned(2,0,0)==0,"moving evidence does not train crouch or standing");
    auto prior=e.learned(2,1,0);controller.suspend(controls);
    check(e.learned(2,1,0)==prior&&!e.confirm(second),"death retires lag history/tokens while retaining only weak identity-specific evidence");
    controller.reset(controls);check(e.learned(2,1,0)==0&&!e.confirm(token),"round/disconnect reset removes evidence and invalidates tokens");
    for(unsigned t=0;t<12;++t){frame.players[2].sample=sample(t);controller.update(frame,controls,.65f);}
    check(controller.shot_token(2,650,controls,token),"new round yields fresh token");
    frame.players[2].sample=sample(12);frame.players[2].sample.origin_x+=1000;controller.update(frame,controls,.65f);
    check(!e.confirm(token),"teleport invalidates captured generation epoch");
    unsigned credits=0;auto credit=[&](const ShotToken&){++credits;return 2u;};
    Ledger ledger;auto s=shot();s.token=token;ledger.intent(s);ledger.fire(38,1010);ledger.impact(200,0,0,1011);ledger.hurt(2,1,120,0,1012);
    ledger.boundary(1016,credit);const auto& first=ledger.shots()[0];
    check(first.outcome==HeadHit&&(first.bits&Reinforced)&&credits==1,"unique fire-impact-head sequence settles once at packet boundary");
    ledger.boundary(1100,credit);check(credits==1,"duplicate boundary never credits again");
    for(unsigned kind=0;kind<8;++kind){
        Ledger l;auto v=shot();v.token=token;if(kind==2)v.hitbox=3;l.intent(v);l.fire(38,1010);
        if(kind!=3)l.impact(200,kind==1?100.f:0.f,0,1011);
        if(kind==4)l.boundary(1011,credit);
        if(kind!=5)l.hurt(kind==6?3:2,kind==0?2:1,60,40,1012);
        if(kind==7)l.hurt(2,1,60,40,1013);
        const auto old=credits;l.boundary(4000,credit);check(credits==old,"body/wide ray/body point/missing impact/cross-packet/unknown/wrong target/duplicate cannot reinforce");
    }
    Ledger dt;s=shot();s.token=token;dt.intent(s);s=shot(101,1001);s.token=second;dt.intent(s);dt.fire(38,1010);dt.fire(38,1010);
    dt.impact(200,0,0,1011);dt.hurt(2,1,120,0,1012);const auto old=credits;dt.boundary(4000,credit);
    check(dt.counters().ambiguous==2&&credits==old,"DT batch is preserved and cannot misattribute feedback");
    Ledger late;late.intent(shot());late.fire(38,1700);late.boundary(4000,credit);
    check(late.counters().unconfirmed==1&&late.counters().unmatched==1,"late/manual fire cannot borrow stale GS intent");
    Ledger flood;for(unsigned i=0;i<300;++i)flood.intent(shot(100+i));check(flood.counters().overflow==44,"fixed-size ring overwrites without allocation");
    flood.reset();check(flood.counters().resets==1,"reset marks pending outcomes without losing archive");
    std::printf("{\"checks\":%u,\"shot_bytes\":%zu,\"log_bytes\":%zu,\"same_record_required\":true,\"unknown_does_not_penalize\":true,\"DT_ambiguity_skips_learning\":true,\"single_head_does_not_reinforce\":true,\"gameplay_tested\":false}\n",checks,sizeof(Shot),sizeof(Log));
}
