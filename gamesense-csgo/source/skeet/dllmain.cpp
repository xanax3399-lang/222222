#include "pch.h"
#include "../loader_protocol.h"
#include "nl_hypotheses.h"
#include "nl_points_patch.h"
#include "nl_stop_patch.h"
#include "v3_fire_patch.h"
#include "crash_report.h"
#include <exception>

extern "C" {
__declspec(dllexport) LoaderStatus skeet_loader_status = {1, LoaderWaiting, 0, "Waiting for game modules"};
__declspec(dllexport) nl_hypotheses::Status skeet_nl_hypotheses_status = {1,0,0,0,0,0,-1,0,0,0};
__declspec(dllexport) nl_points_patch::Status skeet_nl_points_status = {2,0,0,0,0,0,0,0,80,80,0};
__declspec(dllexport) nl_stop_patch::Status skeet_nl_stop_status = {1,1,0};
__declspec(dllexport) v3_patches::Status skeet_v3_status = {1,1,95,0};
__declspec(dllexport) v3_fire::Status skeet_v3_fire_status = {1,1,0,0};
}

static void status(LoaderState state, DWORD error, const char* message) {
    skeet_loader_status.error = error;
    lstrcpynA(skeet_loader_status.message, message, sizeof(skeet_loader_status.message));
    InterlockedExchange(&skeet_loader_status.state, state);
}
static DWORD fail(const char* message) {
    DWORD error = GetLastError();
    status(LoaderFailed, error ? error : ERROR_INVALID_DATA, message);
    OutputDebugStringA(message);
    return 1;
}
static DWORD WINAPI initialize(LPVOID parameter) {
    crash_report::initialize(static_cast<HMODULE>(parameter));
    wchar_t settings[32768]{};
    if(!GetModuleFileNameW(static_cast<HMODULE>(parameter),settings,32768))return fail("Cannot locate NL points settings.");
    auto* slash=std::wcsrchr(settings,L'\\');
    if(!slash||slash-settings+22>=32768)return fail("NL points settings path is too long.");
    std::wcscpy(slash+1,L"skeet_nl_points.ini");
    auto& points=skeet_nl_points_status;
    points.head_percent=GetPrivateProfileIntW(L"points",L"head_scale_percent",80,settings);
    points.body_percent=GetPrivateProfileIntW(L"points",L"body_scale_percent",80,settings);
    points.reduced_head=GetPrivateProfileIntW(L"points",L"reduced_head",0,settings);
    skeet_nl_stop_status.enabled=GetPrivateProfileIntW(L"movement",L"nl_brake",1,settings);
    if(skeet_nl_stop_status.enabled>1)return fail("Invalid movement.nl_brake: expected 0 or 1.");
    skeet_v3_status.head_enabled=GetPrivateProfileIntW(L"v3",L"head_crown",1,settings);
    skeet_v3_status.crown_percent=GetPrivateProfileIntW(L"v3",L"head_crown_percent",95,settings);
    if(skeet_v3_status.head_enabled>1||skeet_v3_status.crown_percent<50||skeet_v3_status.crown_percent>99)
        return fail("Invalid v3 settings: head_crown must be 0 or 1; crown percent 50..99.");
    skeet_v3_fire_status.guard_enabled=GetPrivateProfileIntW(L"v3",L"late_eye_guard",1,settings);
    skeet_v3_fire_status.recharge_enabled=GetPrivateProfileIntW(L"v3",L"unsafe_dt_recharge",0,settings);
    gsnl_lua_status.enabled=GetPrivateProfileIntW(L"loader",L"native_api_bridge",1,settings);
    if(gsnl_lua_status.enabled>1)return fail("Invalid loader.native_api_bridge: expected 0 or 1.");
    if(skeet_v3_fire_status.guard_enabled>1||skeet_v3_fire_status.recharge_enabled>1)
        return fail("Invalid v3 settings: late_eye_guard / unsafe_dt_recharge must be 0 or 1.");
    if(points.head_percent>100||points.body_percent>100||points.reduced_head>1)
        return fail("Invalid skeet_nl_points.ini: scale must be 0..100; reduced_head must be 0 or 1.");
    const auto start = GetTickCount64();
    while (!GetModuleHandleW(L"serverbrowser.dll") || !GetModuleHandleW(L"client.dll") ||
           !GetModuleHandleW(L"engine.dll") || !GetModuleHandleW(L"shaderapidx9.dll")) {
        if (GetTickCount64() - start >= 120000) {
            SetLastError(WAIT_TIMEOUT);
            return fail("Timed out waiting for legacy CS:GO modules.");
        }
        Sleep(100);
    }
    status(LoaderInitializing, 0, "Initializing supplied core with Legacy 8802 loader compatibility");
    try {
        auto* skeet = skeet_t::getInstance(static_cast<HMODULE>(parameter));
        if (!skeet->map()) return fail("Fixed image address is occupied, reservation is invalid, or resource size differs.");
        if (!skeet->fix_imports()) return fail("An original image import could not be resolved.");
        if (!skeet->extra()) return fail(skeet->last_error());
        if (!FlushInstructionCache(GetCurrentProcess(), reinterpret_cast<void*>(kImageBase), kImageSize))
            return fail("Could not flush the image instruction cache.");
        if (!skeet->entry()) return fail("Could not start the original image entry thread.");
        status(LoaderEntryStarted, 0, nl_hypotheses::selected_mode==nl_hypotheses::Stock
            ? "GameSense mode: original entry resumed. Game runtime unverified."
            : "Selected NL modules installed. Entry resumed; game runtime unverified.");
        return 0;
    } catch (const std::exception& e) {
        return fail(e.what());
    } catch (...) {
        return fail("Unexpected C++ initialization error.");
    }
}
BOOL WINAPI DllMain(HMODULE module, DWORD reason, LPVOID) {
    if (reason == DLL_PROCESS_ATTACH) {
        DisableThreadLibraryCalls(module);
        HANDLE worker = CreateThread(nullptr, 0, initialize, module, 0, nullptr);
        if (!worker) return FALSE;
        CloseHandle(worker);
    }
    return TRUE;
}
