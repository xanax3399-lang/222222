#include "../source/skeet/nl_points.h"
#if defined(_WIN32)
#define API extern "C" __declspec(dllexport)
#else
#define API extern "C"
#endif
API int probe_points(const float* input,unsigned head,unsigned reduced,unsigned hitbox,float* output) {
    nl_points::Capsule c{{input[0],input[1],input[2]},{input[3],input[4],input[5]},input[6]};
    nl_points::Points points{};
    if(!nl_points::generate(c,{input[7],input[8],input[9]},input[10],head!=0,reduced!=0,hitbox,points))return 0;
    for(std::size_t i=0;i<points.count;++i){output[3*i]=points.positions[i].x;output[3*i+1]=points.positions[i].y;output[3*i+2]=points.positions[i].z;}
    return static_cast<int>(points.count);
}
API bool probe_scale(const nl_points::ScaleInput* input,float* output) {
    return nl_points::point_scale(*input,*output);
}
