#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <windows.h>
#include <tlhelp32.h>
#include <cwchar>
#include <cstdint>
struct Handle {
    HANDLE value;
    explicit Handle(HANDLE h=nullptr):value(h){}
    ~Handle(){if(value&&value!=INVALID_HANDLE_VALUE)CloseHandle(value);}
    Handle(const Handle&)=delete;
};
#include "../source/steam/legacy_launch.h"
extern "C" __declspec(dllexport) unsigned launch_probe(const wchar_t* name,int explicit_resume) {
    Handle process;legacy_launch::Suspended pending;DWORD pid=0;
    if(!legacy_launch::launch(legacy_launch::fs::path(name),process,pending,pid))return 0;
    if(explicit_resume&&!pending.resume())return 1;
    return pid;
}
