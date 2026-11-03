#pragma once
// CS:GO geometry reconstruction from NL image 682ce73b...ad96e.
// Head: 0x414ac630. Body: 0x41490fa0. Scale: 0x4149ed20.
// Explicit inputs replace NL's global weapon/settings pointers.
// Not installed in the GS image: see recovery/POINTS_STATUS_RU.md.
#include <algorithm>
#include <array>
#include <cmath>
#include <cstddef>
#include <limits>

namespace nl_points {
struct Vec3 { float x{}, y{}, z{}; };
inline Vec3 operator+(Vec3 a,Vec3 b){return {a.x+b.x,a.y+b.y,a.z+b.z};}
inline Vec3 operator-(Vec3 a,Vec3 b){return {a.x-b.x,a.y-b.y,a.z-b.z};}
inline Vec3 operator*(Vec3 a,float s){return {a.x*s,a.y*s,a.z*s};}
inline float dot(Vec3 a,Vec3 b){return a.x*b.x+a.y*b.y+a.z*b.z;}
inline Vec3 cross(Vec3 a,Vec3 b){return {a.y*b.z-a.z*b.y,a.z*b.x-a.x*b.z,a.x*b.y-a.y*b.x};}
inline float length(Vec3 a){return std::sqrt(dot(a,a));}
inline bool finite(Vec3 a){return std::isfinite(a.x)&&std::isfinite(a.y)&&std::isfinite(a.z);}
inline Vec3 unit(Vec3 a){return a*(1.0f/(length(a)+std::numeric_limits<float>::epsilon()));}
struct Capsule { Vec3 a,b;float radius{}; };
struct Points { std::array<Vec3,7> positions{};std::size_t count{}; };

// This is an independent analytic intersection implementation, not a literal
// port of NL's SSE intersection. Only rays used by the generator are required:
// start outside the capsule, end at its midpoint. t is the first entry [0,1].
inline bool entry(const Capsule& c,Vec3 start,Vec3 delta,float& t) {
    const Vec3 axis=c.b-c.a, offset=start-c.a;
    const double aa=dot(axis,axis), dd=dot(delta,delta);
    if(!(dd>0))return false;
    double best=std::numeric_limits<double>::infinity();
    const auto sphere=[&](Vec3 center) {
        const Vec3 o=start-center;
        const double od=dot(o,delta), q=dot(o,o)-double(c.radius)*c.radius;
        const double disc=od*od-dd*q;
        if(disc<0)return;
        const double root=(-od-std::sqrt(disc))/dd;
        if(root>=0&&root<=1)best=std::min(best,root);
    };
    sphere(c.a);sphere(c.b);
    if(aa>1e-12) {
        const double ad=dot(axis,delta),ao=dot(axis,offset),od=dot(offset,delta);
        const double A=aa*dd-ad*ad;
        const double B=aa*od-ao*ad;
        const double C=aa*(dot(offset,offset)-double(c.radius)*c.radius)-ao*ao;
        const double disc=B*B-A*C;
        if(A>1e-12&&disc>=0) {
            const double root=(-B-std::sqrt(disc))/A;
            const double along=ao+root*ad;
            if(root>=0&&root<=1&&along>=0&&along<=aa)best=std::min(best,root);
        }
    }
    if(!std::isfinite(best))return false;
    t=static_cast<float>(best);return true;
}

// Geometry is separated from intersection so the reconstruction can be
// compared against NL using NL's own native intersection as an oracle.
template<class Intersect>
inline bool generate(const Capsule& c,Vec3 eye,float scale,bool head,
                     bool reduced_head,unsigned hitbox,Points& result,Intersect intersect) {
    if(!finite(c.a)||!finite(c.b)||!finite(eye)||!std::isfinite(c.radius)||
       !std::isfinite(scale)||c.radius<=0||scale<0||scale>1)return false;
    Points points{};const Vec3 center=(c.a+c.b)*0.5f;
    const Vec3 view=unit(center-eye);
    if(!finite(view)||length(center-eye)<0.001f)return false;
    Vec3 side{},up{};
    if(head) {
        // A spherical/parallel head has no stable native cross-product basis.
        // Leave it to stock GS instead of manufacturing an arbitrary basis.
        if(length(c.b-c.a)<0.001f)return false;
        side=unit(cross(unit(c.b-c.a),view));
        if(length(side)<0.99f)return false;
        up=unit(cross(view,side));
    } else {
        if(view.x==0&&view.y==0){side={0,-1,0};up={-view.z,0,0};}
        else {side=unit(Vec3{view.y,-view.x,0});up=unit(cross(side,view));}
    }
    const float extent=length(c.b-c.a)+2.01f*c.radius;
    if(!std::isfinite(extent)||!finite(center)||!finite(side)||!finite(up))return false;
    std::array<Vec3,6> directions{};
    directions[0]=side;directions[1]=side*-1.0f;
    unsigned count=2;
    if(head) {
        directions[2]=up;directions[3]=up*-1.0f;
        count=4;
        if(!reduced_head){directions[4]=unit(side+up);directions[5]=unit(up-side);count=6;}
    } else if(hitbox==6){directions[2]=up;count=3;}
    points.positions[points.count++]=center;
    for(unsigned i=0;i<count;++i) {
        const Vec3 displacement=directions[i]*extent;
        const Vec3 start=center+displacement;
        const Vec3 delta=displacement*-1.0f;
        float t=1;
        if(!intersect(c,start,delta,t)||!std::isfinite(t)||t<0||t>1)return false;
        const Vec3 p=start+delta*t;
        const Vec3 position=center+(p-center)*scale;
        if(!finite(position))return false;
        points.positions[points.count++]=position;
    }
    result=points;return true;
}
inline bool generate(const Capsule& c,Vec3 eye,float scale,bool head,
                     bool reduced_head,unsigned hitbox,Points& result) {
    return generate(c,eye,scale,head,reduced_head,hitbox,result,entry);
}

// Radius <= 0 returns the donor's 0.5 default. max_scale is the native
// record-dependent cap (0.8 or a 0.95/0.9 motion blend). Angular inputs are
// radians. fallback_spread comes from the donor's separate weapon helper.
struct ScaleInput {
    float radius{},distance{},inaccuracy{},spread{},fallback_spread{},max_scale{0.8f};
    int percent{};bool use_override_spread{};float override_spread{};
};
inline bool point_scale(const ScaleInput& in,float& result) {
    if(!std::isfinite(in.radius))return false;
    if(in.radius<=0){result=0.5f;return true;}
    if(!std::isfinite(in.distance)||in.distance<0||!std::isfinite(in.inaccuracy)||
       !std::isfinite(in.spread)||!std::isfinite(in.fallback_spread)||
       !std::isfinite(in.max_scale)||in.max_scale<0||in.max_scale>1||
       (in.use_override_spread&&!std::isfinite(in.override_spread)))return false;
    const auto automatic=[&](float angular) {
        const float shifted=0.9999999403953552f*angular+-1.5707963705062866f;
        const float a=static_cast<float>(std::sin(static_cast<double>(angular)));
        const float b=static_cast<float>(std::sin(static_cast<double>(shifted)));
        return ((in.distance*a)/b+in.radius)/in.radius;
    };
    float value;
    if(in.percent<1) {
        value=automatic(in.inaccuracy+in.spread);
        if(value<0)value=automatic(in.inaccuracy+in.fallback_spread);
        value=std::min(in.max_scale,std::max(0.0f,value));
    } else {
        const float manual=std::min(in.max_scale,static_cast<float>(in.percent)*0.01f);
        const float automatic_value=automatic(in.inaccuracy+
            (in.use_override_spread?in.override_spread:in.spread))-0.1f;
        value=std::max(manual,std::min(in.max_scale-0.1f,std::max(0.0f,automatic_value)));
    }
    if(!std::isfinite(value))return false;
    result=value;return true;
}
} // namespace nl_points
