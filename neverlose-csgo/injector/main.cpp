#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <winsock2.h>
#include <windows.h>
#include <winhttp.h>
#include <bcrypt.h>
#include <tlhelp32.h>
#include <filesystem>
#include <fstream>
#include <string>
#include <vector>
#include <cstdio>
#include "resource.h"
#pragma comment(lib,"winhttp.lib")
#pragma comment(lib,"bcrypt.lib")
#pragma comment(lib,"ws2_32.lib")
namespace fs=std::filesystem;
namespace {
struct Handle {
    HANDLE h=nullptr;Handle()=default;explicit Handle(HANDLE v):h(v){};
    Handle(const Handle&)=delete;Handle& operator=(const Handle&)=delete;
    ~Handle(){if(h&&h!=INVALID_HANDLE_VALUE)CloseHandle(h);}
    operator bool()const{return h&&h!=INVALID_HANDLE_VALUE;}
};
struct Http {HINTERNET h=nullptr;explicit Http(HINTERNET v):h(v){};~Http(){if(h)WinHttpCloseHandle(h);}operator bool()const{return h!=nullptr;}};
struct Runtime {
    fs::path directory;Handle process,job;
    ~Runtime(){
        if(process){if(WaitForSingleObject(process.h,0)==WAIT_TIMEOUT){TerminateProcess(process.h,0);WaitForSingleObject(process.h,5000);}}
        if(!directory.empty()){std::error_code ec;fs::remove_all(directory,ec);}
    }
};
bool fail(const char* text){std::printf("[!] %s (Windows error %lu)\n",text,GetLastError());return false;}
fs::path exe_path(){std::vector<wchar_t> buf(32768);DWORD n=GetModuleFileNameW(nullptr,buf.data(),DWORD(buf.size()));return n?fs::path(std::wstring(buf.data(),n)):fs::path{};}
bool health(){
    Http session(WinHttpOpen(L"NeverloseCSGO/1",WINHTTP_ACCESS_TYPE_NO_PROXY,nullptr,nullptr,0));if(!session)return false;
    WinHttpSetTimeouts(session.h,500,500,500,500);
    Http conn(WinHttpConnect(session.h,L"127.0.0.1",30031,0));if(!conn)return false;
    Http req(WinHttpOpenRequest(conn.h,L"GET",L"/health",nullptr,nullptr,nullptr,0));if(!req)return false;
    if(!WinHttpSendRequest(req.h,nullptr,0,nullptr,0,0,0)||!WinHttpReceiveResponse(req.h,nullptr))return false;
    DWORD status=0,size=sizeof(status);if(!WinHttpQueryHeaders(req.h,WINHTTP_QUERY_STATUS_CODE|WINHTTP_QUERY_FLAG_NUMBER,nullptr,&status,&size,nullptr)||status!=200)return false;
    std::string body;char buf[128];DWORD n=0;
    while(WinHttpReadData(req.h,buf,sizeof(buf),&n)&&n){body.append(buf,n);if(body.size()>128)return false;}
    return body=="neverlose-csgo-local-v1";
}
bool ws_port(){
    SOCKET s=socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);if(s==INVALID_SOCKET)return false;
    u_long nonblocking=1;ioctlsocket(s,FIONBIO,&nonblocking);
    sockaddr_in addr{};addr.sin_family=AF_INET;addr.sin_port=htons(30030);addr.sin_addr.s_addr=htonl(INADDR_LOOPBACK);
    int r=connect(s,reinterpret_cast<sockaddr*>(&addr),sizeof(addr));
    if(r!=0){fd_set set;FD_ZERO(&set);FD_SET(s,&set);timeval timeout{0,100000};r=select(0,nullptr,&set,nullptr,&timeout);int err=1,len=sizeof(err);if(r>0)getsockopt(s,SOL_SOCKET,SO_ERROR,reinterpret_cast<char*>(&err),&len);r=(r>0&&err==0)?0:-1;}
    closesocket(s);return r==0;
}
bool start_server(Runtime& rt,const fs::path& cloud){
    if(health()&&ws_port()){std::puts("[+] Local server is ready.");return true;}
    HRSRC res=FindResourceW(nullptr,MAKEINTRESOURCEW(IDR_NEVERLOSE_SERVER),L"BINARY");if(!res)return fail("Embedded server is missing; rebuild the injector");
    DWORD size=SizeofResource(nullptr,res);HGLOBAL loaded=LoadResource(nullptr,res);auto bytes=static_cast<const char*>(loaded?LockResource(loaded):nullptr);
    if(!bytes||size<64||bytes[0]!='M'||bytes[1]!='Z')return fail("Invalid embedded server image");
    wchar_t temp[MAX_PATH]{};if(!GetTempPathW(MAX_PATH,temp))return fail("Cannot find temporary directory");
    unsigned char nonce[16];if(BCryptGenRandom(nullptr,nonce,sizeof(nonce),BCRYPT_USE_SYSTEM_PREFERRED_RNG)<0)return fail("Cannot create runtime identifier");
    wchar_t name[64]=L"NeverloseCSGO-";const wchar_t hex[]=L"0123456789abcdef";size_t at=14;
    // Prefix length is computed, not assumed, to avoid embedded NULs in the name.
    at=wcslen(name);for(unsigned char b:nonce){name[at++]=hex[b>>4];name[at++]=hex[b&15];}name[at]=0;
    auto candidate=fs::path(temp)/name;
    if(!CreateDirectoryW(candidate.c_str(),nullptr))return fail("Cannot create server runtime directory");
    rt.directory=candidate;
    auto server=rt.directory/L"server.exe";
    {std::ofstream out(server,std::ios::binary);out.write(bytes,size);out.close();if(!out)return fail("Cannot extract server");}
    {std::ifstream in(server,std::ios::binary);std::vector<char> actual((std::istreambuf_iterator<char>(in)),{});if(actual.size()!=size||memcmp(actual.data(),bytes,size)!=0)return fail("Embedded server verification failed");}
    if(HRSRC runtime=FindResourceW(nullptr,MAKEINTRESOURCEW(IDR_UNWIND_RUNTIME),L"BINARY")){
        DWORD length=SizeofResource(nullptr,runtime);HGLOBAL handle=LoadResource(nullptr,runtime);
        auto content=static_cast<const char*>(handle?LockResource(handle):nullptr);
        if(!content||length<64||content[0]!='M'||content[1]!='Z')return fail("Invalid bundled server runtime");
        auto target=rt.directory/L"libunwind.dll";
        {std::ofstream out(target,std::ios::binary);out.write(content,length);out.close();if(!out)return fail("Cannot extract server runtime");}
        {std::ifstream in(target,std::ios::binary);std::vector<char> actual((std::istreambuf_iterator<char>(in)),{});if(actual.size()!=length||memcmp(actual.data(),content,length)!=0)return fail("Server runtime verification failed");}
    }
    std::error_code ec;fs::create_directories(cloud,ec);if(ec)return fail("Cannot create config directory");
    // Only this child inherits the storage setting. No system environment is changed.
    DWORD old_size=GetEnvironmentVariableW(L"NL_CLOUD_PATH",nullptr,0);std::vector<wchar_t> old(old_size?old_size:1);if(old_size)GetEnvironmentVariableW(L"NL_CLOUD_PATH",old.data(),old_size);
    if(!SetEnvironmentVariableW(L"NL_CLOUD_PATH",cloud.c_str()))return fail("Cannot configure server storage");
    std::wstring cmd=L"\""+server.wstring()+L"\"";std::vector<wchar_t> command(cmd.begin(),cmd.end());command.push_back(0);
    STARTUPINFOW si{sizeof(si)};PROCESS_INFORMATION pi{};
    BOOL launched=CreateProcessW(server.c_str(),command.data(),nullptr,nullptr,FALSE,CREATE_NO_WINDOW|CREATE_SUSPENDED,nullptr,rt.directory.c_str(),&si,&pi);
    DWORD error=GetLastError();SetEnvironmentVariableW(L"NL_CLOUD_PATH",old_size?old.data():nullptr);
    if(!launched){SetLastError(error);return fail("Cannot start embedded server");}
    rt.process.h=pi.hProcess;Handle thread(pi.hThread);rt.job.h=CreateJobObjectW(nullptr,nullptr);
    JOBOBJECT_EXTENDED_LIMIT_INFORMATION info{};info.BasicLimitInformation.LimitFlags=JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE;
    if(!rt.job||!SetInformationJobObject(rt.job.h,JobObjectExtendedLimitInformation,&info,sizeof(info))||!AssignProcessToJobObject(rt.job.h,pi.hProcess))return fail("Cannot attach server lifetime to injector");
    if(ResumeThread(thread.h)==DWORD(-1))return fail("Cannot resume server");
    ULONGLONG until=GetTickCount64()+20000;
    while(GetTickCount64()<until){if(health()&&ws_port()){std::puts("[+] Embedded server passed readiness checks.");return true;}if(WaitForSingleObject(pi.hProcess,0)==WAIT_OBJECT_0)return fail("Server exited during startup");Sleep(150);}
    return fail("Server readiness timed out; check ports 30030 and 30031");
}
DWORD find_game(){Handle snap(CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0));PROCESSENTRY32W p{sizeof(p)};if(snap&&Process32FirstW(snap.h,&p))do{if(_wcsicmp(p.szExeFile,L"csgo.exe")==0)return p.th32ProcessID;}while(Process32NextW(snap.h,&p));return 0;}
fs::path process_dir(HANDLE p){std::vector<wchar_t> path(32768);DWORD n=DWORD(path.size());return QueryFullProcessImageNameW(p,0,path.data(),&n)?fs::path(std::wstring(path.data(),n)).parent_path():fs::path{};}
uintptr_t module_base(DWORD pid,const wchar_t* name){Handle snap(CreateToolhelp32Snapshot(TH32CS_SNAPMODULE|TH32CS_SNAPMODULE32,pid));MODULEENTRY32W m{sizeof(m)};if(snap&&Module32FirstW(snap.h,&m))do{if(_wcsicmp(m.szModule,name)==0)return reinterpret_cast<uintptr_t>(m.modBaseAddr);}while(Module32NextW(snap.h,&m));return 0;}
bool inject(HANDLE process,DWORD pid,const fs::path& path){
    BOOL wow=FALSE;
    if(!IsWow64Process(process,&wow))return fail("Cannot query game architecture");
    SYSTEM_INFO sys{};GetNativeSystemInfo(&sys);if(sys.wProcessorArchitecture!=PROCESSOR_ARCHITECTURE_INTEL&&!wow)return fail("Expected 32-bit CS:GO Legacy");
    {std::ifstream in(path,std::ios::binary);IMAGE_DOS_HEADER dos{};in.read(reinterpret_cast<char*>(&dos),sizeof(dos));if(!in||dos.e_magic!=IMAGE_DOS_SIGNATURE||dos.e_lfanew<64||dos.e_lfanew>0x100000)return fail("Invalid DLL image");in.seekg(dos.e_lfanew);DWORD sig=0;IMAGE_FILE_HEADER header{};in.read(reinterpret_cast<char*>(&sig),4);in.read(reinterpret_cast<char*>(&header),sizeof(header));if(!in||sig!=IMAGE_NT_SIGNATURE||header.Machine!=IMAGE_FILE_MACHINE_I386||!(header.Characteristics&IMAGE_FILE_DLL))return fail("Expected an x86 DLL");}
    if(module_base(pid,path.filename().c_str()))return fail("DLL is already loaded; restart CS:GO to replace it");
    auto load=GetProcAddress(GetModuleHandleW(L"kernel32.dll"),"LoadLibraryW");HMODULE owner=nullptr;
    if(!load||!GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS|GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,reinterpret_cast<LPCWSTR>(load),&owner))return fail("Cannot resolve Windows loader");
    wchar_t owner_path[MAX_PATH]{};GetModuleFileNameW(owner,owner_path,MAX_PATH);uintptr_t remote=module_base(pid,fs::path(owner_path).filename().c_str());if(!remote)return fail("Cannot locate Windows loader in game");
    auto remote_load=reinterpret_cast<LPTHREAD_START_ROUTINE>(remote+(reinterpret_cast<uintptr_t>(load)-reinterpret_cast<uintptr_t>(owner)));
    std::wstring dll=path.wstring();SIZE_T size=(dll.size()+1)*sizeof(wchar_t),written=0;
    void* data=VirtualAllocEx(process,nullptr,size,MEM_COMMIT|MEM_RESERVE,PAGE_READWRITE);if(!data)return fail("Cannot allocate DLL path");
    if(!WriteProcessMemory(process,data,dll.c_str(),size,&written)||written!=size){VirtualFreeEx(process,data,0,MEM_RELEASE);return fail("Cannot write DLL path");}
    Handle thread(CreateRemoteThread(process,nullptr,0,remote_load,data,0,nullptr));if(!thread){VirtualFreeEx(process,data,0,MEM_RELEASE);return fail("Cannot start DLL loader");}
    DWORD wait=WaitForSingleObject(thread.h,30000);
    // A pending loader may still read its path. Do not free it on timeout.
    if(wait!=WAIT_OBJECT_0)return fail("DLL load did not finish within 30 seconds");
    DWORD result=0;BOOL got=GetExitCodeThread(thread.h,&result);VirtualFreeEx(process,data,0,MEM_RELEASE);
    if(!got||!result)return fail("Windows could not load neverlose.dll");
    return true;
}
}
int main(int argc,char** argv){
    SetConsoleTitleW(L"Neverlose CS:GO");std::puts("Neverlose / CS:GO Legacy\nDLL + embedded local server\n");
    WSADATA wsa{};if(WSAStartup(MAKEWORD(2,2),&wsa)!=0)return 1;
    Runtime rt;
    bool server_only=argc==2&&std::string(argv[1])=="--server-only";
    DWORD pid=server_only?0:find_game();
    if(!server_only&&!pid){std::puts("Start CS:GO Legacy in windowed or borderless mode, then run this injector.");return 1;}
    Handle game(pid?OpenProcess(PROCESS_CREATE_THREAD|PROCESS_QUERY_INFORMATION|PROCESS_VM_OPERATION|PROCESS_VM_WRITE|PROCESS_VM_READ|SYNCHRONIZE,FALSE,pid):nullptr);
    if(pid&&!game){fail("Cannot open CS:GO; use the same user and privilege level");return 1;}
    auto folder=pid?process_dir(game.h):exe_path().parent_path();if(folder.empty())return 1;
    if(!start_server(rt,folder/L"nl_cloud"))return 1;
    if(server_only){std::puts("Server-only mode. Press Enter to stop this server.");getchar();return 0;}
    if(!inject(game.h,pid,exe_path().parent_path()/L"neverlose.dll"))return 1;
    std::puts("[+] DLL loaded. Insert: new menu. Home: overlay menu.\nKeep this window open while playing. The owned server stops when CS:GO closes.");
    WaitForSingleObject(game.h,INFINITE);return 0;
}
