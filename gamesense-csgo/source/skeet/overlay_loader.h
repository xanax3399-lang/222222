#pragma once
#include <windows.h>
#include <cstring>
#include "overlay_patch.h"

namespace overlay_patch {
struct Addresses { DWORD return_address = 0, reference_address = 0; };
inline bool readable(const void* address, std::size_t size) {
    auto p = reinterpret_cast<std::uintptr_t>(address);
    if (!p || size > UINTPTR_MAX - p) return false;
    const auto end = p + size;
    while (p < end) {
        MEMORY_BASIC_INFORMATION mbi{};
        if (!VirtualQuery(reinterpret_cast<void*>(p), &mbi, sizeof(mbi)) ||
            mbi.State != MEM_COMMIT || (mbi.Protect & (PAGE_GUARD | PAGE_NOACCESS))) return false;
        const DWORD access = mbi.Protect & 0xff;
        if (access != PAGE_READONLY && access != PAGE_READWRITE && access != PAGE_WRITECOPY &&
            access != PAGE_EXECUTE_READ && access != PAGE_EXECUTE_READWRITE &&
            access != PAGE_EXECUTE_WRITECOPY) return false;
        const auto next = reinterpret_cast<std::uintptr_t>(mbi.BaseAddress) + mbi.RegionSize;
        if (next <= p) return false;
        p = next < end ? next : end;
    }
    return true;
}
inline bool resolve(Addresses& out, const char*& error) {
    out = {};
    auto* base = reinterpret_cast<std::uint8_t*>(GetModuleHandleW(L"gameoverlayrenderer.dll"));
    error = "gameoverlayrenderer.dll is missing; enable the Steam overlay and restart the game.";
    if (!readable(base, sizeof(IMAGE_DOS_HEADER))) return false;
    auto* dos = reinterpret_cast<IMAGE_DOS_HEADER*>(base);
    error = "Steam overlay has an unsupported PE header.";
    if (dos->e_magic != IMAGE_DOS_SIGNATURE || dos->e_lfanew < sizeof(IMAGE_DOS_HEADER) ||
        dos->e_lfanew > 0x100000) return false;
    auto* nt = reinterpret_cast<IMAGE_NT_HEADERS32*>(base + dos->e_lfanew);
    if (!readable(nt, sizeof(*nt)) || nt->Signature != IMAGE_NT_SIGNATURE ||
        nt->FileHeader.Machine != IMAGE_FILE_MACHINE_I386 ||
        nt->OptionalHeader.Magic != IMAGE_NT_OPTIONAL_HDR32_MAGIC ||
        nt->FileHeader.SizeOfOptionalHeader != sizeof(IMAGE_OPTIONAL_HEADER32) ||
        nt->FileHeader.NumberOfSections == 0 || nt->FileHeader.NumberOfSections > 96) return false;
    const auto image_size = nt->OptionalHeader.SizeOfImage;
    auto* sections = IMAGE_FIRST_SECTION(nt);
    const auto section_end = reinterpret_cast<std::uint8_t*>(sections + nt->FileHeader.NumberOfSections) - base;
    if (image_size < 4096 || image_size > 0x20000000 || section_end > nt->OptionalHeader.SizeOfHeaders ||
        nt->OptionalHeader.SizeOfHeaders > image_size ||
        !readable(sections, nt->FileHeader.NumberOfSections * sizeof(*sections))) return false;
    std::size_t returns = 0, references = 0;
    std::uint8_t *ret = nullptr, *ref = nullptr;
    for (WORD i = 0; i < nt->FileHeader.NumberOfSections; ++i) {
        const auto& s = sections[i];
        const auto n = s.Misc.VirtualSize;
        if (!(s.Characteristics & IMAGE_SCN_MEM_EXECUTE) || !n) continue;
        if (s.VirtualAddress >= image_size || n > image_size - s.VirtualAddress) return false;
        auto* data = base + s.VirtualAddress;
        if (!readable(data, n)) continue;
        auto r = find(data, n, return_pattern);
        auto x = find(data, n, reference_pattern);
        returns += r.count; references += x.count;
        if (r.count) ret = data + r.offset;
        if (x.count) ref = data + x.offset;
    }
    error = "Steam overlay signatures missing or ambiguous. Initialization stopped (no null-address patch).";
    if (returns != 1 || references != 1) return false;
    DWORD reference = 0;
    std::memcpy(&reference, ref + 2, sizeof(reference));
    const auto start = reinterpret_cast<std::uintptr_t>(base);
    error = "Steam overlay reference operand is outside its image or unreadable.";
    if (reference < start || reference - start > image_size - sizeof(DWORD) ||
        !readable(reinterpret_cast<void*>(reference), sizeof(DWORD))) return false;
    out.return_address = reinterpret_cast<DWORD>(ret);
    out.reference_address = reference;
    error = nullptr;
    return true;
}
}
