#define NOMINMAX
#include "native_driver.h"
#include "native_controller.h"
#include "feedback_status.h"
#include "feedback_hook.h"
#include "../source/skeet/nl_hypotheses.h"
#include <array>
#include <cmath>
#include <cwchar>
#include <algorithm>
#include <chrono>
#include <cstddef>

extern "C" __declspec(dllexport) stock_native::DriverStatus sr_driver_status={1,1};
extern "C" __declspec(dllexport) stock_feedback::Status sr_feedback_status={1,1,1};
extern "C" __declspec(dllexport) stock_feedback::Log sr_feedback_log{};
namespace stock_native {
namespace {
constexpr unsigned base=0x43310000,image_size=0x2fc000;
constexpr unsigned gs_engine=0x4346a514,gs_entities=0x4346a890,gs_globals=0x43467b04;
constexpr unsigned frame_stage=37,get_classes=8;
using StageFn=void(__thiscall*)(void*,int);
using Factory=void*(__cdecl*)(const char*,int*);
void* client=nullptr;void* engine=nullptr;void* entities=nullptr;void* cvars=nullptr;
void** original_table=nullptr;void* original_entry=nullptr;void** hook_slot=nullptr;
std::array<unsigned char,16> original_code{};
StageFn previous=nullptr;
float threshold=.65f;
unsigned fps_limit=0;
bool fps_owned=false;float fps_original=0;
const char* error_text="Native resolver was not prepared.";
Controller controller(shared_engine());
stock_feedback::Ledger feedback;
SRWLOCK feedback_lock=SRWLOCK_INIT;
void* event_manager=nullptr;
ULONGLONG feedback_retry_at=0;
struct FeedbackGuard {
    bool locked;
    FeedbackGuard():locked(TryAcquireSRWLockExclusive(&feedback_lock)!=0){if(!locked)InterlockedIncrement(reinterpret_cast<volatile LONG*>(&sr_feedback_status.busy));}
    ~FeedbackGuard(){if(locked)ReleaseSRWLockExclusive(&feedback_lock);}
};
template<class T> T read(const void* p,unsigned offset=0){T value;std::memcpy(&value,static_cast<const unsigned char*>(p)+offset,sizeof(value));return value;}
template<class T> T at(unsigned address){return read<T>(reinterpret_cast<const void*>(address));}
bool readable(const void* p,std::size_t bytes) {
    if(!p||!bytes)return false;
    MEMORY_BASIC_INFORMATION info{};
    if(!VirtualQuery(p,&info,sizeof(info))||info.State!=MEM_COMMIT||(info.Protect&(PAGE_GUARD|PAGE_NOACCESS)))return false;
    const auto begin=reinterpret_cast<std::uintptr_t>(p),region=reinterpret_cast<std::uintptr_t>(info.BaseAddress);
    return begin>=region&&bytes<=info.RegionSize-(begin-region);
}
template<class F> F method(void* object,unsigned slot){return reinterpret_cast<F>((*static_cast<void***>(object))[slot]);}
void* resolve_interface(const wchar_t* module,const char* name) {
#ifdef SR_NATIVE_FIXTURE
    extern void* fixture_interface(const wchar_t*,const char*);
    return fixture_interface(module,name);
#else
    HMODULE handle=GetModuleHandleW(module);if(!handle)return nullptr;
    auto factory=reinterpret_cast<Factory>(GetProcAddress(handle,"CreateInterface"));
    return factory?factory(name,nullptr):nullptr;
#endif
}
struct RecvProp {
    const char* name;int type,flags,string_size;unsigned char inside_array,pad[3];
    void* extra;RecvProp* array;void* length_proxy;void* proxy;void* table_proxy;
    struct RecvTable* table;int offset,stride,elements;const char* parent;
};
struct RecvTable {RecvProp* props;int count;void* decoder;const char* name;unsigned char initialized,main,pad[2];};
struct ClientClass {void* create;void* event;const char* name;RecvTable* table;ClientClass* next;int id;};
static_assert(sizeof(RecvProp)==60&&offsetof(RecvProp,offset)==44&&sizeof(RecvTable)==20&&sizeof(ClientClass)==24);
struct Offsets {int sim=-1,yaw=-1,lby=-1,pose=-1,velocity=-1,duck=-1,origin=-1,flags=-1,health=-1,life=-1,team=-1;};
Offsets offsets;
bool text_is(const char* p,const char* expected) {
    if(!p)return false;
    const auto length=std::strlen(expected)+1;
    return readable(p,length)&&std::memcmp(p,expected,length)==0;
}
int find(RecvTable* table,const char* name,unsigned depth=0,int parent=0) {
    if(depth>20||!readable(table,sizeof(*table))||table->count<0||table->count>4096||
       !readable(table->props,static_cast<unsigned>(table->count)*sizeof(RecvProp)))return -1;
    for(int i=0;i<table->count;++i) {
        const auto& property=table->props[i];
        if(property.offset<0||property.offset>0xffff||parent+property.offset>0xffff)continue;
        if(text_is(property.name,name))return parent+property.offset;
        if(property.type==6&&property.table) {
            const int child=find(property.table,name,depth+1,parent+property.offset);
            if(child>=0)return child;
        }
    }
    return -1;
}
bool resolve_netvars() {
    auto* list=method<ClientClass*(__thiscall*)(void*)>(client,get_classes)(client);
    RecvTable* root=nullptr;
    for(unsigned count=0;list&&count<1024;++count) {
        if(!readable(list,sizeof(*list)))return false;
        if(readable(list->table,sizeof(RecvTable))&&text_is(list->table->name,"DT_CSPlayer")){root=list->table;break;}
        list=list->next;
    }
    if(!root)return false;
    offsets.sim=find(root,"m_flSimulationTime");offsets.yaw=find(root,"m_angEyeAngles[1]");
    offsets.lby=find(root,"m_flLowerBodyYawTarget");offsets.pose=find(root,"m_flPoseParameter");
    offsets.velocity=find(root,"m_vecVelocity[0]");if(offsets.velocity<0)offsets.velocity=find(root,"m_vecVelocity");
    offsets.duck=find(root,"m_flDuckAmount");offsets.origin=find(root,"m_vecOrigin");
    offsets.flags=find(root,"m_fFlags");offsets.health=find(root,"m_iHealth");
    offsets.life=find(root,"m_lifeState");offsets.team=find(root,"m_iTeamNum");
    const int fields[]={offsets.sim,offsets.yaw,offsets.velocity,offsets.duck,offsets.origin,offsets.flags,offsets.health,offsets.team};
    sr_driver_status.netvar_mask=0;
    for(unsigned i=0;i<8;++i)if(fields[i]>=0)sr_driver_status.netvar_mask|=1u<<i;
    if(offsets.lby>=0)sr_driver_status.netvar_mask|=1u<<8;
    if(offsets.pose>=0)sr_driver_status.netvar_mask|=1u<<9;
    return (sr_driver_status.netvar_mask&255u)==255u;
}
struct Variables {
    void *rate=nullptr,*ratio=nullptr,*interp=nullptr,*unlag=nullptr,*min_rate=nullptr,*max_rate=nullptr,*min_ratio=nullptr,*max_ratio=nullptr,*teammates=nullptr,*fps=nullptr;
} vars;
void* find_var(const char* name){return cvars?method<void*(__thiscall*)(void*,const char*)>(cvars,15)(cvars,name):nullptr;}
float number(void* var,float fallback) {
    if(!var)return fallback;
    const float value=method<float(__thiscall*)(void*)>(var,12)(var);
    return std::isfinite(value)?value:fallback;
}
void set_number(void* var,float value){if(var)method<void(__thiscall*)(void*,float)>(var,15)(var,value);}
void cache_variables() {
    cvars=resolve_interface(L"vstdlib.dll","VEngineCvar007");
    vars={find_var("cl_updaterate"),find_var("cl_interp_ratio"),find_var("cl_interp"),find_var("sv_maxunlag"),
        find_var("sv_minupdaterate"),find_var("sv_maxupdaterate"),find_var("sv_client_min_interp_ratio"),
        find_var("sv_client_max_interp_ratio"),find_var("mp_teammates_are_enemies"),find_var("fps_max")};
}
bool alive(void* entity) {
    return entity&&read<int>(entity,offsets.health)>0&&(offsets.life<0||read<unsigned char>(entity,offsets.life)==0);
}
void* entity(unsigned index){return method<void*(__thiscall*)(void*,int)>(entities,3)(entities,static_cast<int>(index));}
bool dormant(unsigned index) {
    void* networkable=method<void*(__thiscall*)(void*,int)>(entities,0)(entities,static_cast<int>(index));
    return !networkable||method<bool(__thiscall*)(void*)>(networkable,9)(networkable);
}
unsigned identity(unsigned player,void* object) {
    alignas(16) std::array<unsigned char,512> info{};
    unsigned value=static_cast<unsigned>(reinterpret_cast<std::uintptr_t>(object))^(player*0x9e3779b9u);
    if(method<bool(__thiscall*)(void*,int,void*)>(engine,8)(engine,static_cast<int>(player),info.data())) {
        const unsigned low=read<unsigned>(info.data(),8),high=read<unsigned>(info.data(),12);
        value^=low+(high*33u);
        // Source player_info_t: name[128] follows the 64-bit account ID; userid
        // at +0x90 distinguishes bot/reconnected occupants of a reused slot.
        value^=read<unsigned>(info.data(),0x90)*0x85ebca6bu;
    }
    return value?value:1;
}
void mirror_stats() {
    const auto stats=shared_engine().stats();auto& s=sr_driver_status;
    s.tracked=controller.tracked;s.applied=controller.applied;s.blocked=controller.blocked;
    s.invalid_controls=controller.invalid_controls;
    s.feeds=stats.feeds;s.records=stats.records;s.duplicates=stats.duplicates;s.rejected=stats.rejected;
    s.selected=stats.selected;s.fallback=stats.fallback;s.memory_bytes=stats.memory_bytes;
}
void feedback_boundary();
void feedback_register();
bool __cdecl shot_capture(unsigned*,void*);
void update() {
    const auto started=std::chrono::steady_clock::now();FrameInput input;
    auto* globals=at<unsigned char*>(gs_globals);
    const bool in_game=method<bool(__thiscall*)(void*)>(engine,26)(engine);
    if(!in_game||!globals){controller.reset({reinterpret_cast<unsigned char*>(plist_base)});feedback.reset();mirror_stats();return;}
    const float now=read<float>(globals,0x10),interval=read<float>(globals,0x20);
    const int local=method<int(__thiscall*)(void*)>(engine,12)(engine);
    void* self=local>=1&&local<=64?entity(static_cast<unsigned>(local)):nullptr;
    if(!alive(self)||!std::isfinite(now)||!std::isfinite(interval)||interval<.001f||interval>.1f) {
        controller.suspend({reinterpret_cast<unsigned char*>(plist_base)});mirror_stats();return;
    }
    const int team=read<int>(self,offsets.team);const bool free_for_all=number(vars.teammates,0)>0;
    float rate=std::max(1.f,number(vars.rate,1/interval));
    const float min_rate=number(vars.min_rate,0),max_rate=number(vars.max_rate,0);
    if(min_rate>0&&max_rate>=min_rate)rate=std::clamp(rate,min_rate,max_rate);
    float ratio=number(vars.ratio,2);const float low=number(vars.min_ratio,-1),high=number(vars.max_ratio,-1);
    if(low>=0&&high>=low)ratio=std::clamp(ratio,low,high);
    const float lerp=std::clamp(std::max(number(vars.interp,0),std::max(0.f,ratio)/rate),0.f,.5f);
    const float unlag=std::clamp(number(vars.unlag,.2f),.01f,1.f);
    float latency=0;void* channel=method<void*(__thiscall*)(void*)>(engine,78)(engine);
    if(channel)latency=method<float(__thiscall*)(void*,int)>(channel,10)(channel,0);
    if(!std::isfinite(latency))latency=0;latency=std::clamp(latency,0.f,2.f);
    const int count=std::clamp(read<int>(globals,0x18),0,64);
    for(int index=1;index<=count;++index) {
        if(index==local)continue;
        void* object=entity(static_cast<unsigned>(index));if(!object||dormant(static_cast<unsigned>(index)))continue;
        if(!alive(object)){
            auto& target=input.players[static_cast<unsigned>(index)];
            if(controller.identity(static_cast<unsigned>(index))){target.preserve_learning=true;target.seen_identity=identity(static_cast<unsigned>(index),object);}
            continue;
        }
        const int enemy_team=read<int>(object,offsets.team);
        if(enemy_team<2||(!free_for_all&&team==enemy_team))continue;
        auto& target=input.players[static_cast<unsigned>(index)];auto& s=target.sample;target.valid=true;
        s.player=static_cast<unsigned>(index);s.identity=identity(s.player,object);
        s.flags=(read<unsigned>(object,offsets.flags)&1u)?stock_resolver::Ground:0;
        if(offsets.lby>=0)s.flags|=stock_resolver::Lby;
        s.simulation_time=read<float>(object,offsets.sim);s.now=now;s.interval=interval;
        s.latency=latency;s.lerp=lerp;s.max_unlag=unlag;
        s.eye_yaw=read<float>(object,offsets.yaw);s.lower_body_yaw=offsets.lby>=0?read<float>(object,offsets.lby):0;
        if(offsets.pose>=0) {
            const float pose=read<float>(object,offsets.pose+11*4);
            if(std::isfinite(pose)&&pose>=0&&pose<=1){s.flags|=stock_resolver::Pose;s.pose_yaw=pose*120-60;}
        }
        s.velocity_x=read<float>(object,offsets.velocity);s.velocity_y=read<float>(object,offsets.velocity+4);
        s.duck=read<float>(object,offsets.duck);
        s.origin_x=read<float>(object,offsets.origin);s.origin_y=read<float>(object,offsets.origin+4);s.origin_z=read<float>(object,offsets.origin+8);
    }
    controller.update(input,{reinterpret_cast<unsigned char*>(plist_base)},threshold);mirror_stats();
    auto& status=sr_driver_status;status.last_update_ms=std::chrono::duration<float,std::milli>(std::chrono::steady_clock::now()-started).count();
    status.worst_update_ms=std::max(status.worst_update_ms,status.last_update_ms);
}
void feedback_publish() {
    auto& status=sr_feedback_status;
    InterlockedIncrement(reinterpret_cast<volatile LONG*>(&status.sequence));
    sr_feedback_log.shots=feedback.shots();status.counters=feedback.counters();
    status.last_serial=0;for(const auto& shot:feedback.shots())status.last_serial=std::max(status.last_serial,shot.serial);
    status.bytes=sizeof(sr_feedback_log);
    InterlockedIncrement(reinterpret_cast<volatile LONG*>(&status.sequence));
}
void feedback_boundary() {
    if(!sr_feedback_status.enabled)return;
    feedback.boundary(GetTickCount64(),[](const stock_resolver::ShotToken& token) {
        if(!sr_feedback_status.learning)return 0u;
        auto* object=entity(token.player);auto& model=shared_engine();
        const float before=model.learned(token.player,token.state,token.hypothesis);
        if(!object||identity(token.player,object)!=token.identity||!model.confirm(token))return 0u;
        return model.learned(token.player,token.state,token.hypothesis)>before?2u:1u;
    });
    feedback_publish();
}
bool __cdecl shot_capture(unsigned* registers,void*) {
    if(!sr_feedback_status.enabled||!sr_feedback_status.listening||sr_driver_status.state!=Active)return false;
    FeedbackGuard guard;if(!guard.locked)return false;
    const auto* frame=reinterpret_cast<const unsigned char*>(registers)+36;
    auto* candidate=read<void*>(frame,0x18);auto* weapon=read<void*>(frame,0x14);auto* command=read<void*>(frame,0x28);
    const auto reject=[](){feedback.reject();return false;};
    if(!readable(candidate,0xb8)||!readable(weapon,0xe8)||!readable(command,12))return reject();
    stock_feedback::Shot shot{};shot.command=read<unsigned>(command,4);shot.native_id=registers[1];
    shot.target=read<unsigned>(candidate,4);shot.record_tick=read<unsigned>(candidate,0xb4);
    shot.weapon=read<unsigned>(weapon,0xd8);shot.hitbox=read<unsigned>(candidate,0x2c);shot.created_ms=GetTickCount64();
    if(!shot.command||shot.target<1||shot.target>64||!shot.record_tick||shot.hitbox>18)return reject();
    for(unsigned i=0;i<3;++i){shot.point[i]=read<float>(candidate,0xc+i*4);shot.eye[i]=read<float>(weapon,0xdc+i*4);
        if(!std::isfinite(shot.point[i])||!std::isfinite(shot.eye[i]))return reject();}
    shot.hc=read<float>(candidate,0x38);shot.predicted_damage=static_cast<float>(read<int>(candidate,0x28));
    if(!std::isfinite(shot.hc)||shot.hc<0||shot.hc>1)shot.hc=-1;
    if(shot.hc>=0)controller.shot_token(shot.target,shot.record_tick,{reinterpret_cast<unsigned char*>(plist_base)},shot.token);
    feedback.intent(shot);return false;
}
unsigned event_weapon(const char* name) {
    if(!name)return 0;
    if(!std::strncmp(name,"weapon_",7))name+=7;
    const char* keys[]={"deagle","elite","fiveseven","glock","ak47","aug","awp","famas","g3sg1","galilar","m249","m4a1","mac10","p90","mp5sd","ump45","xm1014","bizon","mag7","negev","sawedoff","tec9","taser","hkp2000","mp7","mp9","nova","p250","scar20","sg556","ssg08","m4a1_silencer","usp_silencer","cz75a","revolver"};
    const unsigned ids[]={1,2,3,4,7,8,9,10,11,13,14,16,17,19,23,24,25,26,27,28,29,30,31,32,33,34,35,36,38,39,40,60,61,63,64};
    for(unsigned i=0;i<sizeof(ids)/sizeof(ids[0]);++i)if(!std::strcmp(name,keys[i]))return ids[i];return 0;
}
void __fastcall event_destroy(void*,void*,unsigned){}
int __fastcall event_debug(void*,void*){return 42;}
void __fastcall event_fire(void*,void*,void* event) {
    if(!sr_feedback_status.listening||!readable(event,4))return;
    FeedbackGuard guard;if(!guard.locked)return;
    const char* name=method<const char*(__thiscall*)(void*)>(event,1)(event);if(!name)return;
    const auto integer=[&](const char* key){return method<int(__thiscall*)(void*,const char*,int)>(event,6)(event,key,0);};
    const auto player=[&](const char* key){return method<int(__thiscall*)(void*,int)>(engine,9)(engine,integer(key));};
    const int local=method<int(__thiscall*)(void*)>(engine,12)(engine);const auto now=GetTickCount64();
    if(!std::strcmp(name,"round_start")) {feedback.reset();controller.reset({reinterpret_cast<unsigned char*>(plist_base)});}
    else if(!std::strcmp(name,"player_disconnect")) {
        feedback.reset();const int who=player("userid");if(who>=1&&who<=64)controller.forget(static_cast<unsigned>(who),{reinterpret_cast<unsigned char*>(plist_base)});
    } else if(!std::strcmp(name,"weapon_fire")&&player("userid")==local) {
        const char* weapon=method<const char*(__thiscall*)(void*,const char*,const char*)>(event,9)(event,"weapon","");
        feedback.fire(event_weapon(weapon),now);
    } else if(!std::strcmp(name,"bullet_impact")&&player("userid")==local) {
        const auto real=[&](const char* key){return method<float(__thiscall*)(void*,const char*,float)>(event,8)(event,key,0);};
        const float x=real("x"),y=real("y"),z=real("z");
        if(std::isfinite(x)&&std::isfinite(y)&&std::isfinite(z))feedback.impact(x,y,z,now);
    } else if(!std::strcmp(name,"player_hurt")&&player("attacker")==local) {
        const int target=player("userid"),group=integer("hitgroup"),damage=integer("dmg_health"),remaining=integer("health");
        if(target>=1&&target<=64&&group>=0&&group<=10&&damage>0&&damage<=10000&&remaining>=0)
            feedback.hurt(static_cast<unsigned>(target),static_cast<unsigned>(group),static_cast<unsigned>(damage),static_cast<unsigned>(remaining),now);
    }
}
void* event_table[]={reinterpret_cast<void*>(event_destroy),reinterpret_cast<void*>(event_fire),reinterpret_cast<void*>(event_debug)};
struct EventListener {void** table;};EventListener event_listener{event_table};
void feedback_register() {
    if(!sr_feedback_status.enabled||sr_feedback_status.listening||!engine||!method<bool(__thiscall*)(void*)>(engine,26)(engine))return;
    const auto now=GetTickCount64();if(now<feedback_retry_at)return;feedback_retry_at=now+2000;
    if(!event_manager)event_manager=resolve_interface(L"engine.dll","GAMEEVENTSMANAGER002");
    if(!readable(event_manager,4)||!readable(*static_cast<void***>(event_manager),24)){sr_feedback_status.error=1;return;}
    for(const char* name:{"weapon_fire","bullet_impact","player_hurt","round_start","player_disconnect"}) {
        if(!method<bool(__thiscall*)(void*,void*,const char*,bool)>(event_manager,3)(event_manager,&event_listener,name,false)) {
            method<void(__thiscall*)(void*,void*)>(event_manager,5)(event_manager,&event_listener);sr_feedback_status.error=2;return;
        }
    }
    sr_feedback_status.error=0;sr_feedback_status.listening=1;
}

void __fastcall notify(void* object,void*,int stage) {
    ++sr_driver_status.callbacks;
    if(stage==4&&sr_driver_status.enabled) {
        feedback_register();FeedbackGuard guard;
        if(guard.locked){feedback_boundary();++sr_driver_status.updates;update();}
    }
    if(stage==5) {
        ++sr_driver_status.frames;auto* globals=at<unsigned char*>(gs_globals);
        if(globals)shared_engine().frame(read<float>(globals,8));
        if(fps_limit&&vars.fps) {
            const float current=number(vars.fps,0);
            if(method<bool(__thiscall*)(void*)>(engine,26)(engine)) {
                if(fps_owned&&std::fabs(current-static_cast<float>(fps_limit))>.01f){fps_owned=false;fps_limit=0;}
                else if(!fps_owned){fps_original=current;set_number(vars.fps,static_cast<float>(fps_limit));fps_owned=true;}
            }else if(fps_owned){if(std::fabs(current-static_cast<float>(fps_limit))<.01f)set_number(vars.fps,fps_original);fps_owned=false;}
        }
    }
    previous(object,stage);
}
bool fail(Error code,const char* text){
    sr_driver_status.error=code;sr_driver_status.state=Failed;error_text=text;
    if(code==CoreContract||code==Netvars)SetLastError(ERROR_REVISION_MISMATCH);
    else if(code==ClientInterface)SetLastError(ERROR_MOD_NOT_FOUND);
    else if(code==WaitHook)SetLastError(ERROR_TIMEOUT);
    else if(code==HookLost)SetLastError(ERROR_RETRY);
    return false;
}
bool matches(const unsigned char* image,unsigned address,const unsigned char* data,unsigned size){return std::memcmp(image+(address-base),data,size)==0;}
}
const char* last_error(){return error_text;}
bool prepare(unsigned char* image,unsigned size,HMODULE module) {
    sr_driver_status.error=None;
    if(nl_hypotheses::selected_mode!=nl_hypotheses::StockResolver){sr_driver_status.state=Off;return true;}
    constexpr unsigned char descriptors[]={1,14,0,0,0,0,0,0,0xc2,0x5b,0xfe,0x6a,5,0,0,0,3,20,0xc4,0xff,0x3c,0,0,0,0x27,0xa5,0xba,0xfb,8,0,0,0};
    constexpr unsigned char tick[]={0xa1,4,0x7b,0x46,0x43,0x51,0x51,0xf3,0x0f,0x10,0x40,0x20};
    if(reinterpret_cast<std::uintptr_t>(image)!=base||size!=image_size||
       !matches(image,0x4346d5a8,descriptors,sizeof(descriptors))||!matches(image,0x433b75a4,tick,sizeof(tick)))
        return fail(CoreContract,"Native resolver: GS player-override/global layout differs.");
    wchar_t path[32768]{};
    if(!GetModuleFileNameW(module,path,32768))return fail(CoreContract,"Native resolver: cannot locate settings.");
    auto* slash=std::wcsrchr(path,L'\\');if(!slash||slash-path>32700)return fail(CoreContract,"Native resolver: settings path is too long.");
    std::wcscpy(slash+1,L"skeet_nl_points.ini");
    sr_driver_status.enabled=GetPrivateProfileIntW(L"resolver",L"enabled",1,path);
    const unsigned percent=GetPrivateProfileIntW(L"resolver",L"confidence",65,path);
    sr_feedback_status.enabled=GetPrivateProfileIntW(L"resolver",L"feedback",1,path);
    sr_feedback_status.learning=GetPrivateProfileIntW(L"resolver",L"feedback_learning",1,path);
    if(sr_feedback_status.enabled>1||sr_feedback_status.learning>1)return fail(CoreContract,"Native resolver: feedback settings must be 0 or 1.");
    fps_limit=GetPrivateProfileIntW(L"resolver",L"fps_limit",0,path);
    if(sr_driver_status.enabled>1||percent<50||percent>95||(fps_limit&&(fps_limit<30||fps_limit>500)))
        return fail(CoreContract,"Native resolver: invalid enabled/confidence/fps_limit settings.");
    threshold=static_cast<float>(percent)*.01f;sr_driver_status.threshold=threshold;
    if(!sr_driver_status.enabled){sr_driver_status.state=Off;return true;}
    client=resolve_interface(L"client.dll","VClient018");
    if(!client||!readable(client,4))return fail(ClientInterface,"Native resolver: VClient018 is unavailable.");
    original_table=*static_cast<void***>(client);
    if(!readable(original_table,(frame_stage+1)*4))return fail(ClientInterface,"Native resolver: incomplete VClient018 vtable.");
    original_entry=original_table[frame_stage];
    if(!readable(original_entry,original_code.size()))return fail(ClientInterface,"Native resolver: invalid original FrameStageNotify.");
    std::memcpy(original_code.data(),original_entry,original_code.size());
    if(sr_feedback_status.enabled) {
        if(!stock_feedback::install_hook(image,size,reinterpret_cast<unsigned>(shot_capture),true))return fail(CoreContract,"Native resolver: shot capture contract or installation failed.");
        sr_feedback_status.installed=1;sr_feedback_status.bytes=sizeof(sr_feedback_log);
    }
    sr_driver_status.client=static_cast<unsigned>(reinterpret_cast<std::uintptr_t>(client));sr_driver_status.state=Prepared;
    return true;
}
bool start() {
    if(nl_hypotheses::selected_mode!=nl_hypotheses::StockResolver||!sr_driver_status.enabled)return true;
    if(sr_driver_status.state!=Prepared)return fail(ClientInterface,"Native resolver was not prepared before GS startup.");
    sr_driver_status.state=Waiting;const auto began=GetTickCount64();void** stable_slot=nullptr;void* stable_entry=nullptr;ULONGLONG stable_since=0;
    while(GetTickCount64()-began<60000) {
        auto** table=*static_cast<void***>(client);
        if(readable(table,(frame_stage+1)*4)) {
            void* entry=table[frame_stage];
            const bool changed=table!=original_table||entry!=original_entry||
                (readable(entry,original_code.size())&&std::memcmp(entry,original_code.data(),original_code.size())!=0);
            engine=at<void*>(gs_engine);entities=at<void*>(gs_entities);
            if(changed&&engine&&entities&&at<void*>(gs_globals)&&readable(entry,16)) {
                if(stable_slot!=table+frame_stage||stable_entry!=entry){stable_slot=table+frame_stage;stable_entry=entry;stable_since=GetTickCount64();}
                if(GetTickCount64()-stable_since>=250) {
                    if(!resolve_netvars())return fail(Netvars,"Native resolver: required DT_CSPlayer netvars were not found.");
                    cache_variables();event_manager=resolve_interface(L"engine.dll","GAMEEVENTSMANAGER002");previous=reinterpret_cast<StageFn>(entry);hook_slot=table+frame_stage;
                    DWORD old=0;if(!VirtualProtect(hook_slot,4,PAGE_READWRITE,&old))return fail(Protect,"Native resolver: cannot write FrameStageNotify slot.");
                    void* replaced=InterlockedCompareExchangePointer(hook_slot,reinterpret_cast<void*>(&notify),entry);
                    DWORD unused=0;const bool restored=VirtualProtect(hook_slot,4,old,&unused)!=0;
                    if(replaced!=entry)return fail(HookLost,"Native resolver: FrameStageNotify changed during installation.");
                    if(!restored){InterlockedCompareExchangePointer(hook_slot,entry,reinterpret_cast<void*>(&notify));return fail(Protect,"Native resolver: cannot restore vtable protection.");}
                    sr_driver_status.previous=static_cast<unsigned>(reinterpret_cast<std::uintptr_t>(entry));
                    sr_driver_status.slot=static_cast<unsigned>(reinterpret_cast<std::uintptr_t>(hook_slot));
                    sr_driver_status.installed=1;sr_driver_status.state=Active;error_text="Native resolver installed.";return true;
                }
            }
        }
        Sleep(50);
    }
    return fail(WaitHook,"GS entry started, but native resolver did not observe the GS FrameStage hook within 60 seconds.");
}
}
