#include "../source/steam/steam_discovery.h"
#include "../source/steam/launch_policy.h"
#include <cassert>
#include <iostream>
int main() {
    using namespace steam_discovery;int n=0;
    auto libs=libraries(R"vdf("libraryfolders" { "0" { "path" "C:\\Program Files (x86)\\Steam" "apps" {"730" "123456"} } "1" { "path" "D:\\SteamLibrary" } })vdf");
    assert(libs.size()==2&&libs[0]=="C:\\Program Files (x86)\\Steam"&&libs[1]=="D:\\SteamLibrary");++n;
    libs=libraries(R"vdf("LibraryFolders" {"1" "E:\\old Steam" "TimeNextStatsReport" "0"})vdf");assert(libs.size()==1&&libs[0]=="E:\\old Steam");++n;
    assert(install(R"vdf(// hello
"AppState" { "appid" "730" "installdir" "Counter-Strike Global Offensive" "UserConfig" {"betakey" "csgo_legacy"} })vdf")=="Counter-Strike Global Offensive");++n;
    for(const auto* bad:{"../cs2","C:\\games","/tmp","abc/../evil","a/./b","a//b","a\\..\\b","", "a/"}) {assert(!relative_install(bad));++n;}
    for(const auto* good:{"Counter-Strike Global Offensive","csgo_legacy","nested/csgo","Игры"}) {assert(relative_install(good));++n;}
    std::vector<Entry> out;
    for(const auto* bad:{"\"a\" {", "}", "\"a\"", "\"a\" \"unterminated", "\"a\" { \"b\" }", "abc", "{ }"}) {assert(!parse(bad,out));++n;}
    assert(!parse(std::string(1024*1024+1,'x'),out));++n;
    assert(parse("\"x\" { \"name\" \"a\\\"b\" }",out)&&out.size()==1&&out[0].value=="a\"b");++n;
    const std::vector<std::wstring> original={L"Path=C:\\Windows",L"=C:=C:\\Steam",L"sTeAmApPiD=123",L"SteamAppId=456",L"SteamGameId=789",L"SteamAppIdExtra=keep",L"TEST=αβ"};
    const auto block=launch_policy::environment(original);std::vector<std::wstring> entries;
    for(const wchar_t* p=block.data();*p;p+=std::wcslen(p)+1)entries.emplace_back(p);
    assert(block.size()>=2&&block[block.size()-1]==0&&block[block.size()-2]==0);++n;
    assert(entries.size()==6);++n;
    for(const auto* keep:{L"Path=C:\\Windows",L"=C:=C:\\Steam",L"SteamAppIdExtra=keep",L"TEST=αβ",L"SteamAppId=730",L"SteamGameId=730"}) {assert(std::find(entries.begin(),entries.end(),keep)!=entries.end());++n;}
    assert(original[2]==L"sTeAmApPiD=123");++n;
    assert(launch_policy::environment({})==std::vector<wchar_t>({L'S',L't',L'e',L'a',L'm',L'A',L'p',L'p',L'I',L'd',L'=',L'7',L'3',L'0',0,L'S',L't',L'e',L'a',L'm',L'G',L'a',L'm',L'e',L'I',L'd',L'=',L'7',L'3',L'0',0,0}));++n;
    std::cout<<n<<" Steam discovery/environment fixture checks passed\n";
}
