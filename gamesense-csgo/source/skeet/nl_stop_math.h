#pragma once

// Reconstructed arithmetic blocks from the supplied CS:GO NL x86 image.
// Explicit inputs replace surrounding game state. The separate GS adapter uses
// brake_axes with native GS stop requests, friction and acceleration inputs.
// This file does not implement the full NL stop eligibility/timing controller.
#include <algorithm>
#include <cmath>

namespace nl_stop_recovery {
struct Axes { float x, y; };
struct FrictionInput {
    Axes velocity;
    float speed, stop_speed, friction, interval, surface_friction;
};
struct FrictionResult { Axes velocity; float speed; };

// 414A09B7..414A09C6 and 414A0A6A..414A0ABE (or the unchanged branch).
inline bool friction_step(const FrictionInput& in, FrictionResult& out) {
    const float values[]{in.velocity.x,in.velocity.y,in.speed,in.stop_speed,
                         in.friction,in.interval,in.surface_friction};
    for (float f : values) if (!std::isfinite(f)) return false;
    if (in.speed < 0 || in.stop_speed < 0 || in.friction < 0 ||
        in.interval <= 0 || in.surface_friction < 0) return false;
    // MAXSS chooses the second operand on equality (including signed zero).
    const float control = in.stop_speed > in.speed ? in.stop_speed : in.speed;
    float drop = control * in.friction;
    drop = drop * in.interval;
    drop = drop * in.surface_friction;
    if (!std::isfinite(drop)) return false;
    const float remaining = in.speed - drop;
    const float speed = 0.0f > remaining ? 0.0f : remaining;
    Axes velocity = in.velocity;
    if (speed != in.speed) {
        const float ratio = speed / in.speed;
        velocity = {velocity.x * ratio, velocity.y * ratio};
    }
    out = {velocity, speed};
    return true;
}

struct BrakeInput {
    // Components prepared by native atan2/cos/sin logic, not recovered here.
    Axes direction;
    float speed, weapon_max_speed, accelerate, interval, surface_friction;
    bool grounded;
};

// 414A0D43..414A10E8. Does not decide WHEN to request braking.
inline bool brake_axes(const BrakeInput& in, Axes& out) {
    const float values[]{in.direction.x,in.direction.y,in.speed,
                         in.weapon_max_speed,in.accelerate,in.interval,
                         in.surface_friction};
    for (float f : values) if (!std::isfinite(f)) return false;
    if (in.speed < 0 || in.weapon_max_speed < 0 || in.accelerate < 0 ||
        in.interval <= 0 || in.surface_friction < 0) return false;
    // Preserve native float32 operation order, including the caller's product.
    const float surface_tick = in.surface_friction * in.interval;
    const float acceleration = surface_tick * in.accelerate;
    const float available = in.weapon_max_speed * acceleration - in.speed;
    if (!std::isfinite(acceleration) || !std::isfinite(available)) return false;
    float magnitude = 450.0f;
    if (available >= 1.0f) {
        if (in.grounded) magnitude = 0.9900000095367432f;
        else if (acceleration != 0.0f)
            magnitude = std::clamp(in.speed / acceleration, -450.0f, 450.0f);
    }
    const float x = in.direction.x * magnitude, y = in.direction.y * magnitude;
    if (!std::isfinite(x) || !std::isfinite(y)) return false;
    out = {std::clamp(x, -450.0f, 450.0f), std::clamp(y, -450.0f, 450.0f)};
    return true;
}
}
