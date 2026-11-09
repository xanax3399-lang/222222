// Exercise production patch guards, with deliberately invalid image pointers.
#define NOMINMAX
#include <windows.h>
#include <cstdlib>
#include <cstdio>
#include "../source/skeet/nl_hypotheses_patch.h"
#include "../source/skeet/nl_points_patch.h"
#include "../source/skeet/nl_stop_patch.h"
#include "../source/skeet/v3_fire_patch.h"
extern "C" {
__declspec(dllexport) nl_hypotheses::Status skeet_nl_hypotheses_status{};
__declspec(dllexport) nl_points_patch::Status skeet_nl_points_status{};
__declspec(dllexport) nl_stop_patch::Status skeet_nl_stop_status{};
__declspec(dllexport) v3_patches::Status skeet_v3_status{};
__declspec(dllexport) v3_fire::Status skeet_v3_fire_status{};
}
int main(int argc,char** argv) {
    if(argc!=2)return 2;
    const unsigned mode=static_cast<unsigned>(std::strtoul(argv[1],nullptr,10));
    if(mode!=0&&mode!=8)return 2;
    nl_hypotheses::selected_mode=mode;
    // Even enabled legacy settings must not install in either new stock mode.
    skeet_nl_stop_status.enabled=1;skeet_v3_status.head_enabled=1;
    skeet_v3_fire_status.guard_enabled=1;skeet_v3_fire_status.recharge_enabled=1;
    if(!nl_hypotheses_patch::apply(nullptr,0)||!nl_points_patch::apply(nullptr,0)||
       !nl_stop_patch::apply(nullptr,0)||!v3_fire::apply(nullptr,0))return 1;
    if(skeet_nl_hypotheses_status.installed||skeet_nl_points_status.installed||
       skeet_nl_stop_status.installed||skeet_v3_status.installed||skeet_v3_fire_status.installed)return 1;
    std::printf("Mode %u: all production legacy gameplay patch guards passed.\n",mode);return 0;
}
