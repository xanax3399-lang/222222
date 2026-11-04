#pragma once
#include <shellapi.h>
namespace launcher_reports {
inline constexpr wchar_t filename[]=L"module_diagnostics.log";
inline std::wstring beside(const wchar_t* dll,const wchar_t* name) {
    const auto* slash=std::wcsrchr(dll,L'\\');
    return slash?std::wstring(dll,slash+1)+name:std::wstring{};
}
inline std::wstring settings(const wchar_t* dll){return beside(dll,L"skeet_nl_points.ini");}
inline bool number(const wchar_t* text,DWORD& result) {
    if(!text||!*text)return false;
    std::uint64_t value=0;
    for(;*text;++text) {
        if(*text<L'0'||*text>L'9')return false;
        value=value*10+static_cast<unsigned>(*text-L'0');
        if(value>0xffffffffULL)return false;
    }
    result=static_cast<DWORD>(value);return true;
}
inline std::wstring fallback(bool create) {
    wchar_t root[32768]{};
    const DWORD n=GetEnvironmentVariableW(L"LOCALAPPDATA",root,32768);
    if(!n||n>=32700)return {};
    std::wstring folder=root;folder+=L"\\GameSenseLegacy8802";
    if(create&&!CreateDirectoryW(folder.c_str(),nullptr)&&GetLastError()!=ERROR_ALREADY_EXISTS)return {};
    folder+=L"\\Reports";
    if(create&&!CreateDirectoryW(folder.c_str(),nullptr)&&GetLastError()!=ERROR_ALREADY_EXISTS)return {};
    return folder+L"\\"+filename;
}
inline bool identity(HANDLE process,FILETIME born) {
    FILETIME actual{},ended{},kernel{},user{};
    if(!GetProcessTimes(process,&actual,&ended,&kernel,&user)||CompareFileTime(&actual,&born))return false;
    wchar_t image[32768]{};DWORD size=32768;
    if(!QueryFullProcessImageNameW(process,0,image,&size))return false;
    const auto* name=std::wcsrchr(image,L'\\');
    return !_wcsicmp(name?name+1:image,L"csgo.exe");
}
// Preserve a previous valid report on failed reads or failed publication. Readers
// see the old complete file or the new complete file, never a truncated snapshot.
inline bool snapshot(const wchar_t* dll,DWORD pid,unsigned sequence,std::wstring& saved) {
    std::wstring output=beside(dll,filename),temporary;
    FILE* file=nullptr;
    for(unsigned attempt=0;attempt<2;++attempt) {
        if(attempt)output=fallback(true);
        if(output.empty()||output.size()>32600)continue;
        temporary=output+L"."+std::to_wstring(GetCurrentProcessId())+L".tmp";
        file=_wfopen(temporary.c_str(),L"wb");if(file)break;
    }
    if(!file)return false;
    FILE* previous=run_log;const bool previous_quiet=diagnostic_quiet;
    run_log=file;diagnostic_quiet=true;
    SYSTEMTIME now{};GetSystemTime(&now);
    diagnostic_printf("Automatic snapshot: %u\nProcess: %lu\nCaptured UTC: %04u-%02u-%02u %02u:%02u:%02u\n",
        sequence,pid,now.wYear,now.wMonth,now.wDay,now.wHour,now.wMinute,now.wSecond);
    const int result=diagnostics(dll,pid);
    diagnostic_printf("\nThese module counters do not identify aim_miss/resolver causes.\n");
    const bool flushed=std::fflush(file)==0;
    const bool closed=std::fclose(file)==0;
    run_log=previous;diagnostic_quiet=previous_quiet;
    if(result||!flushed||!closed||!MoveFileExW(temporary.c_str(),output.c_str(),
            MOVEFILE_REPLACE_EXISTING|MOVEFILE_WRITE_THROUGH)) {
        DeleteFileW(temporary.c_str());return false;
    }
    saved=output;return true;
}
inline void finish(const std::wstring& saved,HANDLE process,unsigned sequence) {
    if(saved.empty())return;
    DWORD code=0;GetExitCodeProcess(process,&code);
    FILE* file=_wfopen(saved.c_str(),L"ab");if(!file)return;
    std::fprintf(file,"\nSession ended. Exit code: %lu. Last successful snapshot: %u.\n"
        "Counters above were captured while the process was alive.\n",code,sequence);
    std::fclose(file);
}
inline int watch(const wchar_t* dll,DWORD pid,FILETIME born) {
    // Separate read-only handle. The monitor has no VM_WRITE, VM_OPERATION or
    // CREATE_THREAD access to the game. Creation time prevents PID reuse.
    Handle process(OpenProcess(SYNCHRONIZE|PROCESS_QUERY_INFORMATION|PROCESS_VM_READ,FALSE,pid));
    if(!process.value||!identity(process.value,born))return 1;
    const std::wstring name=L"Local\\SkeetReports-"+std::to_wstring(pid)+L"-"+
        std::to_wstring(born.dwHighDateTime)+L"-"+std::to_wstring(born.dwLowDateTime);
    Handle mutex(CreateMutexW(nullptr,TRUE,name.c_str()));
    if(!mutex.value)return 1;
    if(GetLastError()==ERROR_ALREADY_EXISTS)return 0;
    const UINT configured=GetPrivateProfileIntW(L"loader",L"report_interval_seconds",10,settings(dll).c_str());
    const DWORD seconds=configured<2?2:(configured>60?60:configured);
    std::wstring saved;unsigned sequence=0;
    for(;;) {
        if(WaitForSingleObject(process.value,0)==WAIT_OBJECT_0)break;
        std::wstring current;
        if(snapshot(dll,pid,sequence+1,current)){++sequence;saved=current;}
        const DWORD waited=WaitForSingleObject(process.value,seconds*1000);
        if(waited==WAIT_OBJECT_0)break;
        if(waited!=WAIT_TIMEOUT){ReleaseMutex(mutex.value);return 1;}
    }
    finish(saved,process.value,sequence);ReleaseMutex(mutex.value);return sequence?0:1;
}
inline DWORD start(const wchar_t* dll,HANDLE process,DWORD pid) {
    if(GetPrivateProfileIntW(L"loader",L"automatic_reports",1,settings(dll).c_str())!=1) {
        log_line("Automatic reports disabled in loader settings.");return 0;
    }
    std::wstring saved;
    if(snapshot(dll,pid,0,saved)) {
        std::puts("Initial report saved. Menu 8 opens the latest report.");
        log_line("Initial automatic report saved.");
    } else log_line("Could not save the initial automatic report.",GetLastError());
    FILETIME born{},ended{},kernel{},user{};wchar_t executable[32768]{};
    const DWORD executable_size=GetModuleFileNameW(nullptr,executable,32768);
    if(!GetProcessTimes(process,&born,&ended,&kernel,&user)||
       !executable_size||executable_size>=32768) {
        log_line("Could not prepare background report monitor.",GetLastError());return 0;
    }
    std::wstring command=L"\""+std::wstring(executable)+L"\" --watch "+std::to_wstring(pid)+
        L" "+std::to_wstring(born.dwLowDateTime)+L" "+std::to_wstring(born.dwHighDateTime);
    STARTUPINFOW startup{};startup.cb=sizeof(startup);PROCESS_INFORMATION child{};
    if(!CreateProcessW(executable,command.data(),nullptr,nullptr,FALSE,
            CREATE_NO_WINDOW|BELOW_NORMAL_PRIORITY_CLASS,nullptr,nullptr,&startup,&child)) {
        log_line("Could not start background report monitor; initial snapshot retained.",GetLastError());return 0;
    }
    CloseHandle(child.hThread);CloseHandle(child.hProcess);
    std::puts("Automatic reports enabled during this session. Menu 8 opens the saved report.");
    log_line("Background read-only report monitor started.");
    return child.dwProcessId;
}
inline std::wstring latest(const wchar_t* dll) {
    const std::wstring candidates[]={beside(dll,filename),fallback(false)};
    std::wstring chosen;FILETIME last{};
    for(const auto& path:candidates) {
        WIN32_FILE_ATTRIBUTE_DATA data{};
        if(path.empty()||!GetFileAttributesExW(path.c_str(),GetFileExInfoStandard,&data)||
           data.dwFileAttributes&FILE_ATTRIBUTE_DIRECTORY)continue;
        if(chosen.empty()||CompareFileTime(&data.ftLastWriteTime,&last)>0){chosen=path;last=data.ftLastWriteTime;}
    }
    return chosen;
}
inline void open_report(const wchar_t* dll) {
    const auto report=latest(dll);
    if(report.empty()){std::puts("No saved report yet. A normal loader launch will save one automatically.");return;}
    // Explicit user action (menu 8), no automatic windows while playing.
    const auto result=reinterpret_cast<INT_PTR>(ShellExecuteW(nullptr,L"open",report.c_str(),nullptr,nullptr,SW_SHOWNORMAL));
    if(result<=32) {
        wchar_t folder[32768]{};if(!GetSystemDirectoryW(folder,32768))return;
        const std::wstring notepad=std::wstring(folder)+L"\\notepad.exe";
        const std::wstring argument=L"\""+report+L"\"";
        if(reinterpret_cast<INT_PTR>(ShellExecuteW(nullptr,L"open",notepad.c_str(),argument.c_str(),nullptr,SW_SHOWNORMAL))<=32)
            std::puts("Could not open the saved report in a text editor.");
    }
}
inline void settings_menu(const wchar_t* dll) {
    const auto ini=settings(dll);
    for(;;) {
        const unsigned values[]={GetPrivateProfileIntW(L"v3",L"head_crown",1,ini.c_str()),
            GetPrivateProfileIntW(L"v3",L"late_eye_guard",1,ini.c_str()),
            GetPrivateProfileIntW(L"v3",L"unsafe_dt_recharge",1,ini.c_str()),
            GetPrivateProfileIntW(L"loader",L"automatic_reports",1,ini.c_str())};
        std::printf("\n1 - Head crown points: %s\n2 - Late hitchance recheck: %s\n3 - Unsafe DT recharge: %s\n4 - Automatic reports: %s\n0 - Back\n",
            values[0]?"ON":"OFF",values[1]?"ON":"OFF",values[2]?"ON":"OFF",values[3]?"ON":"OFF");
        std::puts("Patch switches affect menu 3. Restart CS:GO fully after changing them.");
        std::printf("Toggle: ");char input[32]{};
        if(!std::fgets(input,sizeof(input),stdin)||input[0]=='0')return;
        if(input[0]<'1'||input[0]>'4'){std::puts("Unknown switch.");continue;}
        const unsigned index=input[0]-'1';
        const wchar_t* keys[]={L"head_crown",L"late_eye_guard",L"unsafe_dt_recharge",L"automatic_reports"};
        if(!WritePrivateProfileStringW(index==3?L"loader":L"v3",keys[index],values[index]?L"0":L"1",ini.c_str()))
            std::puts("Cannot save settings beside the loader. No live game setting was changed.");
        else std::puts("Saved. Changes apply after a full game restart and loader launch.");
    }
}
}
