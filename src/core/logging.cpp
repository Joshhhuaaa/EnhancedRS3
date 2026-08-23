#include "stdafx.h"
#include "common.hpp"
#include "logging.hpp"
#include "version.h"

#include <cstring>
#include <cstdlib>
#include <intrin.h>
#include <winver.h>

#include <spdlog/sinks/basic_file_sink.h>
#ifdef ENHANCED_DEBUG
#include <spdlog/sinks/stdout_sinks.h>
#endif

namespace
{
    std::string Trim(std::string text)
    {
        auto first = text.find_first_not_of(' ');
        auto last = text.find_last_not_of(' ');
        return first == std::string::npos ? std::string() : text.substr(first, last - first + 1);
    }

    std::string RegString(HKEY key, const char* name)
    {
        char buffer[256]{};
        DWORD size = sizeof(buffer) - 1;

        if (RegQueryValueExA(key, name, nullptr, nullptr, reinterpret_cast<LPBYTE>(buffer), &size) != ERROR_SUCCESS)
            return {};

        return buffer;
    }

    std::string FileVersion(const std::filesystem::path& file)
    {
        DWORD ignored = 0;
        auto size = GetFileVersionInfoSizeW(file.c_str(), &ignored);
        if (!size)
            return {};

        std::vector<uint8_t> data(size);
        VS_FIXEDFILEINFO* fixed = nullptr;
        UINT length = 0;

        if (!GetFileVersionInfoW(file.c_str(), 0, size, data.data()) ||
            !VerQueryValueW(data.data(), L"\\", reinterpret_cast<void**>(&fixed), &length) || !fixed)
            return {};

        return std::format("{}.{}.{}.{}",
            HIWORD(fixed->dwFileVersionMS), LOWORD(fixed->dwFileVersionMS),
            HIWORD(fixed->dwFileVersionLS), LOWORD(fixed->dwFileVersionLS));
    }

    std::string OSVersion()
    {
        std::string name, display, build;
        DWORD ubr = 0;

        HKEY key = nullptr;
        if (RegOpenKeyExA(HKEY_LOCAL_MACHINE, "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion",
                          0, KEY_READ | KEY_WOW64_64KEY, &key) == ERROR_SUCCESS)
        {
            name = RegString(key, "ProductName");
            display = RegString(key, "DisplayVersion");
            build = RegString(key, "CurrentBuildNumber");

            DWORD size = sizeof(ubr);
            RegQueryValueExA(key, "UBR", nullptr, nullptr, reinterpret_cast<LPBYTE>(&ubr), &size);
            RegCloseKey(key);
        }

        if (name.empty())
            return "unknown";

        // ProductName still reads "Windows 10" on 11, the build number is the only tell.
        if (std::atoi(build.c_str()) >= 22000)
        {
            auto ten = name.find("Windows 10");
            if (ten != std::string::npos)
                name.replace(ten, 10, "Windows 11");
        }

        if (!display.empty())
            name += " " + display;
        if (!build.empty())
            name += std::format(" (build {}.{})", build, ubr);

        return name;
    }

    // A compatibility mode lies to RtlGetVersion, which is why the build above comes from the registry
    void LogShimmedVersion()
    {
        RTL_OSVERSIONINFOW info{ sizeof(info) };
        auto rtlGetVersion = reinterpret_cast<LONG(WINAPI*)(PRTL_OSVERSIONINFOW)>(
            GetProcAddress(GetModuleHandleW(L"ntdll.dll"), "RtlGetVersion"));

        if (!rtlGetVersion || rtlGetVersion(&info) != 0)
            return;

        HKEY key = nullptr;
        if (RegOpenKeyExA(HKEY_LOCAL_MACHINE, "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion",
                          0, KEY_READ | KEY_WOW64_64KEY, &key) != ERROR_SUCCESS)
            return;

        auto real = std::atoi(RegString(key, "CurrentBuildNumber").c_str());
        RegCloseKey(key);

        if (real && info.dwBuildNumber != static_cast<DWORD>(real))
            spdlog::warn("OS: Compatibility mode is on, the game sees {}.{} build {}",
                info.dwMajorVersion, info.dwMinorVersion, info.dwBuildNumber);
    }

    std::string HostVersion()
    {
        auto ntdll = GetModuleHandleW(L"ntdll.dll");

        auto wineVersion = reinterpret_cast<const char*(__cdecl*)()>(GetProcAddress(ntdll, "wine_get_version"));
        if (!wineVersion)
            return {};

        auto host = std::format("Wine {}", wineVersion());

        auto wineHost = reinterpret_cast<void(__cdecl*)(const char**, const char**)>(
            GetProcAddress(ntdll, "wine_get_host_version"));

        const char* sysname = nullptr;
        const char* release = nullptr;

        if (wineHost)
        {
            wineHost(&sysname, &release);
            if (sysname && release)
                host += std::format(" on {} {}", sysname, release);
        }

        return host;
    }

