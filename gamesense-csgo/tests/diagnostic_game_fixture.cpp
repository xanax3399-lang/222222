#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <cstdio>
#include "../source/skeet/nl_points_status.h"
// A short-lived CI process, NOT CS:GO. Loads the actual DLL in its waiting state;
// exports are readable, but there are no engine modules and no core injection.
int wmain(int argc,wchar_t** argv) {
    if(argc!=3)return 2;
    const HMODULE dll=LoadLibraryW(argv[1]);if(!dll)return 3;
    auto* points=reinterpret_cast<nl_points_patch::Status*>(GetProcAddress(dll,"skeet_nl_points_status"));
    if(!points||points->version!=2)return 4;
    FILETIME born{},ended{},kernel{},user{};
    if(!GetProcessTimes(GetCurrentProcess(),&born,&ended,&kernel,&user))return 5;
    FILE* ready=nullptr;if(_wfopen_s(&ready,argv[2],L"wb")||!ready)return 6;
    std::fprintf(ready,"%lu %lu %lu\n",GetCurrentProcessId(),born.dwLowDateTime,born.dwHighDateTime);
    std::fclose(ready);
    Sleep(2100);points->calls=123;Sleep(6400);
    return 0;
}
