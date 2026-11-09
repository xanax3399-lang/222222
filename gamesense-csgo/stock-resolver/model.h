#pragma once
#include <algorithm>
#include <array>
#include <cmath>
#include <cstdint>
#include <cstddef>

namespace stock_resolver {
constexpr unsigned players=64, history_size=16, frame_samples=512;
enum Flags : unsigned { Ground=1, Pose=2, Lby=4 };
enum Reason : unsigned { NoHistory=1, Invalid=2, Stale=3, Uncertain=4, Air=5, Hysteresis=6, Evidence=7 };
struct Snapshot {
    std::uint32_t player,identity,flags,reserved;
    float simulation_time,now,interval,latency,lerp,max_unlag;
    float eye_yaw,lower_body_yaw,pose_yaw,velocity_x,velocity_y,duck;
    float origin_x,origin_y,origin_z;
};
struct Decision {
    std::uint32_t player,identity,generation,apply,records,state,reason,reserved;
    float offset,confidence,simulation_time;
};
struct Stats {
    std::uint32_t feeds,records,duplicates,rejected,resets,selected,fallback,head_feedback,feedback_rejected,slots,memory_bytes;
};
struct FrameStats { std::uint32_t count,spikes;float mean_ms,p50_ms,p95_ms,p99_ms,max_ms; };
static_assert(sizeof(Snapshot)==76 && sizeof(Decision)==44 && sizeof(Stats)==44 && sizeof(FrameStats)==28);
inline float clamp(float x,float a,float b){return std::max(a,std::min(x,b));}
inline float normalize(float x){x=std::fmod(x,360.f);if(x>180)x-=360;if(x< -180)x+=360;return x;}
inline float distance(float a,float b){return std::fabs(normalize(a-b));}
inline unsigned movement(const Snapshot& s){return !(s.flags&Ground)?3:s.duck>.5f?2:s.velocity_x*s.velocity_x+s.velocity_y*s.velocity_y>1225?1:0;}
inline bool finite(const Snapshot& s) {
    const float values[]={s.simulation_time,s.now,s.interval,s.latency,s.lerp,s.max_unlag,s.eye_yaw,s.lower_body_yaw,s.pose_yaw,s.velocity_x,s.velocity_y,s.duck,s.origin_x,s.origin_y,s.origin_z};
    for(float value:values)if(!std::isfinite(value))return false;
    return s.player>=1&&s.player<=players&&s.identity&&s.simulation_time>=0&&s.interval>=.001f&&s.interval<=.1f&&
        s.latency>=0&&s.latency<=2&&s.lerp>=0&&s.lerp<=.5f&&s.max_unlag>=.01f&&s.max_unlag<=1&&
        std::fabs(s.eye_yaw)<=7200&&std::fabs(s.lower_body_yaw)<=7200&&std::fabs(s.pose_yaw)<=180&&s.duck>=0&&s.duck<=1&&
        std::fabs(s.velocity_x)<=5000&&std::fabs(s.velocity_y)<=5000;
}
struct Record { Snapshot sample{};std::uint32_t generation=0,selected=0,applied=0,credited=0; };
struct Slot {
    std::uint32_t identity=0,count=0,head=0,pending=3,pending_count=0;
    float last_sim=-1,last_seen=0,anchor=0,anchor_time=-100,world=0;
    bool has_world=false;
    float prior[3]{};
    Decision decision{};
    std::array<Record,history_size> records{};
};
class Engine {
    std::array<Slot,players+1> slots_{};
    std::array<float,frame_samples> frames_{};
    std::uint32_t generation_=0,frame_head_=0,frame_count_=0;
    Stats stats_{};
    const Record& recent(const Slot& slot,unsigned n)const{return slot.records[(slot.head+history_size-1-n)%history_size];}
public:
    void reset(){slots_={};frames_={};generation_=frame_head_=frame_count_=0;stats_={};}
    void forget(unsigned player){if(player>=1&&player<=players){slots_[player]=Slot{};++stats_.resets;}}
    Stats stats()const {auto out=stats_;out.memory_bytes=sizeof(*this);out.slots=0;for(unsigned i=1;i<=players;++i)out.slots+=slots_[i].identity!=0;return out;}
    bool feed(const Snapshot& s,float threshold,Decision& out) {
        ++stats_.feeds;out={s.player,s.identity,0,0,0,0,Invalid,0,0,0,s.simulation_time};
        if(!finite(s)||!std::isfinite(threshold)||threshold<0||threshold>1){++stats_.rejected;return false;}
        auto& slot=slots_[s.player];
        const float age=s.now-s.simulation_time;
        if(age< -2*s.interval||age>s.max_unlag+s.latency+s.lerp+2*s.interval){out.reason=Stale;++stats_.rejected;return false;}
        bool reset=slot.identity!=s.identity;
        const float gap=s.simulation_time-slot.last_sim;
        if(slot.identity&&(!reset)&&(gap< -s.interval*.25f||gap>std::max(.25f,s.interval*17)))reset=true;
        if(slot.count&&!reset) {
            const auto& last=recent(slot,0).sample;
            const float dx=s.origin_x-last.origin_x,dy=s.origin_y-last.origin_y,dz=s.origin_z-last.origin_z;
            if(dx*dx+dy*dy+dz*dz>4096.f)reset=true;
        }
        if(reset){slot=Slot{};slot.identity=s.identity;++stats_.resets;}
        slot.last_seen=s.now;
        if(slot.count&&std::fabs(s.simulation_time-slot.last_sim)<s.interval*.25f){out=slot.decision;if(out.confidence<threshold){out.apply=0;out.reason=Uncertain;}++stats_.duplicates;return true;}
        slot.last_sim=s.simulation_time;
        auto& record=slot.records[slot.head];record=Record{};record.sample=s;
        slot.head=(slot.head+1)%history_size;slot.count=std::min(slot.count+1,history_size);++stats_.records;
        out={s.player,s.identity,++generation_,0,slot.count,movement(s),NoHistory,0,0,0,s.simulation_time};
        // A generation belongs to one simulation record, never a rendered frame.
        record.generation=out.generation;
        for(float& prior:slot.prior)prior*=std::exp(-std::max(0.f,gap)*.7f);
        const float speed=std::sqrt(s.velocity_x*s.velocity_x+s.velocity_y*s.velocity_y);
        const bool grounded=(s.flags&Ground)!=0,has_lby=(s.flags&Lby)!=0;
        if(grounded&&has_lby&&speed>35&&s.duck<.5f) {
            const float heading=std::atan2(s.velocity_y,s.velocity_x)*57.295779513f;
            if(distance(heading,s.lower_body_yaw)<50) {slot.anchor=normalize(s.lower_body_yaw);slot.anchor_time=s.simulation_time;}
        }
        float evidence=0.f,reference=s.lower_body_yaw;
        const float anchor_age=s.simulation_time-slot.anchor_time;
        if(anchor_age>=0&&anchor_age<=1.1f){reference=slot.anchor;evidence=.95f*(1.f-anchor_age/1.1f);}
        // Alternating eye deltas around a stable LBY are a hint, not server truth.
        unsigned alternations=0,usable=0;int previous_sign=0;
        if(grounded&&has_lby&&speed<35) {
            for(unsigned i=0;i<std::min(slot.count,6u);++i) {
                const auto& r=recent(slot,i).sample;
                if(!(r.flags&Lby)||movement(r)!=movement(s)||distance(r.lower_body_yaw,s.lower_body_yaw)>15)break;
                const float delta=normalize(r.eye_yaw-s.lower_body_yaw),magnitude=std::fabs(delta);
                if(magnitude<20||magnitude>120)break;
                int sign=delta>0?1:-1;if(previous_sign&&sign!=previous_sign)++alternations;
                previous_sign=sign;++usable;
            }
            if(usable>=5&&alternations>=3&&evidence<.78f){reference=normalize(s.lower_body_yaw);evidence=.78f;}
        }
        if(evidence==0&&has_lby)evidence=.3f;
        float costs[3]{},offsets[3]={-60,0,60};unsigned best=0,second=1;
        for(unsigned c=0;c<3;++c) {
            costs[c]=evidence*distance(normalize(s.eye_yaw+offsets[c]),reference)/60.f;
            if(s.flags&Pose)costs[c]+=.06f*std::fabs(offsets[c]-s.pose_yaw)/60.f;
            costs[c]-=slot.prior[c];
            if(costs[c]<costs[best])best=c;
        }
        second=best==0?1:0;for(unsigned c=0;c<3;++c)if(c!=best&&costs[c]<costs[second])second=c;
        const float correct=clamp(s.latency+s.lerp,0,s.max_unlag);
        float quality=1-.25f*clamp(std::fabs(age-correct)/(s.max_unlag+correct),0,1);
        if(gap>2*s.interval)quality*=.85f;
        if(s.duck>.5f)quality*=.85f;
        if(!grounded)quality*=.45f;
        const float support=clamp((float(slot.count)-2)/4.f,0,1);
        // Confidence is an evidence score, not a probability of hitting a head.
        out.confidence=clamp((costs[second]-costs[best])/std::max(evidence,.15f),0,1)*evidence*support*quality;
        out.offset=offsets[best];out.reason=grounded?Uncertain:Air;
        if(slot.count>=4&&grounded&&out.confidence>=threshold&&evidence>=.55f) {
            float world=normalize(s.eye_yaw+out.offset);
            bool ready=true;
            if(slot.has_world&&distance(world,slot.world)>20) {
                if(slot.pending!=best){slot.pending=best;slot.pending_count=1;}else ++slot.pending_count;
                ready=slot.pending_count>=2;
            }
            if(ready){out.apply=1;out.reason=Evidence;slot.world=world;slot.has_world=true;slot.pending=3;slot.pending_count=0;}
            else out.reason=Hysteresis;
        }
        record.selected=best;record.applied=out.apply;
        if(out.apply)++stats_.selected;else ++stats_.fallback;
        slot.decision=out;return true;
    }
    bool hit(unsigned player,unsigned identity,unsigned generation) {
        if(player<1||player>players||!identity){++stats_.feedback_rejected;return false;}
        auto& slot=slots_[player];
        if(slot.identity==identity)for(unsigned i=0;i<slot.count;++i){auto& r=slot.records[(slot.head+history_size-1-i)%history_size];
            if(r.generation==generation&&r.applied&&!r.credited){r.credited=1;slot.prior[r.selected]=std::min(.15f,slot.prior[r.selected]+.025f);++stats_.head_feedback;return true;}}
        ++stats_.feedback_rejected;return false;
    }
    unsigned history(unsigned player,Snapshot* out,unsigned capacity)const {
        if(player<1||player>players||!out)return 0;
        const auto& slot=slots_[player];unsigned n=std::min(capacity,slot.count);
        for(unsigned i=0;i<n;++i)out[i]=recent(slot,n-i-1).sample;
        return n;
    }
    void frame(float dt){if(std::isfinite(dt)&&dt>0&&dt<=10){frames_[frame_head_]=dt*1000;frame_head_=(frame_head_+1)%frame_samples;frame_count_=std::min(frame_count_+1,frame_samples);}}
    FrameStats frame_stats()const {
        FrameStats out{};out.count=frame_count_;if(!frame_count_)return out;
        std::array<float,frame_samples> sorted{};
        for(unsigned i=0;i<frame_count_;++i){sorted[i]=frames_[i];out.mean_ms+=sorted[i];out.spikes+=sorted[i]>50;}
        std::sort(sorted.begin(),sorted.begin()+frame_count_);out.mean_ms/=frame_count_;
        auto percentile=[&](float p){return sorted[static_cast<unsigned>(std::ceil(p*frame_count_))-1];};
        out.p50_ms=percentile(.5f);out.p95_ms=percentile(.95f);out.p99_ms=percentile(.99f);out.max_ms=sorted[frame_count_-1];return out;
    }
};
}
