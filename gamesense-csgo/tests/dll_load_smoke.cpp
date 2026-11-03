#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <cstdio>
#include "../source/loader_protocol.h"
#include "../source/skeet/nl_points_status.h"
#include "../source/skeet/nl_stop_status.h"
#include "../source/skeet/v3_status.h"
int wmain(int argc,wchar_t** argv) {
    if(argc!=2)return 2;
    HMODULE dll=LoadLibraryW(argv[1]);
    if(!dll){std::printf("LoadLibrary failed: %lu\n",GetLastError());return 1;}
    auto* loader=reinterpret_cast<LoaderStatus*>(GetProcAddress(dll,"skeet_loader_status"));
    auto* points=reinterpret_cast<nl_points_patch::Status*>(GetProcAddress(dll,"skeet_nl_points_status"));
    auto* brake=reinterpret_cast<nl_stop_patch::Status*>(GetProcAddress(dll,"skeet_nl_stop_status"));
    if(!brake||brake->version!=1||brake->enabled!=1||brake->installed)return 1;
    auto* v3=reinterpret_cast<v3_patches::Status*>(GetProcAddress(dll,"skeet_v3_status"));
    if(!v3||v3->version!=1||v3->crown_percent!=95||v3->installed)return 1;
    if(!loader||!points||loader->version!=1||points->version!=2||points->head_percent!=80||points->body_percent!=80)return 1;
    Sleep(200);
    if(loader->state!=LoaderWaiting)return 1;
    std::puts("Actual x86 DLL loaded; exports and waiting state verified. CS:GO was not run.");
    // The waiting worker belongs to this short-lived test process. ExitProcess
    // ends it before DLL teardown; do not FreeLibrary while it is executing.
    return 0;
}
