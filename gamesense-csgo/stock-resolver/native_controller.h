#pragma once
#include "model.h"
#include <cstring>

namespace stock_native {
// Recovered from the pinned GS plist.get/set bodies and descriptor table:
// array 0x4347BE08, index*32, bool +5, signed integer +8, range -60..60.
constexpr unsigned plist_base=0x4347be08, stride=32, yaw_enabled=5, yaw_value=8;
struct PlayerInput { bool valid=false,preserve_learning=false;unsigned seen_identity=0; stock_resolver::Snapshot sample{}; };
struct FrameInput { std::array<PlayerInput,65> players{}; };
struct Controls {
    unsigned char* base=nullptr;
    bool get(unsigned player,bool& enabled,int& value) const {
        if(!base||player<1||player>64)return false;
        const auto* entry=base+player*stride;
        if(entry[yaw_enabled]>1)return false;
        enabled=entry[yaw_enabled]!=0;std::memcpy(&value,entry+yaw_value,4);
        return value>=-60&&value<=60;
    }
    void set(unsigned player,bool enabled,int value) const {
        auto* entry=base+player*stride;
        std::memcpy(entry+yaw_value,&value,4);entry[yaw_enabled]=enabled?1:0;
    }
};
struct Owned { unsigned identity=0;bool owned=false,blocked=false;int value=0,original=0; };
class Controller {
    stock_resolver::Engine& engine_;
    std::array<Owned,65> states_{};
public:
    unsigned applied=0,tracked=0,blocked=0,invalid_controls=0;
    explicit Controller(stock_resolver::Engine& engine):engine_(engine){}
    void release(unsigned player,Controls controls) {
        auto& state=states_[player];bool enabled=false;int value=0;
        if(state.owned&&controls.get(player,enabled,value)&&enabled&&value==state.value)
            controls.set(player,false,state.original);
        state.owned=false;
    }
    void forget(unsigned player,Controls controls) {
        release(player,controls);states_[player]=Owned{};engine_.forget(player);
    }
    bool shot_token(unsigned player,unsigned tick,Controls controls,stock_resolver::ShotToken& out)const {
        if(player<1||player>64)return false;
        const auto& state=states_[player];bool enabled=false;int value=0;
        return state.owned&&!state.blocked&&controls.get(player,enabled,value)&&enabled&&value==state.value&&
            engine_.token(player,state.identity,tick,value,out);
    }
    unsigned identity(unsigned player)const{return player>=1&&player<=64?states_[player].identity:0;}
    void suspend(Controls controls) {
        for(unsigned p=1;p<=64;++p)if(states_[p].identity){release(p,controls);engine_.retire(p,states_[p].identity);states_[p].blocked=false;}
        applied=tracked=blocked=0;
    }
    void reset(Controls controls) {
        for(unsigned p=1;p<=64;++p)forget(p,controls);
        engine_.reset();applied=tracked=blocked=invalid_controls=0;
    }
    void update(const FrameInput& frame,Controls controls,float threshold) {
        applied=tracked=blocked=0;
        for(unsigned player=1;player<=64;++player) {
            auto& state=states_[player];const auto& input=frame.players[player];
            if(!input.valid){if(state.identity){
                if(input.preserve_learning&&input.seen_identity==state.identity){release(player,controls);engine_.retire(player,state.identity);state.blocked=false;}
                else forget(player,controls);
            }continue;}
            if(input.sample.player!=player||!input.sample.identity){if(state.identity)forget(player,controls);continue;}
            ++tracked;
            if(state.identity!=input.sample.identity){forget(player,controls);state.identity=input.sample.identity;}
            stock_resolver::Decision decision{};
            if(!engine_.feed(input.sample,threshold,decision)||!decision.apply||state.blocked){release(player,controls);blocked+=state.blocked;continue;}
            bool enabled=false;int value=0;
            if(!controls.get(player,enabled,value)){++invalid_controls;release(player,controls);continue;}
            if(state.owned) {
                if(!enabled||value!=state.value){state.owned=false;state.blocked=true;++blocked;continue;}
            }else {
                if(enabled){state.blocked=true;++blocked;continue;}
                state.original=value;
            }
            const int wanted=static_cast<int>(decision.offset);
            if(wanted< -60||wanted>60){release(player,controls);continue;}
            if(!state.owned||wanted!=state.value)controls.set(player,true,wanted);
            state.value=wanted;state.owned=true;engine_.written(player,decision.generation,wanted);++applied;
        }
    }
};
}
