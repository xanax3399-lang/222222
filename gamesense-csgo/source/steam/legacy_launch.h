#pragma once
#include "steam_discovery.h"
#include "launch_policy.h"
#include <filesystem>
#include <string>
#include <vector>
#include <algorithm>
namespace legacy_launch {
namespace fs=std::filesystem;
inline std::wstring widen(const std::string& s) {
    int n=MultiByteToWideChar(CP_UTF8,MB_ERR_INVALID_CHARS,s.data(),static_cast<int>(s.size()),nullptr,0);
    if(n<=0)return {};std::wstring out(n,L'\0');
    MultiByteToWideChar(CP_UTF8,MB_ERR_INVALID_CHARS,s.data(),static_cast<int>(s.size()),out.data(),n);return out;
}
inline std::wstring registry(HKEY root,const wchar_t* key,const wchar_t* name,REGSAM view=0) {
    HKEY opened=nullptr;
    if(RegOpenKeyExW(root,key,0,KEY_QUERY_VALUE|view,&opened)!=ERROR_SUCCESS)return {};
    DWORD type=0,bytes=0;std::wstring out;
    if(RegQueryValueExW(opened,name,nullptr,&type,nullptr,&bytes)==ERROR_SUCCESS&&type==REG_SZ&&bytes>=2&&bytes<=65536) {
        out.resize(bytes/2+1);if(RegQueryValueExW(opened,name,nullptr,&type,reinterpret_cast<BYTE*>(out.data()),&bytes)==ERROR_SUCCESS)out.resize(std::wcslen(out.c_str()));else out.clear();
    }
    RegCloseKey(opened);return out;
}
inline std::string read(const fs::path& path) {
    Handle f(CreateFileW(path.c_str(),GENERIC_READ,FILE_SHARE_READ|FILE_SHARE_WRITE,nullptr,OPEN_EXISTING,0,nullptr));
    if(f.value==INVALID_HANDLE_VALUE)return {};
    LARGE_INTEGER length{};if(!GetFileSizeEx(f.value,&length)||length.QuadPart<0||length.QuadPart>1024*1024)return {};
    std::string out(static_cast<std::size_t>(length.QuadPart),'\0');DWORD got=0;
    if(!ReadFile(f.value,out.data(),static_cast<DWORD>(out.size()),&got,nullptr)||got!=out.size())return {};return out;
}
inline fs::path steam_root() {
    auto root=registry(HKEY_CURRENT_USER,L"Software\\Valve\\Steam",L"SteamPath");
    if(root.empty()) {const auto exe=registry(HKEY_CURRENT_USER,L"Software\\Valve\\Steam",L"SteamExe");if(!exe.empty())root=fs::path(exe).parent_path().wstring();}
    if(root.empty())root=registry(HKEY_LOCAL_MACHINE,L"Software\\Valve\\Steam",L"InstallPath",KEY_WOW64_32KEY);
    if(root.empty())root=registry(HKEY_LOCAL_MACHINE,L"Software\\Valve\\Steam",L"InstallPath",KEY_WOW64_64KEY);
    return root;
}
inline bool executable(const fs::path& path) {
    if(_wcsicmp(path.filename().c_str(),L"csgo.exe"))return false;
    Handle f(CreateFileW(path.c_str(),GENERIC_READ,FILE_SHARE_READ,nullptr,OPEN_EXISTING,0,nullptr));
    if(f.value==INVALID_HANDLE_VALUE)return false;
    IMAGE_DOS_HEADER dos{};DWORD got=0;LARGE_INTEGER size{};
    if(!GetFileSizeEx(f.value,&size)||!ReadFile(f.value,&dos,sizeof(dos),&got,nullptr)||got!=sizeof(dos)||dos.e_magic!=IMAGE_DOS_SIGNATURE||dos.e_lfanew<0||dos.e_lfanew>size.QuadPart-static_cast<LONGLONG>(sizeof(IMAGE_NT_HEADERS32)))return false;
    LARGE_INTEGER offset{};offset.QuadPart=dos.e_lfanew;IMAGE_NT_HEADERS32 nt{};
    return SetFilePointerEx(f.value,offset,nullptr,FILE_BEGIN)&&ReadFile(f.value,&nt,sizeof(nt),&got,nullptr)&&got==sizeof(nt)&&nt.Signature==IMAGE_NT_SIGNATURE&&nt.FileHeader.Machine==IMAGE_FILE_MACHINE_I386&&nt.OptionalHeader.Magic==IMAGE_NT_OPTIONAL_HDR32_MAGIC&&!(nt.FileHeader.Characteristics&IMAGE_FILE_DLL);
}
inline fs::path discover(const fs::path& root) {
    if(root.empty())return {};
    std::vector<fs::path> libraries{root};
    for(const auto& s:steam_discovery::libraries(read(root/L"steamapps/libraryfolders.vdf"))) {
        const auto w=widen(s);if(!w.empty())libraries.emplace_back(w);
    }
    for(const auto& library:libraries) {
        const auto name=steam_discovery::install(read(library/L"steamapps/appmanifest_730.acf"));
        if(name.empty())continue;
        const auto w=widen(name);if(w.empty())continue;
        const auto folder=library/L"steamapps/common"/w;
        for(const auto& candidate:{folder/L"csgo.exe",folder/L"csgo_legacy/csgo.exe"})if(executable(candidate))return candidate;
    }
    return {};
}
inline DWORD steam_pid() {
    Handle snapshot(CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0));if(snapshot.value==INVALID_HANDLE_VALUE)return 0;
    PROCESSENTRY32W item{};item.dwSize=sizeof(item);
    if(Process32FirstW(snapshot.value,&item))do {if(!_wcsicmp(item.szExeFile,L"steam.exe"))return item.th32ProcessID;}while(Process32NextW(snapshot.value,&item));
    return 0;
}
inline bool ensure_steam(const fs::path& root) {
    if(steam_pid())return true;
    if(root.empty()){SetLastError(ERROR_PATH_NOT_FOUND);return false;}
    const auto exe=root/L"steam.exe";std::wstring command=L"\""+exe.wstring()+L"\" -silent";
    STARTUPINFOW startup{};startup.cb=sizeof(startup);PROCESS_INFORMATION pi{};
    if(!CreateProcessW(exe.c_str(),command.data(),nullptr,nullptr,FALSE,0,nullptr,root.c_str(),&startup,&pi))return false;
    Handle process(pi.hProcess),thread(pi.hThread);
    const auto start=GetTickCount64();
    while(GetTickCount64()-start<15000) {if(steam_pid()){Sleep(1000);return true;}Sleep(100);}
    SetLastError(ERROR_TIMEOUT);return false;
}
inline std::vector<wchar_t> environment() {
    std::vector<std::wstring> entries;auto* block=GetEnvironmentStringsW();if(!block)return {};
    for(const wchar_t* p=block;*p;p+=std::wcslen(p)+1) {
        entries.emplace_back(p);
    }
    FreeEnvironmentStringsW(block);return launch_policy::environment(std::move(entries));
}
struct Suspended {
    Handle thread;
    ~Suspended(){if(thread.value)ResumeThread(thread.value);}
    bool resume() {if(!thread.value)return true;if(ResumeThread(thread.value)==static_cast<DWORD>(-1))return false;CloseHandle(thread.value);thread.value=nullptr;return true;}
};
inline bool launch(const fs::path& game,Handle& process,Suspended& suspended,DWORD& pid) {
    auto env=environment();if(env.empty())return false;
    std::wstring command=L"\""+game.wstring()+L"\" -steam -insecure -console";
    STARTUPINFOW startup{};startup.cb=sizeof(startup);PROCESS_INFORMATION pi{};
    const auto directory=game.parent_path();
    if(!CreateProcessW(game.c_str(),command.data(),nullptr,nullptr,FALSE,CREATE_SUSPENDED|CREATE_UNICODE_ENVIRONMENT,env.data(),directory.c_str(),&startup,&pi))return false;
    process.value=pi.hProcess;suspended.thread.value=pi.hThread;pid=pi.dwProcessId;return true;
}
inline bool modules_ready(DWORD pid) {
    Handle snapshot(CreateToolhelp32Snapshot(TH32CS_SNAPMODULE,pid));if(snapshot.value==INVALID_HANDLE_VALUE)return false;
    bool client=false,engine=false,overlay=false;MODULEENTRY32W item{};item.dwSize=sizeof(item);
    if(Module32FirstW(snapshot.value,&item))do {
        client|=!_wcsicmp(item.szModule,L"client.dll");engine|=!_wcsicmp(item.szModule,L"engine.dll");overlay|=!_wcsicmp(item.szModule,L"gameoverlayrenderer.dll");
    }while(Module32NextW(snapshot.value,&item));
    return client&&engine&&overlay;
}
inline bool wait_modules(HANDLE process,DWORD pid) {
    const auto start=GetTickCount64();
    while(GetTickCount64()-start<120000) {
        if(WaitForSingleObject(process,0)==WAIT_OBJECT_0){SetLastError(ERROR_PROCESS_ABORTED);return false;}
        if(modules_ready(pid))return true;Sleep(100);
    }
    SetLastError(ERROR_TIMEOUT);return false;
}
}
