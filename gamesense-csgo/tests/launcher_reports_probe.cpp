// The test-only entry calls the production post-injection reporting routine
// against a controlled, already running process. Other arguments, including the
// spawned --watch child, use the actual production loader entry point.
#define wmain production_loader_main
#include "../source/steam/steam.cpp"
#undef wmain
int wmain(int argc,wchar_t** argv) {
    if(argc==3&&!_wcsicmp(argv[1],L"--probe-latest")) {
        wchar_t path[32768]{};const DWORD n=GetModuleFileNameW(nullptr,path,32768);
        if(!n||n>=32768)return 3;
        const auto dll=launcher_reports::beside(path,L"skeet.dll");
        return _wcsicmp(launcher_reports::latest(dll.c_str()).c_str(),argv[2])?1:0;
    }
    if(argc!=4||_wcsicmp(argv[1],L"--probe-start"))return production_loader_main(argc,argv);
    DWORD pid=0;if(!launcher_reports::number(argv[2],pid)||!pid)return 2;
    wchar_t path[32768]{};const DWORD n=GetModuleFileNameW(nullptr,path,32768);
    if(!n||n>=32768)return 3;
    const auto dll=launcher_reports::beside(path,L"skeet.dll");
    Handle process(OpenProcess(SYNCHRONIZE|PROCESS_QUERY_INFORMATION|PROCESS_VM_READ,FALSE,pid));
    if(!process.value)return 4;
    RunLog parent_log(dll.c_str(),L"report-probe.log");
    const DWORD child=launcher_reports::start(dll.c_str(),process.value,pid);
    log_line("Parent log restored after automatic snapshot.");
    FILE* output=_wfopen(argv[3],L"wb");if(!output)return 5;
    std::fprintf(output,"%lu\n",child);std::fclose(output);return 0;
}