    std::string CPUName()
    {
        int regs[4]{};
        __cpuid(regs, 0x80000000);

        if (static_cast<uint32_t>(regs[0]) < 0x80000004)
            return "unknown";

        char brand[49]{};
        for (int i = 0; i < 3; ++i)
        {
            __cpuid(regs, 0x80000002 + i);
            memcpy(brand + i * sizeof(regs), regs, sizeof(regs));
        }

        return Trim(brand);
    }

    void LogAdapters()
    {
        std::vector<std::string> seen;

        for (DWORD i = 0;; ++i)
        {
            DISPLAY_DEVICEA device{ sizeof(device) };
            if (!EnumDisplayDevicesA(nullptr, i, &device, 0))
                break;

            // Each monitor reports its adapter, so track every adapter seen to remove duplicates
            if (std::find(seen.begin(), seen.end(), device.DeviceString) != seen.end())
                continue;

            seen.emplace_back(device.DeviceString);
            spdlog::info("GPU {}: {}{}", seen.size(), device.DeviceString,
                (device.StateFlags & DISPLAY_DEVICE_PRIMARY_DEVICE) ? " (primary)" : "");
        }

        if (seen.empty())
            spdlog::warn("GPU: EnumDisplayDevices returned nothing");
    }
}

void Logging::Initialize()
{
    try
    {
#ifdef ENHANCED_DEBUG
        // Open a console for debug builds so UnrealScript Log() calls and our own
        // spdlog output are visible live instead of only in the file after the fact
        AllocConsole();
        SetConsoleTitleW(L"" APP_NAME " Debug Log");
        FILE* dummy;
        freopen_s(&dummy, "CONOUT$", "w", stdout);

        // Save the previous log before writing the new one, so the window has history
        std::ifstream old(sAsiPath / (APP_NAME ".log"), std::ios::binary | std::ios::ate);
        if (old)
        {
            auto size = static_cast<size_t>(old.tellg());
            old.seekg(0);
            std::string content(size, '\0');
            old.read(content.data(), size);
            fwrite(content.data(), 1, content.size(), stdout);
        }
#endif

        std::vector<spdlog::sink_ptr> sinks{
            std::make_shared<spdlog::sinks::basic_file_sink_mt>((sAsiPath / (APP_NAME ".log")).string(), true)
        };
#ifdef ENHANCED_DEBUG
        sinks.push_back(std::make_shared<spdlog::sinks::stdout_sink_mt>());
#endif

        auto logger = std::make_shared<spdlog::logger>(APP_NAME, sinks.begin(), sinks.end());
        spdlog::set_default_logger(logger);
        spdlog::set_pattern("[%H:%M:%S.%e] [%l] %v");
        spdlog::flush_on(spdlog::level::info);
    }
    catch (const spdlog::spdlog_ex&)
    {
    }
}

void Logging::LogSystemInfo()
{
    SYSTEMTIME now{};
    GetLocalTime(&now);

    spdlog::info("Starting " APP_NAME " v" APP_STRING " at {:04}-{:02}-{:02} {:02}:{:02}:{:02}",
        now.wYear, now.wMonth, now.wDay, now.wHour, now.wMinute, now.wSecond);

    wchar_t module[MAX_PATH]{};
    GetModuleFileNameW(baseModule, module, MAX_PATH);
    spdlog::info("ASI: {} (base 0x{:08X})",
        std::filesystem::path(module).lexically_proximate(sExePath).string(),
        reinterpret_cast<uintptr_t>(baseModule));

    auto game = FileVersion(sExePath / sExeName);
    spdlog::info("Game: {}{} (base 0x{:08X})", sExeName,
        game.empty() ? std::string() : " " + game,
        reinterpret_cast<uintptr_t>(GetModuleHandleW(nullptr)));

    spdlog::info("Path: {}", sExePath.string());

    BOOL wow64 = FALSE;
    IsWow64Process(GetCurrentProcess(), &wow64);

    auto host = HostVersion();
    spdlog::info("OS: {} {}{}", OSVersion(), wow64 ? "64-bit" : "32-bit",
        host.empty() ? std::string() : " - " + host);
    LogShimmedVersion();

    SYSTEM_INFO system{};
    GetNativeSystemInfo(&system);
    spdlog::info("CPU: {} ({} threads)", CPUName(), system.dwNumberOfProcessors);

    MEMORYSTATUSEX memory{ sizeof(memory) };
    GlobalMemoryStatusEx(&memory);
    spdlog::info("RAM: {:.1f} GB", memory.ullTotalPhys / 1073741824.0);

    LogAdapters();
}
