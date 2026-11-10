#define NOMINMAX
#include "feedback_hook.h"
#define API extern "C" __declspec(dllexport)
API unsigned feedback_capture[6]{};
bool __cdecl captured(unsigned* registers,void*) {
    auto* frame=reinterpret_cast<unsigned char*>(registers)+36;
    ++feedback_capture[0];std::memcpy(feedback_capture+1,frame+0x14,4);std::memcpy(feedback_capture+2,frame+0x18,4);
    std::memcpy(feedback_capture+3,frame+0x28,4);feedback_capture[4]=registers[1];feedback_capture[5]=registers[7];return false;
}
API bool feedback_prepare(unsigned char* image,unsigned size,unsigned mode,unsigned enabled) {
    return stock_feedback::install_hook(image,size,reinterpret_cast<unsigned>(captured),mode==8&&enabled);
}
