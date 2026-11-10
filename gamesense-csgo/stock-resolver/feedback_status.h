#pragma once
#include "shot_feedback.h"
namespace stock_feedback {
struct Status {
    unsigned version,enabled,learning;
    volatile std::int32_t installed,listening,error,sequence,busy;
    Counters counters;
    unsigned last_serial,bytes;
};
static_assert(sizeof(Status)==100);
static_assert(sizeof(Shot)==144);
struct Log {unsigned version=1,count=capacity;std::array<Shot,capacity> shots{};};
static_assert(sizeof(Log)==36872);
}
#ifdef _WIN32
#include <windows.h>
extern "C" __declspec(dllexport) stock_feedback::Status sr_feedback_status;
extern "C" __declspec(dllexport) stock_feedback::Log sr_feedback_log;
#endif
