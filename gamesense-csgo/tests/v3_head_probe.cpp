#include "../source/skeet/v3_head_points.h"
extern "C" bool probe_v3_head(const float* in,unsigned percent,float* out) {
    v3_head_points::Points points;
    if(!v3_head_points::generate({{in[0],in[1],in[2]},{in[3],in[4],in[5]},in[6]},
                               {in[7],in[8],in[9]},percent,points))return false;
    for(unsigned i=0;i<3;++i){out[3*i]=points.positions[i].x;out[3*i+1]=points.positions[i].y;out[3*i+2]=points.positions[i].z;}
    return true;
}
