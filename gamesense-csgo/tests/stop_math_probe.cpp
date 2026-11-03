#include "../recovery/stop-analysis/nl_stop_math.hpp"
extern "C" bool probe_stop_friction(const float* in, float* out) {
    nl_stop_recovery::FrictionResult result;
    if (!nl_stop_recovery::friction_step({{in[0],in[1]},in[2],in[3],in[4],in[5],in[6]},result))
        return false;
    out[0]=result.velocity.x;out[1]=result.velocity.y;out[2]=result.speed;
    return true;
}
extern "C" bool probe_stop_brake(const float* in, bool grounded, float* out) {
    nl_stop_recovery::Axes result;
    if (!nl_stop_recovery::brake_axes({{in[0],in[1]},in[2],in[3],in[4],in[5],in[6],grounded},result))
        return false;
    out[0]=result.x;out[1]=result.y;
    return true;
}
