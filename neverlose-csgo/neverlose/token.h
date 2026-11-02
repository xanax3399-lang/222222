#pragma once
#include <windows.h>
#include <string>

// Optional legacy website integration. No account credential is compiled in.
inline std::string website_token_storage;
inline const char* auth_token = "";
inline void load_optional_website_token() {
    const DWORD size = GetEnvironmentVariableA("NL_WEBSITE_TOKEN", nullptr, 0);
    if (!size || size > 4096) return;
    website_token_storage.resize(size);
    const DWORD copied = GetEnvironmentVariableA("NL_WEBSITE_TOKEN", website_token_storage.data(), size);
    if (!copied || copied >= size) { website_token_storage.clear(); return; }
    website_token_storage.resize(copied);
    auth_token = website_token_storage.c_str();
}
