#pragma once
// V3 geometric extension, independently written; not a recovered NL algorithm.
// Uses the selected lag record's capsule, never the entity's current duck pose.
#include "nl_points.h"
namespace v3_head_points {
struct Points {nl_points::Vec3 positions[3]{};unsigned count{};};
inline bool generate(const nl_points::Capsule& capsule,nl_points::Vec3 eye,
                     unsigned percent,Points& result) {
    using namespace nl_points;
    if(!finite(capsule.a)||!finite(capsule.b)||!finite(eye)||
       !std::isfinite(capsule.radius)||capsule.radius<=0||capsule.radius>64||
       percent<50||percent>99)return false;
    const Vec3 top=capsule.a.z>capsule.b.z?capsule.a:capsule.b;
    const Vec3 toward=top-eye;
    const float horizontal=std::sqrt(toward.x*toward.x+toward.y*toward.y);
    if(!std::isfinite(horizontal))return false;
    const Vec3 side=horizontal>.001f?Vec3{-toward.y/horizontal,toward.x/horizontal,0}:Vec3{1,0,0};
    const float radius=capsule.radius*(percent*.01f);
    Points points{};points.count=3;
    points.positions[0]=top+Vec3{0,0,radius};
    points.positions[1]=top+(side*.5f+Vec3{0,0,.8660254037844386f})*radius;
    points.positions[2]=top+(side*-.5f+Vec3{0,0,.8660254037844386f})*radius;
    for(const auto& p:points.positions)if(!finite(p))return false;
    result=points;return true;
}
}
