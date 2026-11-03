#pragma once
// Bounded first-AV diagnostics. No exception suppression or register changes.
#include <cstdarg>
#include <cstdio>
#include <cwchar>
#include "nl_hypotheses_patch.h"
#include "nl_points_status.h"
extern "C" __declspec(dllexport) nl_points_patch::Status skeet_nl_points_status;
namespace crash_report {
inline wchar_t path[32768]{};
inline volatile LONG writing=0;
inline void initialize(HMODULE module) {
    const auto n=GetModuleFileNameW(module,path,32768);
    if(!n||n>=32768){path[0]=0;return;}
    auto* slash=std::wcsrchr(path,L'\\');
    if(!slash||slash-path+18>=32768){path[0]=0;return;}
    std::wcscpy(slash+1,L"skeet_crash.log");
}
inline void line(HANDLE file,const char* format,...) {
    char buffer[768]{};va_list args;va_start(args,format);
    const int count=std::vsnprintf(buffer,sizeof(buffer),format,args);va_end(args);
    if(count<=0)return;
    const DWORD length=count<static_cast<int>(sizeof(buffer))?count:sizeof(buffer)-1;
    DWORD written=0;WriteFile(file,buffer,length,&written,nullptr);
}
inline void memory(HANDLE file,const char* label,DWORD address,DWORD length) {
    unsigned char buffer[256]{};SIZE_T got=0;
    if(length>sizeof(buffer))length=sizeof(buffer);
    const BOOL ok=ReadProcessMemory(GetCurrentProcess(),reinterpret_cast<void*>(address),buffer,length,&got);
    line(file,"%s address=%08lX bytes=%lu read_ok=%lu\r\n",label,address,static_cast<DWORD>(got),static_cast<DWORD>(ok));
    for(DWORD i=0;i<got;i+=16) {
        line(file,"%08lX:",address+i);
        for(DWORD j=i;j<got&&j<i+16;++j)line(file," %02X",buffer[j]);
        line(file,"\r\n");
    }
}
inline bool write(EXCEPTION_POINTERS* info) {
    if(!info||!info->ExceptionRecord||!info->ContextRecord||!path[0]||
       info->ExceptionRecord->ExceptionCode!=EXCEPTION_ACCESS_VIOLATION||
       InterlockedCompareExchange(&writing,1,0)!=0)return false;
    HANDLE file=CreateFileW(path,GENERIC_WRITE,FILE_SHARE_READ,nullptr,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,nullptr);
    if(file==INVALID_HANDLE_VALUE){InterlockedExchange(&writing,0);return false;}
    const auto& c=*info->ContextRecord;const auto& e=*info->ExceptionRecord;
    const auto& s=skeet_nl_hypotheses_status;const auto& t=nl_hypotheses_patch::last_bridge;
    line(file,"Skeet NL animation hypotheses - r3 crash diagnostics\r\n");
    line(file,"exception=%08lX eip=%08lX thread=%lu\r\n",e.ExceptionCode,c.Eip,GetCurrentThreadId());
    if(e.NumberParameters>=2)line(file,"access_kind=%lu target=%08lX (0=read 1=write 8=execute)\r\n",
                                 static_cast<DWORD>(e.ExceptionInformation[0]),static_cast<DWORD>(e.ExceptionInformation[1]));
    line(file,"eax=%08lX ebx=%08lX ecx=%08lX edx=%08lX\r\n",c.Eax,c.Ebx,c.Ecx,c.Edx);
    line(file,"esi=%08lX edi=%08lX ebp=%08lX esp=%08lX flags=%08lX\r\n",c.Esi,c.Edi,c.Ebp,c.Esp,c.EFlags);
    line(file,"mode=%lu installed=%ld calls=%ld supplied=%ld rejected=%ld\r\n",
         s.mode,static_cast<LONG>(s.installed),static_cast<LONG>(s.calls),static_cast<LONG>(s.changed),static_cast<LONG>(s.rejected));
    const auto& p=skeet_nl_points_status;
    line(file,"nl_points: mode=%u installed=%ld calls=%ld generated=%ld fallback=%ld filtered=%ld pool_full=%ld head=%u body=%u reduced=%u\r\n",
         p.mode,p.installed,p.calls,p.generated,p.fallback,p.filtered,p.pool_full,p.head_percent,p.body_percent,p.reduced_head);
    line(file,"last_bridge_best_effort: sequence=%lu phase=%ld sp=%08lX caller=%08lX variant=%lu\r\n",
         t.sequence,static_cast<LONG>(t.phase),t.native_stack,t.caller,t.variant);
    line(file,"last_bridge_registers EDI ESI EBP savedESP EBX EDX ECX EAX:\r\n");
    for(unsigned i=0;i<8;++i)line(file,"%08lX%s",t.registers[i],i==7?"\r\n":" ");
    DWORD values[4]{};std::memcpy(values,&t.input,sizeof(values));
    line(file,"last_bridge_float_bits input=%08lX low=%08lX high=%08lX output=%08lX\r\n",
         values[0],values[1],values[2],values[3]);
    memory(file,"fault_code",c.Eip,32);
    memory(file,"native_hook",0x433fb4be,13);
    memory(file,"stack",c.Esp,256);
    if(c.Eip==0x433d5f12) {
        line(file,"fault_instruction=cmp byte ptr [ecx+4347BE0A],0 expected_target=%08lX\r\n",c.Ecx+0x4347be0aUL);
        memory(file,"index_locals_at_esp_plus_1A0",c.Esp+0x1a0,16);
    }
    FlushFileBuffers(file);CloseHandle(file);InterlockedExchange(&writing,0);return true;
}
}
