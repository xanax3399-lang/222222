#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <windows.h>
#include <tlhelp32.h>
#include <cstdio>
#include <cwchar>
#include <cstdint>
#include <cstring>
#include <cstdarg>
#include <string>
#include "../loader_protocol.h"
#include "../skeet/nl_hypotheses.h"
#include "../skeet/nl_points_status.h"
#include "../skeet/nl_stop_status.h"
#include "../skeet/v3_status.h"
#include "../skeet/v3_fire_status.h"
#include "../../stock-resolver/native_driver.h"
#include "../../stock-resolver/accuracy_status.h"

static FILE* run_log=nullptr;
static bool diagnostic_quiet=false;
static void log_line(const char* message,DWORD code=0) {
    if(!run_log)return;
    std::fprintf(run_log,"%s (code %lu)\n",message,code);std::fflush(run_log);
}
struct RunLog {
    explicit RunLog(const wchar_t* dll_path,const wchar_t* filename=L"loader_last.log") {
        wchar_t path[32768]{};
        if(std::wcslen(dll_path)>=32768)return;
        std::wcscpy(path,dll_path);auto* last=std::wcsrchr(path,L'\\');
        if(!last||last-path+std::wcslen(filename)+2>=32768)return;
        std::wcscpy(last+1,filename);run_log=_wfopen(path,L"wb");
        log_line("Legacy 8802 loader - native C++ resolver / final accuracy check / braking math");
    }
    ~RunLog(){if(run_log){std::fclose(run_log);run_log=nullptr;}}
};
static void diagnostic_printf(const char* format,...) {
    va_list args,copy;va_start(args,format);va_copy(copy,args);
    if(!diagnostic_quiet)std::vprintf(format,args);
    if(run_log){std::vfprintf(run_log,format,copy);std::fflush(run_log);}
    va_end(copy);va_end(args);
}
struct Handle {
    HANDLE value;
    explicit Handle(HANDLE h = nullptr) : value(h) {}
    ~Handle() { if (value && value != INVALID_HANDLE_VALUE) CloseHandle(value); }
    Handle(const Handle&) = delete;
    Handle& operator=(const Handle&) = delete;
};
#include "legacy_launch.h"
static int error(const char* operation) {
    DWORD code = GetLastError();
    char description[512]{};
    FormatMessageA(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
        nullptr, code, 0, description, sizeof(description), nullptr);
    log_line(operation,code);log_line(description,code);
    std::fprintf(stderr, "%s (Windows error %lu): %s\n", operation, code, description);
    return 1;
}
static DWORD game_pid() {
    Handle snapshot(CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0));
    if (snapshot.value == INVALID_HANDLE_VALUE) return 0;
    PROCESSENTRY32W item{}; item.dwSize = sizeof(item);
    if (Process32FirstW(snapshot.value, &item)) do {
        if (!_wcsicmp(item.szExeFile, L"csgo.exe")) return item.th32ProcessID;
    } while (Process32NextW(snapshot.value, &item));
    return 0;
}
static std::uintptr_t remote_load_library(HANDLE process, DWORD pid) {
    auto fn = GetProcAddress(GetModuleHandleW(L"kernel32.dll"), "LoadLibraryW");
    HMODULE owner = nullptr;
    if (!fn || !GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS |
        GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT, reinterpret_cast<LPCWSTR>(fn), &owner)) return 0;
    wchar_t path[MAX_PATH]{};
    if (!GetModuleFileNameW(owner, path, MAX_PATH)) return 0;
    const wchar_t* name = std::wcsrchr(path, L'\\');
    name = name ? name + 1 : path;
    Handle snapshot(CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, pid));
    if (snapshot.value == INVALID_HANDLE_VALUE) return 0;
    MODULEENTRY32W item{}; item.dwSize = sizeof(item);
    if (Module32FirstW(snapshot.value, &item)) do {
        if (_wcsicmp(item.szModule, name)) continue;
        auto* local = reinterpret_cast<BYTE*>(owner);
        auto* local_dos = reinterpret_cast<IMAGE_DOS_HEADER*>(local);
        auto* local_nt = reinterpret_cast<IMAGE_NT_HEADERS32*>(local + local_dos->e_lfanew);
        IMAGE_DOS_HEADER dos{}; IMAGE_NT_HEADERS32 nt{};
        SIZE_T got = 0;
        if (!ReadProcessMemory(process, item.modBaseAddr, &dos, sizeof(dos), &got) ||
            got != sizeof(dos) || dos.e_magic != IMAGE_DOS_SIGNATURE ||
            dos.e_lfanew < 0 || static_cast<DWORD>(dos.e_lfanew) > (item.modBaseSize >= sizeof(nt) ? item.modBaseSize - sizeof(nt) : 0) ||
            !ReadProcessMemory(process, item.modBaseAddr + dos.e_lfanew, &nt, sizeof(nt), &got) ||
            got != sizeof(nt) || nt.Signature != IMAGE_NT_SIGNATURE ||
            nt.FileHeader.Machine != IMAGE_FILE_MACHINE_I386 ||
            nt.FileHeader.TimeDateStamp != local_nt->FileHeader.TimeDateStamp ||
            nt.OptionalHeader.SizeOfImage != local_nt->OptionalHeader.SizeOfImage) return 0;
        const auto offset = reinterpret_cast<std::uintptr_t>(fn) - reinterpret_cast<std::uintptr_t>(owner);
        if (offset >= item.modBaseSize) return 0;
        return reinterpret_cast<std::uintptr_t>(item.modBaseAddr) + offset;
    } while (Module32NextW(snapshot.value, &item));
    return 0;
}
// SEC_IMAGE maps the on-disk PE layout for inspection; it does not execute DllMain.
static DWORD exported_rva(const wchar_t* path,const char* symbol,std::size_t required_size,IMAGE_NT_HEADERS32* metadata=nullptr) {
    Handle file(CreateFileW(path, GENERIC_READ, FILE_SHARE_READ, nullptr, OPEN_EXISTING, 0, nullptr));
    if (file.value == INVALID_HANDLE_VALUE) return 0;
    Handle mapping(CreateFileMappingW(file.value, nullptr, PAGE_READONLY | SEC_IMAGE, 0, 0, nullptr));
    if (!mapping.value) return 0;
    auto* base = static_cast<BYTE*>(MapViewOfFile(mapping.value, FILE_MAP_READ, 0, 0, 0));
    if (!base) return 0;
    DWORD result = 0;
    auto* dos = reinterpret_cast<IMAGE_DOS_HEADER*>(base);
    auto* nt = reinterpret_cast<IMAGE_NT_HEADERS32*>(base + dos->e_lfanew);
    if (nt->FileHeader.Machine == IMAGE_FILE_MACHINE_I386 &&
        nt->OptionalHeader.Magic == IMAGE_NT_OPTIONAL_HDR32_MAGIC &&
        (nt->FileHeader.Characteristics & IMAGE_FILE_DLL)) {
        const DWORD size = nt->OptionalHeader.SizeOfImage;
        auto inside = [size](DWORD rva, std::uint64_t length) { return rva < size && length <= size - rva; };
        const auto dir = nt->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT];
        if (inside(dir.VirtualAddress, sizeof(IMAGE_EXPORT_DIRECTORY))) {
            auto* exports = reinterpret_cast<IMAGE_EXPORT_DIRECTORY*>(base + dir.VirtualAddress);
            if (inside(exports->AddressOfNames, std::uint64_t(exports->NumberOfNames) * 4) &&
                inside(exports->AddressOfNameOrdinals, std::uint64_t(exports->NumberOfNames) * 2) &&
                inside(exports->AddressOfFunctions, std::uint64_t(exports->NumberOfFunctions) * 4)) {
                auto* names = reinterpret_cast<DWORD*>(base + exports->AddressOfNames);
                auto* ordinals = reinterpret_cast<WORD*>(base + exports->AddressOfNameOrdinals);
                auto* functions = reinterpret_cast<DWORD*>(base + exports->AddressOfFunctions);
                const auto symbol_size=std::strlen(symbol)+1;
                for (DWORD i = 0; i < exports->NumberOfNames; ++i) {
                    if (!inside(names[i], symbol_size) ||
                        std::memcmp(base + names[i], symbol, symbol_size) ||
                        ordinals[i] >= exports->NumberOfFunctions) continue;
                    const DWORD rva = functions[ordinals[i]];
                    if (inside(rva, required_size)) {result = rva;if(metadata)*metadata=*nt;}
                }
            }
        }
    }
    UnmapViewOfFile(base);
    return result;
}
static int diagnostics(const wchar_t* path,DWORD selected_pid=0) {
    IMAGE_NT_HEADERS32 local{};
    const DWORD rva=exported_rva(path,"skeet_nl_hypotheses_status",sizeof(nl_hypotheses::Status),&local);
    const DWORD pid=selected_pid?selected_pid:game_pid();
    if(!rva||!pid){diagnostic_printf("No matching DLL or running legacy CS:GO found.\n");return 1;}
    Handle process(OpenProcess(PROCESS_QUERY_INFORMATION|PROCESS_VM_READ,FALSE,pid));
    if(!process.value)return error("Cannot open game for read-only diagnostics");
    Handle modules(CreateToolhelp32Snapshot(TH32CS_SNAPMODULE,pid));
    if(modules.value==INVALID_HANDLE_VALUE)return error("Cannot list game modules");
    MODULEENTRY32W item{};item.dwSize=sizeof(item);
    if(Module32FirstW(modules.value,&item))do {
        if(_wcsicmp(item.szModule,L"skeet.dll"))continue;
        IMAGE_DOS_HEADER dos{};IMAGE_NT_HEADERS32 nt{};SIZE_T got=0;
        if(!ReadProcessMemory(process.value,item.modBaseAddr,&dos,sizeof(dos),&got)||got!=sizeof(dos)||
           dos.e_magic!=IMAGE_DOS_SIGNATURE||dos.e_lfanew<0||item.modBaseSize<sizeof(nt)||
           DWORD(dos.e_lfanew)>item.modBaseSize-sizeof(nt)||
           !ReadProcessMemory(process.value,item.modBaseAddr+dos.e_lfanew,&nt,sizeof(nt),&got)||got!=sizeof(nt)||
           nt.Signature!=IMAGE_NT_SIGNATURE||nt.FileHeader.Machine!=IMAGE_FILE_MACHINE_I386||
           nt.FileHeader.TimeDateStamp!=local.FileHeader.TimeDateStamp||
           nt.OptionalHeader.SizeOfImage!=local.OptionalHeader.SizeOfImage) {
            diagnostic_printf("Loaded DLL does not match this diagnostic build; restart CS:GO and use the matching injector/DLL pair.\n");return 1;
        }
        nl_hypotheses::Status status{};
        if(!ReadProcessMemory(process.value,item.modBaseAddr+rva,&status,sizeof(status),&got)||
           got!=sizeof(status)||status.version!=1||!nl_hypotheses::valid_mode(status.mode))return error("Cannot read hypothesis diagnostics");
        float input=0,output=0;std::int32_t in_bits=status.last_input_bits,out_bits=status.last_output_bits;
        std::memcpy(&input,&in_bits,4);std::memcpy(&output,&out_bits,4);
        diagnostic_printf("Mode: %s\nInstalled: %ld\nBuilder calls: %ld\nHypotheses supplied: %ld\nRejected inputs: %ld\n",
            status.mode==8?"Native C++ resolver + accuracy/braking patch":status.mode==0?"GameSense":status.mode==1?"NL animation hypotheses":status.mode==2?"v2 NL points":status.mode==6?"v3 head crown + fire/recharge":"NL points + animation",long(status.installed),
            long(status.calls),long(status.changed),long(status.rejected));
        if(status.changed)diagnostic_printf("Last sample: GS variant %ld, record tick %ld, base %.3f -> goal %.3f\n",
            long(status.last_variant),long(status.last_tick),input,output);
        const DWORD points_rva=exported_rva(path,"skeet_nl_points_status",sizeof(nl_points_patch::Status));
        nl_points_patch::Status points{};
        if(!points_rva||!ReadProcessMemory(process.value,item.modBaseAddr+points_rva,&points,sizeof(points),&got)||
           got!=sizeof(points)||points.version!=2)return error("Cannot read NL points diagnostics");
        diagnostic_printf("NL points installed: %ld\nCalls: %ld\nNL points added: %ld\nNative-only fallback: %ld\nFiltered by three matrices: %ld\nStorage fallback: %ld\nHead/body scale: %u/%u%%\n",
            points.installed,points.calls,points.generated,points.fallback,points.filtered,points.pool_full,points.head_percent,points.body_percent);
        diagnostic_printf("Native generator calls: %ld\nNative points kept: %ld\nNo additional NL points: %ld\nNative primary center restored: %ld\nHead native points kept: %ld\nHead NL points added: %ld\nLast hitbox: %ld; original: %ld; added: %ld\n",
            points.native_calls,points.kept,points.empty_fallback,points.centroid_restores,points.head_kept,points.head_added,
            points.last_hitbox,points.last_original,points.last_added);
        const DWORD stop_rva=exported_rva(path,"skeet_nl_stop_status",sizeof(nl_stop_patch::Status));
        nl_stop_patch::Status stop{};
        if(!stop_rva||!ReadProcessMemory(process.value,item.modBaseAddr+stop_rva,&stop,sizeof(stop),&got)||
           got!=sizeof(stop)||stop.version!=1)return error("Cannot read NL brake diagnostics");
        diagnostic_printf("NL brake enabled: %u; installed: %ld\nGS brake samples: %ld; NL brake applied: %ld; native fallback: %ld\n",
            stop.enabled,stop.installed,stop.calls,stop.applied,stop.fallback);
        if(stop.applied)diagnostic_printf("Last brake: speed after GS friction %.3f; effective wishspeed %.3f; accelerate %.3f; interval %.6f; grounded %ld; forward %.3f -> %.3f\n",
            stop.speed,stop.max_speed,stop.accelerate,stop.interval,stop.last_grounded,stop.before,stop.after);
        const DWORD v3_rva=exported_rva(path,"skeet_v3_status",sizeof(v3_patches::Status));
        v3_patches::Status v3{};
        if(!v3_rva||!ReadProcessMemory(process.value,item.modBaseAddr+v3_rva,&v3,sizeof(v3),&got)||got!=sizeof(v3)||v3.version!=1)
            return error("Cannot read v3 diagnostics");
        diagnostic_printf("V3 head crown installed: %ld; scale %u%%\nHead calls: %ld; crown candidates: %ld; committed: %ld; matrix rejected: %ld; duplicates: %ld; geometry fallback: %ld\n",
            v3.installed,v3.crown_percent,v3.head_calls,v3.considered,v3.added,v3.filtered,v3.duplicates,v3.geometry_fallback);
        const DWORD fire_rva=exported_rva(path,"skeet_v3_fire_status",sizeof(v3_fire::Status));
        v3_fire::Status fire{};
        if(!fire_rva||!ReadProcessMemory(process.value,item.modBaseAddr+fire_rva,&fire,sizeof(fire),&got)||got!=sizeof(fire)||fire.version!=1)
            return error("Cannot read v3 firing/recharge diagnostics");
        diagnostic_printf("V3 firing/recharge installed: %ld; late eye guard: %u; guarded early DT recharge: %u\nCommands: %ld; DT key releases: %ld; last command: %ld; DT mode: %ld; charge: %ld/%ld\n",
            fire.installed,fire.guard_enabled,fire.recharge_enabled,fire.commands,fire.dt_releases,
            fire.last_command,fire.last_dt_mode,fire.last_charge,fire.last_desired);
        diagnostic_printf("Fire guard calls: %ld; unchanged: %ld; rechecks: %ld; canceled: %ld; DT bypass: %ld; manual attack bypass: %ld; fallback: %ld; last probability: %.3f\nRecharge gate visits: %ld; aim gate overrides: %ld (native pending-shot wait and cooldown retained)\n",
            fire.guard_calls,fire.unchanged,fire.rechecks,fire.canceled,fire.dt_bypass,fire.manual_bypass,
            fire.fallback,fire.last_probability,fire.recharge_checks,fire.recharge_overrides);
        const DWORD native_rva=exported_rva(path,"sr_driver_status",sizeof(stock_native::DriverStatus));
        if(native_rva) {
            stock_native::DriverStatus native{};
            if(!ReadProcessMemory(process.value,item.modBaseAddr+native_rva,&native,sizeof(native),&got)||got!=sizeof(native)||native.version!=1)
                return error("Cannot read native C++ resolver diagnostics");
            diagnostic_printf("\nNative C++ resolver: enabled %u; state %u (0 off, 1 prepared, 2 waiting, 3 active, 4 failed); error %u; installed %u\nFrame callbacks: %u; network updates: %u; frames: %u\nTracked: %u; active overrides: %u; manual blocks: %u; invalid controls: %u\nNetvar mask: %03X; previous callback: %08X; vtable slot: %08X\nRecords: %u; duplicates: %u; rejected: %u; model decisions: %u; GS fallbacks: %u\nThreshold: %.2f; native memory: %u bytes; update last/worst: %.3f/%.3f ms\n",
                native.enabled,native.state,native.error,native.installed,native.callbacks,native.updates,native.frames,
                native.tracked,native.applied,native.blocked,native.invalid_controls,native.netvar_mask,native.previous,native.slot,
                native.records,native.duplicates,native.rejected,native.selected,native.fallback,native.threshold,native.memory_bytes,native.last_update_ms,native.worst_update_ms);
        }
        const DWORD accuracy_rva=exported_rva(path,"sr_accuracy_status",sizeof(native_accuracy::Status));
        if(accuracy_rva) {
            native_accuracy::Status accuracy{};
            if(!ReadProcessMemory(process.value,item.modBaseAddr+accuracy_rva,&accuracy,sizeof(accuracy),&got)||got!=sizeof(accuracy)||accuracy.version!=1)
                return error("Cannot read native accuracy diagnostics");
            diagnostic_printf("\nAccuracy patch: installed %ld; final check %u; NL brake math %u\nGuard calls: %ld; unchanged: %ld; rechecks: %ld; vetoed: %ld; geometry changes: %ld; precision changes: %ld\nDT/release bypass: %ld; manual bypass: %ld; native fast path: %ld; other weapons: %ld; fallback: %ld\nLast weapon: %ld; probability/effective/threshold: %.3f/%.3f/%.3f\nBrake calls/applied/fallback: %ld/%ld/%ld; speed %.3f; wishspeed %.3f; forward %.3f -> %.3f\n",
                accuracy.installed,accuracy.check_enabled,accuracy.brake_enabled,accuracy.guard_calls,accuracy.unchanged,accuracy.rechecks,accuracy.canceled,accuracy.geometry_changed,accuracy.precision_changed,
                accuracy.dt_bypass,accuracy.manual_bypass,accuracy.fast_bypass,accuracy.unsupported,accuracy.fallback,accuracy.last_weapon,accuracy.last_probability,accuracy.last_effective,accuracy.last_threshold,
                accuracy.brake_calls,accuracy.brake_applied,accuracy.brake_fallback,accuracy.speed,accuracy.wish,accuracy.before,accuracy.after);
        }
        diagnostic_printf("GS chooses stop timing and recharge safety. Counters do not measure aiming accuracy.\n");return 0;
    }while(Module32NextW(modules.value,&item));
    diagnostic_printf("skeet.dll is not loaded in this game.\n");return 1;
}
static int run_diagnostics(const wchar_t* path,bool interactive) {
    RunLog output(path,L"module_diagnostics.log");
    const int result=diagnostics(path);
    if(run_log)diagnostic_printf("\nSaved: module_diagnostics.log beside injector.exe\n");
    else std::fputs("Cannot save module_diagnostics.log beside injector.exe.\n",stderr);
    DWORD mode=0;
    if(interactive&&GetConsoleMode(GetStdHandle(STD_INPUT_HANDLE),&mode)) {
        std::printf("Press Enter to close...");std::fflush(stdout);char line[32]{};
        std::fgets(line,sizeof(line),stdin);
    }
    return result;
}
#include "launcher_reports.h"
int wmain(int argc,wchar_t** argv) {
    SetConsoleTitleW(L"Legacy CS:GO 8802 - automatic launch");
    wchar_t path[32768]{};
    const DWORD length = GetModuleFileNameW(nullptr, path, 32768);
    if (!length || length >= 32768) return error("Cannot determine injector location");
    wchar_t* last = std::wcsrchr(path, L'\\');
    if (!last || last - path + 11 >= 32768) return 1;
    std::wcscpy(last + 1, L"skeet.dll");
    const DWORD export_rva = exported_rva(path,"skeet_loader_status",sizeof(LoaderStatus));
    if (!export_rva) {
        std::fprintf(stderr, "Place the matching 32-bit skeet.dll beside injector.exe (loader status export required).\n");
        return 1;
    }
    const wchar_t* explicit_game=nullptr;int mode=-1;bool show_diagnostics=false;
    if(argc>1&&!_wcsicmp(argv[1],L"--watch")) {
        DWORD watched_pid=0,low=0,high=0;
        if(argc!=5||!launcher_reports::number(argv[2],watched_pid)||!watched_pid||
           !launcher_reports::number(argv[3],low)||!launcher_reports::number(argv[4],high)) {
            std::fputs("Invalid background report arguments.\n",stderr);return 1;
        }
        return launcher_reports::watch(path,watched_pid,FILETIME{low,high});
    }
    for(int i=1;i<argc;++i) {
        if(!_wcsicmp(argv[i],L"--game")&&i+1<argc&&!explicit_game)explicit_game=argv[++i];
        else if(!_wcsicmp(argv[i],L"--mode")&&i+1<argc&&mode<0) {
            const auto* value=argv[++i];
            if(!_wcsicmp(value,L"stock"))mode=0;
            else if(!_wcsicmp(value,L"stock-resolver"))mode=8;
            else mode=99;
        } else if(!_wcsicmp(argv[i],L"--diagnostics")&&!show_diagnostics)show_diagnostics=true;
        else {
            std::fprintf(stderr,"Usage: injector.exe [--game \"path to csgo.exe\"] [--mode stock|stock-resolver]\n       injector.exe --diagnostics\n");return 1;
        }
    }
    if((mode>=0&&!nl_hypotheses::valid_mode(static_cast<unsigned>(mode)))||(show_diagnostics&&(mode>=0||explicit_game))) {
        std::fprintf(stderr,"Invalid or conflicting mode arguments.\n");return 1;
    }
    if(show_diagnostics)return run_diagnostics(path,false);
    while(mode<0) {
        std::puts("1 - Original GameSense\n2 - Native C++ resolver + accuracy/braking patch (no Lua)\n5 - Read loader diagnostics\n8 - Open last loader report\n0 - Exit");
        std::printf("Choice [Enter = 2]: ");char choice[32]{};
        if(!std::fgets(choice,sizeof(choice),stdin))choice[0]='2';
        if(choice[0]=='0')return 0;
        if(choice[0]=='5')return run_diagnostics(path,true);
        if(choice[0]=='8'){launcher_reports::open_report(path);continue;}
        if(choice[0]=='2'||choice[0]=='\n'||choice[0]=='\r')mode=8;
        else if(choice[0]=='1')mode=0;
        else {std::fprintf(stderr,"Unknown choice.\n");return 1;}
    }
    RunLog startup_log(path);
    const char* mode_message=mode==8?"Selected: stock GS with integrated native resolver / C++ accuracy and braking patch. No Lua driver.":"Selected: original GameSense gameplay.";
    std::puts(mode_message);log_line(mode_message);
    if(mode==8&&(!exported_rva(path,"sr_driver_status",sizeof(stock_native::DriverStatus))||
        !exported_rva(path,"sr_accuracy_status",sizeof(native_accuracy::Status)))) {
        SetLastError(ERROR_REVISION_MISMATCH);return error("Native accuracy mode needs the matching skeet.dll from this archive");
    }
    DWORD pid=game_pid();Handle process;legacy_launch::Suspended suspended;
    if(!pid) {
        const auto root=legacy_launch::steam_root();
        const auto game=explicit_game?legacy_launch::fs::path(explicit_game):legacy_launch::discover(root);
        if(game.empty()||!legacy_launch::executable(game)) {
            log_line("Legacy csgo.exe (x86) was not found.");
            std::fprintf(stderr,"Legacy csgo.exe (x86) was not found in Steam libraries. Install/select csgo_legacy or use injector.exe --game \"full path to csgo.exe\".\n");return 1;
        }
        if(!legacy_launch::ensure_steam(root))return error("Cannot start Steam");
        std::puts("Launching legacy CS:GO...");
        log_line("Launching legacy CS:GO...");
        if(!legacy_launch::launch(game,process,suspended,pid))return error("Cannot launch legacy CS:GO");
    } else {
        process.value=OpenProcess(SYNCHRONIZE|PROCESS_CREATE_THREAD|PROCESS_QUERY_INFORMATION|
            PROCESS_VM_OPERATION|PROCESS_VM_READ|PROCESS_VM_WRITE,FALSE,pid);
        if(!process.value)return error("Cannot open csgo.exe");
    }
    BOOL self_wow = FALSE, target_wow = FALSE;
    if (!IsWow64Process(GetCurrentProcess(), &self_wow) ||
        !IsWow64Process(process.value, &target_wow)) return error("Cannot check process architecture");
    if (self_wow != target_wow) { std::fprintf(stderr, "The target must be a 32-bit legacy CS:GO process.\n"); return 1; }
    void* image = VirtualAllocEx(process.value, reinterpret_cast<void*>(kImageBase), kImageSize,
        MEM_RESERVE | MEM_COMMIT, PAGE_EXECUTE_READWRITE);
    if (image != reinterpret_cast<void*>(kImageBase)) {
        if (image) VirtualFreeEx(process.value, image, 0, MEM_RELEASE);
        SetLastError(ERROR_INVALID_ADDRESS);
        return error("Original fixed image address is occupied; restart the game before retrying");
    }
    auto release_image = [&]() { VirtualFreeEx(process.value, image, 0, MEM_RELEASE); };
    ImageReservation marker{kReservationMagic,kReservationVersion,pid,kImageSize,static_cast<DWORD>(mode)};
    SIZE_T written = 0;
    if (!WriteProcessMemory(process.value, image, &marker, sizeof(marker), &written) || written != sizeof(marker)) {
        DWORD code = GetLastError(); release_image(); SetLastError(code); return error("Cannot mark image reservation");
    }
    // Reserve the core before the new process starts allocating engine memory.
    if(!suspended.resume()) {DWORD code=GetLastError();release_image();SetLastError(code);return error("Cannot resume game startup");}
    std::puts("Waiting for client, engine and Steam overlay (up to 120 seconds)...");
    log_line("Waiting for game modules and Steam overlay.");
    if(!legacy_launch::wait_modules(process.value,pid)) {
        DWORD code=GetLastError();release_image();SetLastError(code);
        return error("Game/Steam overlay did not initialize; check Steam login and overlay settings");
    }
    const auto remote_fn = remote_load_library(process.value, pid);
    if (!remote_fn) { SetLastError(ERROR_REVISION_MISMATCH); release_image(); return error("Cannot resolve target LoadLibraryW owner/RVA"); }
    const SIZE_T path_bytes = (std::wcslen(path) + 1) * sizeof(wchar_t);
    void* argument = VirtualAllocEx(process.value, nullptr, path_bytes, MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);
    if (!argument || !WriteProcessMemory(process.value, argument, path, path_bytes, &written) || written != path_bytes) {
        DWORD code = GetLastError();
        if (argument) VirtualFreeEx(process.value, argument, 0, MEM_RELEASE);
        release_image(); SetLastError(code); return error("Cannot copy DLL path");
    }
    Handle thread(CreateRemoteThread(process.value, nullptr, 0,
        reinterpret_cast<LPTHREAD_START_ROUTINE>(remote_fn), argument, 0, nullptr));
    if (!thread.value) {
        DWORD code = GetLastError();
        VirtualFreeEx(process.value, argument, 0, MEM_RELEASE);
        release_image(); SetLastError(code); return error("Cannot start DLL load");
    }
    if (WaitForSingleObject(thread.value, 30000) != WAIT_OBJECT_0) {
        log_line("DLL load did not finish within 30 seconds.");
        std::fprintf(stderr, "DLL load did not finish. Remote allocations retained because the thread may still use them. Restart the game before retrying.\n");
        return 1;
    }
    DWORD module = 0;
    const BOOL got_exit = GetExitCodeThread(thread.value, &module);
    VirtualFreeEx(process.value, argument, 0, MEM_RELEASE);
    if (!got_exit) return error("Cannot read DLL load result");
    if (!module) {
        release_image(); SetLastError(ERROR_DLL_INIT_FAILED); return error("Target LoadLibraryW returned NULL");
    }
    std::puts("DLL mapped. Waiting for its initialization status...");
    log_line("DLL mapped. Waiting for its initialization status...");
    const auto initialize_start = GetTickCount64();
    LONG logged_state=-1;char logged_message[244]{};DWORD logged_error=0;
    while (GetTickCount64() - initialize_start < 210000) {
        LoaderStatus status{};
        SIZE_T got = 0;
        if (!ReadProcessMemory(process.value, reinterpret_cast<void*>(module + export_rva), &status, sizeof(status), &got) ||
            got != sizeof(status) || status.version != 1) return error("Cannot read DLL initialization status");
        status.message[sizeof(status.message) - 1] = 0;
        if(status.state!=logged_state||status.error!=logged_error||std::strcmp(status.message,logged_message)){
            log_line(status.message,status.error);logged_state=status.state;logged_error=status.error;
            std::memcpy(logged_message,status.message,sizeof(logged_message));
            std::printf("%s (code %lu)\n",status.message,status.error);std::fflush(stdout);
        }
        if (status.state == LoaderFailed || status.state == LoaderEntryStarted) {
            std::printf("%s (code %lu)\n", status.message, status.error);
            if (status.state == LoaderFailed) std::puts("Restart the game before retrying.");
            else launcher_reports::start(path,process.value,pid);
            return status.state == LoaderEntryStarted ? 0 : 1;
        }
        if (WaitForSingleObject(process.value, 0) == WAIT_OBJECT_0) {
            log_line("The game exited during initialization.");
            std::fprintf(stderr, "The game exited during initialization.\n"); return 1;
        }
        Sleep(100);
    }
    std::fprintf(stderr, "Initialization status timed out; in-game functionality is not confirmed. Restart before retrying.\n");
    log_line("Initialization status timed out; in-game functionality is not confirmed.");
    return 1;
}
