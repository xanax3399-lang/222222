#include "../source/skeet/nl_points.h"
#include <cassert>
#include <cstdio>

int main() {
    using namespace nl_points;
    Points result{};
    const Capsule c{{0,0,60},{0,0,65},4};
    assert(generate(c,{-100,0,64},.8f,true,false,0,result));
    assert(result.count==7);
    assert(std::abs(result.positions[1].y-3.2f)<.0001f);
    assert(std::abs(result.positions[3].z-67.6990509f)<.0001f);
    assert(generate(c,{-100,0,64},.8f,true,true,0,result)&&result.count==5);
    assert(generate(c,{-100,0,64},.8f,false,false,6,result)&&result.count==4);
    assert(generate(c,{-100,0,64},.8f,false,false,3,result)&&result.count==3);
    const auto before=result;
    assert(!generate(c,{-100,0,64},-1,true,false,0,result));
    assert(result.count==before.count&&result.positions[1].y==before.positions[1].y);
    ScaleInput scale{4,100,0,.01f,0,.8f,0,false,0};
    float value=0;assert(point_scale(scale,value));
    assert(std::abs(value-.7499916553f)<.000002f);
    std::puts("CS:GO NL geometry smoke checks passed. GS integration is not installed.");
}
