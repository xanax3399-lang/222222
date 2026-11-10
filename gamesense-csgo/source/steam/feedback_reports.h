#pragma once
#include "../../stock-resolver/feedback_status.h"
#include <string>
namespace feedback_reports {
inline bool save_to(const wchar_t* path,HANDLE process,const void* status_address,const void* log_address) {
    stock_feedback::Status before{},after{};stock_feedback::Log log{};SIZE_T got=0;bool complete=false;
    for(unsigned attempt=0;attempt<3&&!complete;++attempt) {
        if(!ReadProcessMemory(process,status_address,&before,sizeof(before),&got)||got!=sizeof(before)||before.version!=1||before.sequence&1)continue;
        if(before.bytes!=sizeof(log)||!ReadProcessMemory(process,log_address,&log,sizeof(log),&got)||got!=sizeof(log))continue;
        if(!ReadProcessMemory(process,status_address,&after,sizeof(after),&got)||got!=sizeof(after))continue;
        complete=before.sequence==after.sequence&&!(after.sequence&1)&&log.version==1&&log.count==stock_feedback::capacity;
    }
    if(!complete)return false;
    const std::wstring temporary=std::wstring(path)+L"."+std::to_wstring(GetCurrentProcessId())+L".tmp";
    FILE* file=_wfopen(temporary.c_str(),L"wb");if(!file)return false;
    std::fprintf(file,"{\"version\":1,\"capacity\":256,\"latest_serial\":%u,\"learning\":%u,\"listening\":%d,\"shots\":[",after.last_serial,after.learning,static_cast<int>(after.listening));
    bool comma=false;const unsigned first=after.last_serial>stock_feedback::capacity?after.last_serial-stock_feedback::capacity+1:1;
    const char* names[]={"pending","head_hit","body_hit","unknown","unconfirmed","ambiguous","reset"};
    for(unsigned serial=first;serial<=after.last_serial&&serial;++serial) {
        const auto& s=log.shots[(serial-1)%stock_feedback::capacity];if(s.serial!=serial)continue;
        std::fprintf(file,"%s{\"serial\":%u,\"command\":%u,\"native_id\":%u,\"target\":%u,\"weapon\":%u,\"record_tick\":%u,\"hitbox\":%u,\"bits\":%u,\"outcome\":\"%s\",\"hitgroup\":%u,\"damage\":%u,\"remaining\":%u,\"created_ms\":%llu,\"hc\":%.7g,\"predicted_damage\":%.7g,",
            comma?",":"",s.serial,s.command,s.native_id,s.target,s.weapon,s.record_tick,s.hitbox,s.bits,s.outcome<7?names[s.outcome]:"invalid",s.hitgroup,s.damage,s.remaining,static_cast<unsigned long long>(s.created_ms),s.hc,s.predicted_damage);
        std::fprintf(file,"\"identity\":%u,\"generation\":%u,\"epoch\":%u,\"movement_state\":%u,\"hypothesis\":%u,\"offset\":%.7g,\"simulation_time\":%.7g,\"credited\":%s,\"reinforced\":%s,\"point\":[%.7g,%.7g,%.7g],\"eye\":[%.7g,%.7g,%.7g],\"impact\":[%.7g,%.7g,%.7g]}",
            s.token.identity,s.token.generation,s.token.epoch,s.token.state,s.token.hypothesis,s.token.offset,s.token.simulation_time,
            s.bits&stock_feedback::Credited?"true":"false",s.bits&stock_feedback::Reinforced?"true":"false",
            s.point[0],s.point[1],s.point[2],s.eye[0],s.eye[1],s.eye[2],s.impact[0],s.impact[1],s.impact[2]);comma=true;
    }
    std::fputs("]}\n",file);const bool okay=std::fflush(file)==0;const bool closed=std::fclose(file)==0;
    if(!okay||!closed||!MoveFileExW(temporary.c_str(),path,MOVEFILE_REPLACE_EXISTING|MOVEFILE_WRITE_THROUGH)){DeleteFileW(temporary.c_str());return false;}return true;
}
inline bool save(const wchar_t* dll,HANDLE process,const void* status,const void* log) {
    const auto* slash=std::wcsrchr(dll,L'\\');if(!slash)return false;
    const auto path=std::wstring(dll,slash+1)+L"resolver_shots.json";
    if(save_to(path.c_str(),process,status,log))return true;
    wchar_t root[32768]{};const DWORD n=GetEnvironmentVariableW(L"LOCALAPPDATA",root,32768);if(!n||n>32600)return false;
    std::wstring folder=std::wstring(root)+L"\\GameSenseLegacy8802";CreateDirectoryW(folder.c_str(),nullptr);
    folder+=L"\\Reports";CreateDirectoryW(folder.c_str(),nullptr);folder+=L"\\resolver_shots.json";
    return save_to(folder.c_str(),process,status,log);
}
}
