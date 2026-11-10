// The production native driver runs with controlled Source interface objects.
// No Lua runtime, Lua file, FFI, or game process is used in this fixture.
#define SR_NATIVE_FIXTURE
#include "native_driver.h"
namespace stock_native {stock_resolver::Engine& shared_engine(){static stock_resolver::Engine engine;return engine;}}
#include "native_driver.cpp"
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <filesystem>
#include "../source/steam/feedback_reports.h"
using namespace stock_native;
namespace {
unsigned checks=0,gs_calls=0,gs_saw_force=0;
bool in_game=true,enemy_dormant=false;unsigned user_id=42;
struct Object {void** table;};
void* manager_table[6]{},*event_vtable[10]{};Object fake_manager{manager_table};
void* registered_listener=nullptr;unsigned registrations=0;
struct FakeEvent {void** table=event_vtable;const char* name="";int userid=1,attacker=1,group=1,damage=120,remaining=0;};
void* client_old_table[38]{},*client_gs_table[38]{},*engine_table[79]{},*entity_table[4]{},*network_table[10]{};
Object fake_client{client_old_table},fake_engine{engine_table},fake_entities{entity_table},fake_network{network_table};
std::array<unsigned char,512> self_data{},enemy_data{},global_data{};
RecvProp props[11]{};RecvTable property_table{},root_table{};RecvProp base_prop{};ClientClass player_class{};
constexpr int sim=64,yaw=68,lby=72,pose=80,velocity=176,duck=188,origin=192,flags=204,health=208,life=212,team=216;
void check(bool value,const char* text){++checks;if(!value){std::fprintf(stderr,"FAIL: %s\n",text);std::exit(1);}}
template<class T> void put(void* p,unsigned off,T value){std::memcpy(static_cast<unsigned char*>(p)+off,&value,sizeof(value));}
void __fastcall old_stage(void*,void*,int){++gs_calls;}
void __fastcall gs_stage(void*,void*,int stage){++gs_calls;if(stage==4&&at<unsigned char>(plist_base+2*stride+5))++gs_saw_force;}
ClientClass* __fastcall classes(void*,void*){return &player_class;}
bool __fastcall is_game(void*,void*){return in_game;}
int __fastcall local_player(void*,void*){return 1;}
void* __fastcall channel(void*,void*){return nullptr;}
void* __fastcall get_entity(void*,void*,int index){return index==1?self_data.data():index==2?enemy_data.data():nullptr;}
void* __fastcall network(void*,void*,int index){return index==2?&fake_network:nullptr;}
bool __fastcall is_dormant(void*,void*){return enemy_dormant;}
bool __fastcall player_info(void*,void*,int index,void* out){put(out,8,static_cast<unsigned>(index+100));put(out,12,0u);put(out,0x90,user_id);return true;}
int __fastcall by_user(void*,void*,int id){return id==1?1:id==static_cast<int>(user_id)?2:0;}
bool __fastcall add_event(void*,void*,void* listener,const char*,bool){registered_listener=listener;++registrations;return true;}
void __fastcall remove_event(void*,void*,void*){registered_listener=nullptr;}
const char* __fastcall event_name(void* self,void*){return static_cast<FakeEvent*>(self)->name;}
int __fastcall event_int(void* self,void*,const char* name,int fallback){
    const auto& e=*static_cast<FakeEvent*>(self);
    if(!std::strcmp(name,"userid"))return e.userid;if(!std::strcmp(name,"attacker"))return e.attacker;
    if(!std::strcmp(name,"hitgroup"))return e.group;if(!std::strcmp(name,"dmg_health"))return e.damage;
    if(!std::strcmp(name,"health"))return e.remaining;return fallback;
}
float __fastcall event_float(void*,void*,const char* name,float){return !std::strcmp(name,"x")?200.f:0.f;}
const char* __fastcall event_string(void*,void*,const char*,const char*){return "scar20";}
void emit(const char* name){FakeEvent e;e.name=name;e.userid=!std::strcmp(name,"player_hurt")?static_cast<int>(user_id):1;
    method<void(__thiscall*)(void*,void*)>(registered_listener,1)(registered_listener,&e);}
void tables() {
    client_old_table[8]=reinterpret_cast<void*>(classes);client_old_table[37]=reinterpret_cast<void*>(old_stage);
    std::copy(std::begin(client_old_table),std::end(client_old_table),std::begin(client_gs_table));client_gs_table[37]=reinterpret_cast<void*>(gs_stage);
    manager_table[3]=reinterpret_cast<void*>(add_event);manager_table[5]=reinterpret_cast<void*>(remove_event);
    event_vtable[1]=reinterpret_cast<void*>(event_name);event_vtable[6]=reinterpret_cast<void*>(event_int);
    event_vtable[8]=reinterpret_cast<void*>(event_float);event_vtable[9]=reinterpret_cast<void*>(event_string);
    engine_table[9]=reinterpret_cast<void*>(by_user);
    engine_table[8]=reinterpret_cast<void*>(player_info);engine_table[12]=reinterpret_cast<void*>(local_player);
    engine_table[26]=reinterpret_cast<void*>(is_game);engine_table[78]=reinterpret_cast<void*>(channel);
    entity_table[0]=reinterpret_cast<void*>(network);entity_table[3]=reinterpret_cast<void*>(get_entity);network_table[9]=reinterpret_cast<void*>(is_dormant);
    const char* names[]={"m_flSimulationTime","m_angEyeAngles[1]","m_flLowerBodyYawTarget","m_flPoseParameter","m_vecVelocity[0]","m_flDuckAmount","m_vecOrigin","m_fFlags","m_iHealth","m_lifeState","m_iTeamNum"};
    const int positions[]={sim,yaw,lby,pose,velocity,duck,origin,flags,health,life,team};
    for(unsigned i=0;i<11;++i){props[i].name=names[i];props[i].offset=positions[i]-16;props[i].type=1;}
    property_table={props,11,nullptr,"DT_BasePlayer",1,1,{0,0}};
    base_prop.name="baseclass";base_prop.type=6;base_prop.offset=16;base_prop.table=&property_table;
    root_table={&base_prop,1,nullptr,"DT_CSPlayer",1,1,{0,0}};player_class={nullptr,nullptr,"CCSPlayer",&root_table,nullptr,40};
}
void fields(unsigned tick) {
    put(global_data.data(),0x10,10+static_cast<float>(tick)/64+.1f);put(global_data.data(),0x20,1.f/64);put(global_data.data(),0x18,2);put(global_data.data(),8,1.f/120);
    put(self_data.data(),health,100);put(self_data.data(),team,2);
    put(enemy_data.data(),health,100);put(enemy_data.data(),team,3);put(enemy_data.data(),flags,1u);
    put(enemy_data.data(),sim,10+static_cast<float>(tick)/64);put(enemy_data.data(),yaw,60.f);put(enemy_data.data(),lby,0.f);
    put(enemy_data.data(),pose+44,0.f);put(enemy_data.data(),velocity,100.f);put(enemy_data.data(),duck,0.f);put(enemy_data.data(),origin,static_cast<float>(tick)*1.5625f);
}
void step(int stage=4){method<void(__thiscall*)(void*,int)>(&fake_client,37)(&fake_client,stage);}
}
namespace stock_native {namespace {
void* fixture_interface(const wchar_t* module,const char* name){
    if(!_wcsicmp(module,L"engine.dll")&&!std::strcmp(name,"GAMEEVENTSMANAGER002"))return &fake_manager;
    return !_wcsicmp(module,L"client.dll")&&std::strcmp(name,"VClient018")==0?&fake_client:nullptr;
}
}}
int main(int argc,char** argv) {
    if(argc!=3)return 2;
    auto* image=static_cast<unsigned char*>(VirtualAlloc(reinterpret_cast<void*>(0x43310000),0x2fc000,MEM_RESERVE|MEM_COMMIT,PAGE_READWRITE));
    check(image==reinterpret_cast<void*>(0x43310000),"fixture pinned GS image allocation");
    std::ifstream file(argv[1],std::ios::binary);file.read(reinterpret_cast<char*>(image),0x2fc000);check(file.gcount()==0x2fc000,"actual pinned core bytes");tables();
    nl_hypotheses::selected_mode=nl_hypotheses::StockResolver;
    image[0x4346d5b4-0x43310000]^=1;
    check(!prepare(image,0x2fc000,GetModuleHandleW(nullptr))&&sr_driver_status.error==CoreContract,"wrong GS descriptor rejected");
    image[0x4346d5b4-0x43310000]^=1;
    check(prepare(image,0x2fc000,GetModuleHandleW(nullptr))&&sr_driver_status.state==Prepared,"native prepare with NO Lua file");
    put(reinterpret_cast<void*>(gs_engine),0,reinterpret_cast<void*>(&fake_engine));
    put(reinterpret_cast<void*>(gs_entities),0,reinterpret_cast<void*>(&fake_entities));
    put(reinterpret_cast<void*>(gs_globals),0,global_data.data());
    Controls controls{reinterpret_cast<unsigned char*>(plist_base)};
    for(unsigned p=1;p<=64;++p)controls.set(p,false,17);
    fake_client.table=client_gs_table;
    check(start()&&sr_driver_status.installed==1&&sr_driver_status.state==Active,"native vtable hook installed after GS hook");
    check(offsets.sim==sim&&offsets.yaw==yaw&&offsets.pose==pose&&offsets.health==health,"real RecvTable walker includes inherited offset");
    check(sr_driver_status.netvar_mask==1023,"all required and optional netvars resolved");
    for(unsigned tick=0;tick<8;++tick){fields(tick);step();}
    bool enabled=false;int value=0;
    check(controls.get(2,enabled,value)&&enabled&&value==-60,"Source data reaches C++ model and real GS override layout");
    check(gs_calls==8&&gs_saw_force>0,"original GS callback runs and sees override in same update");
    check(sr_driver_status.updates==8&&sr_driver_status.applied==1&&sr_driver_status.tracked==1,"native driver counters represent active integration");
    check(sr_driver_status.records==8&&sr_driver_status.memory_bytes<262144,"bounded model memory");
    for(unsigned n=0;n<20;++n)step();check(sr_driver_status.records==8&&sr_driver_status.duplicates==20,"native repeat-update deduplication");
    controls.set(2,true,29);fields(8);step();check(controls.get(2,enabled,value)&&enabled&&value==29&&sr_driver_status.blocked==1,"manual edit wins");
    enemy_dormant=true;fields(9);step();check(controls.get(2,enabled,value)&&enabled&&value==29,"dormancy preserves manual control");
    controls.set(2,false,17);enemy_dormant=false;++user_id;
    for(unsigned t=10;t<18;++t){fields(t);step();}
    check(controls.get(2,enabled,value)&&enabled&&value==-60,"new player history reacquires control");
    enemy_dormant=true;fields(18);step();check(controls.get(2,enabled,value)&&!enabled&&value==17,"dormancy restores our original values");
    enemy_dormant=false;for(unsigned t=19;t<27;++t){fields(t);step();}
    put(self_data.data(),health,0);step();check(controls.get(2,enabled,value)&&!enabled&&value==17,"local death releases our overrides");
    in_game=false;step();check(sr_driver_status.tracked==0,"disconnect clears history");
    for(unsigned i=0;i<16;++i)step(5);
    check(shared_engine().frame_stats().count==16&&sr_driver_status.frames==16,"native frame-time collection");
    check(registrations==5&&registered_listener&&sr_feedback_status.listening==1,"production Source event registration ABI");
    in_game=true;enemy_dormant=false;for(unsigned t=30;t<42;++t){fields(t);step();}
    std::array<unsigned char,0xe8> weapon{};std::array<unsigned char,0xb8> candidate{};unsigned command[3]={0,888,0};
    std::array<unsigned,80> capture{};auto* frame=reinterpret_cast<unsigned char*>(capture.data())+36;
    put(frame,0x14,weapon.data());put(frame,0x18,candidate.data());put(frame,0x28,command);capture[1]=5;
    put(weapon.data(),0xd8,38u);put(candidate.data(),4,2u);put(candidate.data(),0xb4,681u);
    put(candidate.data(),0xc,100.f);put(candidate.data(),0x38,.8f);put(candidate.data(),0x28,120);
    shot_capture(capture.data(),nullptr);emit("weapon_fire");emit("bullet_impact");emit("player_hurt");step();
    check(sr_feedback_status.counters.credits==1&&shared_engine().learned(2,1,0)==0,"first uniquely linked head records compatibility without reinforcement");
    fields(42);step();command[1]=889;capture[1]=6;put(candidate.data(),0xb4,682u);
    shot_capture(capture.data(),nullptr);emit("weapon_fire");emit("bullet_impact");emit("player_hurt");step();
    check(sr_feedback_status.counters.credits==2&&shared_engine().learned(2,1,0)>0,"second native event sequence reaches bounded model learning");
    check((sr_feedback_log.shots[1].bits&stock_feedback::Reinforced)!=0,"exported shot log exposes actual reinforcement");
    sr_feedback_status.learning=0;fields(43);step();const float before=shared_engine().learned(2,1,0);
    command[1]=890;capture[1]=7;put(candidate.data(),0xb4,683u);shot_capture(capture.data(),nullptr);
    emit("weapon_fire");emit("bullet_impact");emit("player_hurt");step();
    check(sr_feedback_status.counters.credits==2&&shared_engine().learned(2,1,0)==before,"INI learning off retains telemetry without training");
    sr_feedback_status.learning=1;emit("round_start");step();
    check(shared_engine().learned(2,1,0)>0&&sr_feedback_status.counters.resets>0&&sr_driver_status.applied==0,"round retires lag records and pending shots while preserving weak identity evidence");
    const auto shot_path=std::filesystem::path(argv[2]).parent_path()/L"resolver_shots.json";
    check(feedback_reports::save_to(shot_path.c_str(),GetCurrentProcess(),&sr_feedback_status,&sr_feedback_log),"production external shot archive writer");
    std::ifstream shot_file(shot_path);std::string shot_text((std::istreambuf_iterator<char>(shot_file)),std::istreambuf_iterator<char>());
    check(shot_text.find("\"reinforced\":true")!=std::string::npos&&shot_text.find("\"record_tick\":682")!=std::string::npos,"shot archive contains actual credited record and reinforcement");
    std::ofstream report(argv[2]);report<<"{\"checks\":"<<checks<<",\"production_native_driver\":true,\"source_interfaces\":\"controlled fixture\",\"actual_gs_core_layout\":true,\"external_lua_required\":false,\"native_feedback_bridge\":true,\"feedback_events_checked\":true,\"gameplay_tested\":false}\n";
    check(static_cast<bool>(report),"native evidence written");std::printf("Native C++ driver: %u checks passed, no Lua/FFI.\n",checks);
    return 0;
}
