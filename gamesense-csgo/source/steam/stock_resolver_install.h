#pragma once
#include <filesystem>
#include <fstream>
#include <array>
#include <algorithm>
#include <windows.h>
namespace stock_resolver_install {
namespace fs=std::filesystem;
inline bool same_file(const fs::path& a,const fs::path& b) {
    std::error_code ec;
    if(fs::equivalent(a,b,ec)&&!ec)return true;
    ec.clear();auto size=fs::file_size(a,ec);if(ec)return false;
    if(fs::file_size(b,ec)!=size||ec)return false;
    std::ifstream x(a,std::ios::binary),y(b,std::ios::binary);if(!x||!y)return false;
    std::array<char,8192> left{},right{};
    while(x){
        x.read(left.data(),left.size());y.read(right.data(),right.size());
        const auto count=static_cast<std::size_t>(x.gcount()); // bounded by left.size()
        if(x.gcount()!=y.gcount()||!std::equal(left.data(),left.data()+count,right.data()))return false;
    }
    return true;
}
inline bool install_file(const fs::path& source,const fs::path& destination) {
    if(same_file(source,destination))return true;
    return CopyFileW(source.c_str(),destination.c_str(),FALSE)!=0;
}
inline bool deploy(const wchar_t* core_dll,const wchar_t* game_exe) {
    const auto source=fs::path(core_dll).parent_path(),game=fs::path(game_exe).parent_path();
    std::error_code ec;
    const auto script_folder=game/L"csgo";
    if(!fs::is_directory(script_folder,ec)||ec){SetLastError(ERROR_PATH_NOT_FOUND);return false;}
    // The model is already inside skeet.dll; only its Lua bridge is copied.
    return install_file(source/L"stock_resolver.lua",script_folder/L"stock_resolver.lua");
}
}
