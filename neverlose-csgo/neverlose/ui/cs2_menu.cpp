#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <windows.h>
#include <d3d9.h>
#include <dwmapi.h>
#include <shlobj.h>
#include <atomic>
#include <algorithm>
#include <filesystem>
#include <fstream>
#include <string>
#include "cs2_menu.h"
#include "menu_view.h"
#include "../json.hpp"
#include "imgui.h"
#include "backends/imgui_impl_win32.h"
#include "backends/imgui_impl_dx9.h"
#pragma comment(lib,"d3d9.lib")
#pragma comment(lib,"dwmapi.lib")
#pragma comment(lib,"shell32.lib")
extern IMGUI_IMPL_API LRESULT ImGui_ImplWin32_WndProcHandler(HWND,UINT,WPARAM,LPARAM);
namespace cs2_menu {
namespace {
std::atomic_bool running{false},ready{false},visible{false};
std::atomic<void*> native{nullptr};
IDirect3DDevice9* device=nullptr;
D3DPRESENT_PARAMETERS present{};
ViewState view;
HWND game=nullptr;
std::atomic<HWND> window{nullptr};
std::filesystem::path profile_path(){
    wchar_t folder[MAX_PATH]{};
    if(FAILED(SHGetFolderPathW(nullptr,CSIDL_LOCAL_APPDATA,nullptr,SHGFP_TYPE_CURRENT,folder)))return {};
    return std::filesystem::path(folder)/L"NeverloseCSGO"/L"interface.json";
}
void load_profile(){
    try {
        std::ifstream in(profile_path());if(!in)return;
        auto j=nlohmann::json::parse(in);
        for(int i=0;i<3;++i)view.settings.accent[i]=std::clamp(j.at("accent").at(i).get<float>(),0.f,1.f);
        view.settings.opacity=std::clamp(j.at("opacity").get<float>(),.75f,1.f);
        view.settings.scale=std::clamp(j.at("scale").get<float>(),.85f,1.25f);
        view.settings.watermark=j.at("watermark").get<bool>();
        view.settings.session_time=j.at("session_time").get<bool>();
    }catch(...){view.settings=Settings{};}
}
bool save_profile(){
    try {
        auto p=profile_path();if(p.empty())return false;
        std::filesystem::create_directories(p.parent_path());
        nlohmann::json j={{"accent",{view.settings.accent[0],view.settings.accent[1],view.settings.accent[2]}},
            {"opacity",view.settings.opacity},{"scale",view.settings.scale},
            {"watermark",view.settings.watermark},{"session_time",view.settings.session_time}};
        auto tmp=p;tmp+=L".tmp";
        {std::ofstream out(tmp);out<<j.dump(2);out.flush();if(!out)return false;}
        return MoveFileExW(tmp.c_str(),p.c_str(),MOVEFILE_REPLACE_EXISTING|MOVEFILE_WRITE_THROUGH)!=FALSE;
    }catch(...){return false;}
}
void set_open(bool open){
    visible=open;
    if(ImGui::GetCurrentContext())ImGui::GetIO().MouseDrawCursor=open;
    if(!window)return;
    LONG_PTR style=GetWindowLongPtrW(window,GWL_EXSTYLE);
    if(open)style&=~(WS_EX_TRANSPARENT|WS_EX_NOACTIVATE);
    else style|=WS_EX_TRANSPARENT|WS_EX_NOACTIVATE;
    SetWindowLongPtrW(window,GWL_EXSTYLE,style);
    if(open){SetForegroundWindow(window);SetFocus(window);}
    else if(GetForegroundWindow()==window)SetForegroundWindow(game);
}
LRESULT CALLBACK wndproc(HWND h,UINT msg,WPARAM w,LPARAM l){
    if(msg==WM_APP+1){set_open(!visible.load());return 0;}
    if(msg==WM_KEYUP && (w==VK_INSERT||w==VK_ESCAPE)){set_open(false);return 0;}
    if(ImGui::GetCurrentContext() && ImGui_ImplWin32_WndProcHandler(h,msg,w,l))return 1;
    if(msg==WM_SIZE && device && w!=SIZE_MINIMIZED){
        present.BackBufferWidth=LOWORD(l);present.BackBufferHeight=HIWORD(l);
        ImGui_ImplDX9_InvalidateDeviceObjects();
        if(SUCCEEDED(device->Reset(&present)))ImGui_ImplDX9_CreateDeviceObjects();return 0;
    }
    if(msg==WM_CLOSE){set_open(false);return 0;}
    if(msg==WM_DESTROY){PostQuitMessage(0);return 0;}
    return DefWindowProcW(h,msg,w,l);
}
DWORD WINAPI worker(void*){
    WNDCLASSEXW wc{sizeof(wc)};wc.lpfnWndProc=wndproc;wc.hInstance=GetModuleHandleW(nullptr);wc.lpszClassName=L"NeverloseCSGO.Interface";
    while(running && !(game=FindWindowW(L"Valve001",nullptr)))Sleep(100);
    if(!running)return 0;
    if(!RegisterClassExW(&wc) && GetLastError()!=ERROR_CLASS_ALREADY_EXISTS){running=false;return 1;}
    window=CreateWindowExW(WS_EX_TOPMOST|WS_EX_LAYERED|WS_EX_TOOLWINDOW|WS_EX_TRANSPARENT|WS_EX_NOACTIVATE,wc.lpszClassName,L"Neverlose CS:GO",WS_POPUP,0,0,1280,720,game,nullptr,wc.hInstance,nullptr);
    if(!window){running=false;return 1;}
    SetLayeredWindowAttributes(window,RGB(0,0,0),255,LWA_COLORKEY);
    IDirect3D9* d3d=Direct3DCreate9(D3D_SDK_VERSION);
    present.Windowed=TRUE;present.SwapEffect=D3DSWAPEFFECT_DISCARD;present.BackBufferFormat=D3DFMT_A8R8G8B8;
    present.PresentationInterval=D3DPRESENT_INTERVAL_ONE;present.hDeviceWindow=window;
    HRESULT hr=d3d?d3d->CreateDevice(D3DADAPTER_DEFAULT,D3DDEVTYPE_HAL,window,D3DCREATE_SOFTWARE_VERTEXPROCESSING|D3DCREATE_MULTITHREADED,&present,&device):E_FAIL;
    if(FAILED(hr)){if(d3d)d3d->Release();DestroyWindow(window);window=nullptr;running=false;return 1;}
    IMGUI_CHECKVERSION();ImGui::CreateContext();ImGui::GetIO().IniFilename=nullptr;
    ImFontConfig font; font.SizePixels=16; ImGui::GetIO().Fonts->AddFontDefault(&font);
    ImGui_ImplWin32_Init(window);ImGui_ImplDX9_Init(device);load_profile();ready=true;
    const ULONGLONG started=GetTickCount64();bool home_down=false;
    while(running && IsWindow(game)){
        MSG msg;while(PeekMessageW(&msg,nullptr,0,0,PM_REMOVE)){if(msg.message==WM_QUIT)running=false;TranslateMessage(&msg);DispatchMessageW(&msg);}
        if(!running)break;
        HWND fg=GetForegroundWindow();bool active=fg==game||fg==window;
        bool down=(GetAsyncKeyState(VK_HOME)&0x8000)!=0;
        if(active && down && !home_down)set_open(!visible.load());home_down=down;
        if(!active || IsIconic(game)){ShowWindow(window,SW_HIDE);Sleep(30);continue;}
        RECT rect{};GetClientRect(game,&rect);POINT origin{};ClientToScreen(game,&origin);
        SetWindowPos(window,HWND_TOPMOST,origin.x,origin.y,rect.right,rect.bottom,SWP_NOACTIVATE|SWP_SHOWWINDOW);
        if(!visible)SetWindowLongPtrW(window,GWL_EXSTYLE,GetWindowLongPtrW(window,GWL_EXSTYLE)|WS_EX_TRANSPARENT|WS_EX_NOACTIVATE);
        ImGui_ImplDX9_NewFrame();ImGui_ImplWin32_NewFrame();ImGui::NewFrame();
        if(visible){view.native_available=native.load()!=nullptr;draw(view);}
        if(view.settings.watermark){
            ImGui::SetNextWindowPos(ImVec2(ImGui::GetIO().DisplaySize.x-275,18));
            ImGui::SetNextWindowBgAlpha(.9f);
            ImGui::Begin("watermark",nullptr,ImGuiWindowFlags_NoDecoration|ImGuiWindowFlags_AlwaysAutoResize|ImGuiWindowFlags_NoInputs|ImGuiWindowFlags_NoSavedSettings);
            ImGui::TextColored(ImVec4(view.settings.accent[0],view.settings.accent[1],view.settings.accent[2],1),"NEVERLOSE | CS:GO");
            if(view.settings.session_time){unsigned t=unsigned((GetTickCount64()-started)/1000);ImGui::Text("Session %02u:%02u",t/60,t%60);}
            ImGui::End();
        }
        if(view.save_profile){view.saved=save_profile();view.save_profile=false;}
        if(view.reset_profile){view.settings=Settings{};view.saved=false;view.reset_profile=false;}
        if(view.close){set_open(false);view.close=false;}
        if(view.open_native){
            void* p=native.load();BYTE open=1;SIZE_T written=0;
            if(p && WriteProcessMemory(GetCurrentProcess(),static_cast<char*>(p)+4,&open,1,&written) && written==1)set_open(false);
            view.open_native=false;
        }
        ImGui::EndFrame();device->SetRenderState(D3DRS_ZENABLE,FALSE);device->SetRenderState(D3DRS_ALPHABLENDENABLE,FALSE);device->SetRenderState(D3DRS_SCISSORTESTENABLE,FALSE);
        device->Clear(0,nullptr,D3DCLEAR_TARGET,D3DCOLOR_ARGB(0,0,0,0),1,0);
        if(SUCCEEDED(device->BeginScene())){ImGui::Render();ImGui_ImplDX9_RenderDrawData(ImGui::GetDrawData());device->EndScene();}
        HRESULT result=device->Present(nullptr,nullptr,nullptr,nullptr);
        if(result==D3DERR_DEVICELOST && device->TestCooperativeLevel()==D3DERR_DEVICENOTRESET){ImGui_ImplDX9_InvalidateDeviceObjects();if(SUCCEEDED(device->Reset(&present)))ImGui_ImplDX9_CreateDeviceObjects();}
        Sleep(8);
    }
    ready=false;save_profile();ImGui_ImplDX9_Shutdown();ImGui_ImplWin32_Shutdown();ImGui::DestroyContext();
    device->Release();device=nullptr;d3d->Release();DestroyWindow(window);window=nullptr;UnregisterClassW(wc.lpszClassName,wc.hInstance);running=false;return 0;
}
}
bool start(){bool expected=false;if(!running.compare_exchange_strong(expected,true))return true;HANDLE thread=CreateThread(nullptr,0,worker,nullptr,0,nullptr);if(!thread){running=false;return false;}CloseHandle(thread);return true;}
void stop(){running=false;}
bool toggle(){if(!ready)return false;return PostMessageW(window,WM_APP+1,0,0)!=FALSE;}
void remember_native(void* menu){native.store(menu);}
}
