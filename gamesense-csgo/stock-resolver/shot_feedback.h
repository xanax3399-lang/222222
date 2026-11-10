#pragma once
#include "model.h"
#include <array>
#include <cstdint>
namespace stock_feedback {
constexpr unsigned capacity=256;
enum Outcome:unsigned { Pending=0,HeadHit=1,BodyHit=2,Unknown=3,Unconfirmed=4,Ambiguous=5,Reset=6 };
enum Bits:unsigned { Intent=1,Fired=2,Impact=4,Hurt=8,Conflict=16,Eligible=32,Credited=64,Final=128,Reinforced=256 };
struct Shot {
    unsigned serial=0,command=0,native_id=0,target=0,weapon=0,record_tick=0,hitbox=0,bits=0;
    unsigned outcome=0,hitgroup=0,damage=0,remaining=0,batch=0;
    std::uint64_t created_ms=0;
    float point[3]{},eye[3]{},impact[3]{},hc=0,predicted_damage=0;
    stock_resolver::ShotToken token{};
};
struct Counters {unsigned intents=0,fires=0,impacts=0,hurts=0,head_hits=0,body_hits=0,unknown=0,unconfirmed=0,ambiguous=0,credits=0,rejected=0,unmatched=0,overflow=0,duplicates=0,resets=0;};
class Ledger {
    std::array<Shot,capacity> shots_{};
    Counters stats_{};
    unsigned serial_=0,batch_=1,batch_fires_=0;
    static bool live(const Shot& s){return s.serial&&!(s.bits&Final);}
    bool valid_time(const Shot& s,std::uint64_t now)const{return now>=s.created_ms&&now-s.created_ms<=2000;}
    static bool aligned_head(const Shot& s) {
        if(s.hitbox!=0)return false;
        float ray[3]{},point[3]{};float length=0,dot=0;
        for(unsigned i=0;i<3;++i){ray[i]=s.impact[i]-s.eye[i];point[i]=s.point[i]-s.eye[i];length+=ray[i]*ray[i];dot+=ray[i]*point[i];}
        if(!std::isfinite(length)||length<1||dot<0||dot>length)return false;
        const float t=dot/length;float error=0;for(unsigned i=0;i<3;++i){const float d=point[i]-ray[i]*t;error+=d*d;}
        return std::isfinite(error)&&error<=36;
    }
    template<class F> void finish(Shot& s,F&& credit) {
        if(s.bits&Final)return;
        if(s.bits&Conflict){s.outcome=Ambiguous;++stats_.ambiguous;}
        else if(s.bits&Hurt) {
            if(s.hitgroup==1){s.outcome=HeadHit;++stats_.head_hits;
                if((s.bits&(Eligible|Fired|Impact))==(Eligible|Fired|Impact)&&aligned_head(s)) {
                    const auto result=credit(s.token);
                    if(result){s.bits|=Credited;if(result==2)s.bits|=Reinforced;++stats_.credits;}else ++stats_.rejected;
                }
            }else{s.outcome=BodyHit;++stats_.body_hits;}
        }else if(s.bits&Fired){s.outcome=Unknown;++stats_.unknown;}
        else{s.outcome=Unconfirmed;++stats_.unconfirmed;}
        s.bits|=Final;
    }
public:
    void reject(){++stats_.rejected;}
    Counters counters()const{return stats_;}
    const std::array<Shot,capacity>& shots()const{return shots_;}
    Shot* intent(Shot input) {
        for(auto& s:shots_)if(live(s)&&s.command==input.command&&s.native_id==input.native_id){++stats_.duplicates;return nullptr;}
        const unsigned id=++serial_;auto& s=shots_[(id-1)%capacity];
        if(live(s))++stats_.overflow;
        s=input;s.serial=id;s.bits=Intent|(input.token.generation?Eligible:0u);s.batch=batch_;
        ++stats_.intents;return &s;
    }
    void fire(unsigned weapon,std::uint64_t now) {
        ++stats_.fires;++batch_fires_;Shot* best=nullptr;unsigned candidates=0;
        for(auto& s:shots_)if(live(s)&&!(s.bits&Fired)&&s.weapon==weapon&&valid_time(s,now)&&now-s.created_ms<=500) {
            ++candidates;if(!best||s.serial<best->serial)best=&s;
        }
        if(candidates>1)for(auto& s:shots_)if(live(s)&&!(s.bits&Fired)&&s.weapon==weapon&&valid_time(s,now)&&now-s.created_ms<=500)s.bits|=Conflict;
        if(!best){++stats_.unmatched;return;}
        best->bits|=Fired;best->batch=batch_;
    }
    void impact(float x,float y,float z,std::uint64_t now) {
        ++stats_.impacts;Shot* found=nullptr;unsigned n=0;
        for(auto& s:shots_)if(live(s)&&(s.bits&Fired)&&!(s.bits&Impact)&&valid_time(s,now)) {found=&s;++n;}
        if(n!=1){++stats_.unmatched;
            if(n>1)for(auto& s:shots_)if(live(s)&&(s.bits&Fired)&&!(s.bits&Impact))s.bits|=Conflict;
            if(!n)for(auto& s:shots_)if(live(s)&&(s.bits&Fired)&&(s.bits&Impact)){s.bits|=Conflict;++stats_.duplicates;}
            return;}
        found->bits|=Impact;found->impact[0]=x;found->impact[1]=y;found->impact[2]=z;
        if(found->batch!=batch_)found->bits|=Conflict;
    }
    void hurt(unsigned target,unsigned hitgroup,unsigned damage,unsigned remaining,std::uint64_t now) {
        ++stats_.hurts;Shot* found=nullptr;unsigned n=0;
        for(auto& s:shots_)if(live(s)&&(s.bits&Fired)&&s.target==target&&valid_time(s,now)) {found=&s;++n;}
        if(n!=1){++stats_.unmatched;if(n>1)for(auto& s:shots_)if(live(s)&&(s.bits&Fired)&&s.target==target)s.bits|=Conflict;return;}
        if(found->bits&Hurt){found->bits|=Conflict;++stats_.duplicates;return;}
        found->bits|=Hurt;found->hitgroup=hitgroup;found->damage=damage;found->remaining=remaining;
        if(found->batch!=batch_)found->bits|=Conflict;
    }
    template<class F> void boundary(std::uint64_t now,F&& credit) {
        // Source NET_UPDATE_END: all currently delivered events have been read.
        // A multi-fire packet is deliberately ineligible for learning.
        for(auto& s:shots_)if(live(s)) {
            if(s.batch==batch_&&batch_fires_>1)s.bits|=Conflict;
            if(s.bits&Hurt||!valid_time(s,now))finish(s,credit);
        }
        ++batch_;batch_fires_=0;
    }
    void reset() {
        for(auto& s:shots_)if(live(s)){s.bits|=Final;s.outcome=Reset;}
        ++batch_;batch_fires_=0;++stats_.resets;
    }
};
}
