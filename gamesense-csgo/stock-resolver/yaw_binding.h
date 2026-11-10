#pragma once
#include <cstring>
#include "netvar_offset.h"
namespace stock_native {
enum YawMethod:unsigned { YawUnavailable=0,YawScalar=1,YawVector=2,YawArray=3,YawNested=4,YawAmbiguous=5 };
struct YawSpec {const char* name;int type,offset,elements,stride,element_type;};
inline bool eye_base(const char* name){return name&&(!std::strcmp(name,"m_angEyeAngles")||!std::strcmp(name,"m_angEyeAngles[0]"));}
inline int yaw_component(const YawSpec& spec,unsigned& method) {
    method=YawUnavailable;int offset=-1;
    if(!spec.name||netvar_offset(0,spec.offset)<0||spec.offset%4)return -1;
    if(!std::strcmp(spec.name,"m_angEyeAngles[1]")&&spec.type==1){method=YawScalar;offset=spec.offset;}
    else if(eye_base(spec.name)&&(spec.type==2||spec.type==3)){method=YawVector;offset=spec.offset+4;}
    else if(eye_base(spec.name)&&spec.type==5&&spec.element_type==1&&spec.elements>=2&&spec.elements<=64&&
        spec.stride>=4&&spec.stride<=64&&spec.stride%4==0){method=YawArray;offset=spec.offset+spec.stride;}
    if(offset>=0&&netvar_offset(0,offset)<0){method=YawUnavailable;return -1;}
    return offset;
}
}
