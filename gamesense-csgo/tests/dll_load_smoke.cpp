#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <cstdio>
#include "../source/loader_protocol.h"
#include "../source/skeet/nl_points_status.h"
int wmain(int argc,wchar_t** argv) {
    if(argc!=2)return 2;
    HMODULE dll=LoadLibraryW(argv[1]);
    if(!dll){std::printf("LoadLibrary failed: %lu\n",GetLastError());return 1;}
    auto* loader=reinterpret_cast<LoaderStatus*>(GetProcAddress(dll,"skeet_loader_status"));
    auto* points=reinterpret_cast<nl_points_patch::Status*>(GetProcAddress(dll,"skeet_nl_points_status"));
    if(!loader||!points||loader->version!=1||points->version!=2||points->head_percent!=80||points->body_percent!=80)return 1;
    Sleep(200);
    if(loader->state!=LoaderWaiting)return 1;
    std::puts("Actual x86 DLL loaded; exports and waiting state verified. CS:GO was not run.");
    // The waiting worker belongs to this short-lived test process. ExitProcess
    // ends it before DLL teardown; do not FreeLibrary while it is executing.
    return 0;
}
