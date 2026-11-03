#pragma once
#include <string>
#include <vector>
#include <algorithm>
#include <cwctype>
namespace launch_policy {
inline bool starts(const std::wstring& value,const wchar_t* prefix) {
    for(unsigned i=0;prefix[i];++i)if(i>=value.size()||std::towlower(value[i])!=std::towlower(prefix[i]))return false;
    return true;
}
// Per-child environment only. Preserve drive-directory entries (=C:=...) and
// unrelated variables; remove duplicate/mixed-case Steam IDs before insertion.
inline std::vector<wchar_t> environment(std::vector<std::wstring> entries) {
    entries.erase(std::remove_if(entries.begin(),entries.end(),[](const auto& e){return starts(e,L"SteamAppId=")||starts(e,L"SteamGameId=");}),entries.end());
    entries.emplace_back(L"SteamAppId=730");entries.emplace_back(L"SteamGameId=730");
    const auto lower=[](wchar_t c){return std::towlower(c);};
    std::sort(entries.begin(),entries.end(),[&](const auto& a,const auto& b){return std::lexicographical_compare(a.begin(),a.end(),b.begin(),b.end(),[&](wchar_t x,wchar_t y){return lower(x)<lower(y);});});
    std::vector<wchar_t> out;for(const auto& e:entries){out.insert(out.end(),e.begin(),e.end());out.push_back(0);}out.push_back(0);return out;
}
}
