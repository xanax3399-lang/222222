#pragma once
#include <string>
#include <string_view>
#include <vector>
#include <cctype>
namespace steam_discovery {
struct Entry {std::string key,value;};
// Only scalar pairs are retained. Comments, nested objects and escaped Windows
// paths are supported; malformed/truncated documents fail closed.
inline bool parse(std::string_view text,std::vector<Entry>& entries) {
    entries.clear();if(text.size()>1024*1024)return false;
    std::size_t i=0;int depth=0;std::string pending;
    while(i<text.size()) {
        if(std::isspace(static_cast<unsigned char>(text[i]))){++i;continue;}
        if(text[i]=='/'&&i+1<text.size()&&text[i+1]=='/') {
            while(i<text.size()&&text[i]!='\n')++i;continue;
        }
        if(text[i]=='{'){if(pending.empty()||++depth>32)return false;pending.clear();++i;continue;}
        if(text[i]=='}'){if(!pending.empty()||--depth<0)return false;++i;continue;}
        if(text[i++]!='"')return false;
        std::string token;bool closed=false;
        while(i<text.size()) {
            char c=text[i++];if(c=='"'){closed=true;break;}
            if(c=='\\'&&i<text.size()&&(text[i]=='\\'||text[i]=='"'))c=text[i++];
            if(c=='\0'||token.size()>=32767)return false;token+=c;
        }
        if(!closed)return false;
        if(pending.empty())pending=token;
        else {entries.push_back({pending,token});pending.clear();}
    }
    return depth==0&&pending.empty();
}
inline bool relative_install(std::string_view name) {
    if(name.empty()||name.size()>240||name.front()=='/'||name.front()=='\\')return false;
    std::string part;
    for(char c:name) {
        if(c==':'||c=='\0'||static_cast<unsigned char>(c)<32)return false;
        if(c=='/'||c=='\\') {if(part.empty()||part==".."||part==".")return false;part.clear();}
        else part+=c;
    }
    return !part.empty()&&part!=".."&&part!=".";
}
inline std::vector<std::string> libraries(std::string_view text) {
    std::vector<Entry> pairs;std::vector<std::string> out;if(!parse(text,pairs))return out;
    for(const auto& e:pairs) {
        bool numeric=!e.key.empty();for(char c:e.key)numeric&=c>='0'&&c<='9';
        if((e.key=="path"||numeric)&&e.value.size()>2&&e.value[1]==':'&&
           (e.value[2]=='\\'||e.value[2]=='/'))out.push_back(e.value);
    }
    return out;
}
inline std::string install(std::string_view text) {
    std::vector<Entry> pairs;if(!parse(text,pairs))return {};
    for(const auto& e:pairs)if(e.key=="installdir"&&relative_install(e.value))return e.value;
    return {};
}
}
