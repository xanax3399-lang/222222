#include "../source/skeet/overlay_loader.h"
extern "C" __declspec(dllexport) int probe(DWORD* output) {
    overlay_patch::Addresses addresses;
    const char* error = nullptr;
    bool ok = overlay_patch::resolve(addresses, error);
    output[0] = addresses.return_address;
    output[1] = addresses.reference_address;
    output[2] = reinterpret_cast<DWORD>(error);
    return ok ? 1 : 0;
}
