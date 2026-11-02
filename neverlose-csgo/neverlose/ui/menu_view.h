#pragma once
namespace cs2_menu {
struct Settings {
    float accent[3] = {0.62f, 0.39f, 1.0f};
    float opacity = 0.98f;
    float scale = 1.f;
    bool watermark = true;
    bool session_time = true;
};
struct ViewState {
    Settings settings;
    int page = 2;
    bool native_available = false;
    bool open_native = false;
    bool save_profile = false;
    bool reset_profile = false;
    bool close = false;
    bool saved = false;
};
void draw(ViewState& state);
}
