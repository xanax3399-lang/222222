#pragma once
#include <windows.h>

// This loader is for the supplied fixed-base, 32-bit legacy CS:GO image.
constexpr DWORD kImageBase = 0x43310000;
constexpr DWORD kImageSize = 0x002fc000;
constexpr DWORD kReservationMagic = 0x52534b53; // SKSR
constexpr DWORD kReservationVersion = 3;
struct ImageReservation {
    DWORD magic, version, pid, size;
    DWORD hypothesis_mode;
};
static_assert(sizeof(ImageReservation)==20);
enum LoaderState : LONG {
    LoaderWaiting = 0, LoaderInitializing = 1,
    LoaderEntryStarted = 2, LoaderFailed = 3
};
struct LoaderStatus {
    DWORD version;
    volatile LONG state;
    DWORD error;
    char message[244];
};
static_assert(sizeof(LoaderStatus) == 256);
