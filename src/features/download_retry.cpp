#include "stdafx.h"
#include "common.hpp"
#include "feature.hpp"

static constexpr bool   bDownloadRetry  = true;
static constexpr int    iHTTPAttempts   = 3;
static constexpr double fConnectTimeout = 5.0;

// A single failed HTTP redirect download makes the stock game drop HTTP for the rest of the connection,
// so every later file falls back to the slow channel download. Retry HTTP, fall back for the
// failing file only, and start the next file on HTTP again unless the host can't be reached.
namespace
{
    // UNetConnection
    constexpr ptrdiff_t PackageMap   = 0xc8;
    constexpr ptrdiff_t DownloadInfo = 0x4bac;

    // UPackageMap
    constexpr ptrdiff_t PackageList = 0x2c;

    // FDownloadInfo
    constexpr ptrdiff_t ClassName        = 0x4;
    constexpr int       DownloadInfoSize = 0x20;

    constexpr int PackageInfoSize = 0x44;

    struct TArray { uint8_t* Data; int Num; int Max; };

    SafetyHookInline shNotifyReceivedFile{};
    SafetyHookInline shReceiveFile{};

    // Filled in by IpDrv's static initializers, which have not run yet when the feature does
    void** ppHTTPDownloadClass = nullptr;

    const wchar_t* (__cdecl* LocalizeError)(const wchar_t*, const wchar_t*, const wchar_t*) = nullptr;

    int  method = 0;
    int  tries  = 0;
    bool bRetry = false;

    std::string Narrow(uint8_t* fstring)
    {
        auto data = *reinterpret_cast<const wchar_t**>(fstring);
        return std::filesystem::path(data ? data : L"").string();
    }

    void Retry(uint8_t* connection, int packageIndex)
    {
        auto& downloadInfo = *reinterpret_cast<TArray*>(connection + DownloadInfo);

        // ReceiveFile always starts the first download method, so it is shown the array from
        // the one we want instead
        downloadInfo.Data += method * DownloadInfoSize;
        downloadInfo.Num  -= method;
        bRetry = true;
        shReceiveFile.thiscall<void>(connection, packageIndex);
        bRetry = false;
        downloadInfo.Data -= method * DownloadInfoSize;
        downloadInfo.Num  += method;
    }

    void __fastcall ReceiveFile(void* self, void* edx, int packageIndex)
    {
        // Stock only gets here to start a file from scratch, so each new file tries HTTP again
        if (!bRetry)
            method = tries = 0;

        shReceiveFile.thiscall<void>(self, packageIndex);
    }

    void __fastcall NotifyReceivedFile(void* self, void* edx, uint8_t* connection, int packageIndex, const wchar_t* error, int skipped)
    {
        auto& downloadInfo = *reinterpret_cast<TArray*>(connection + DownloadInfo);

        // A ChannelDownload that cannot open its channel fails inside Retry, where stock already
        // sees only the methods that are left
        if (*error && !bRetry)
        {
            auto entry   = downloadInfo.Data + method * DownloadInfoSize;
            auto package = *reinterpret_cast<uint8_t**>(*reinterpret_cast<uint8_t**>(connection + PackageMap) + PackageList) + packageIndex * PackageInfoSize;

            spdlog::warn("DownloadRetry: {} failed over {} (attempt {}): {}",
                         Narrow(package), Narrow(entry + ClassName), tries + 1, std::filesystem::path(error).string());

            if (*reinterpret_cast<void**>(entry) == *ppHTTPDownloadClass)
            {
                if (++tries < iHTTPAttempts)
                    return Retry(connection, packageIndex);

                // An unreachable host would make every remaining file wait out the same attempts, so
                // let stock drop HTTP for the rest of this connection
                if (method == 0 && wcscmp(error, LocalizeError(L"ConnectionFailed", L"Engine", nullptr)) == 0)
                    return shNotifyReceivedFile.thiscall<void>(self, connection, packageIndex, error, skipped);
            }

            if (method + 1 < downloadInfo.Num)
            {
                method++;
                tries = 0;
                return Retry(connection, packageIndex);
            }

            // Stock would drop the first method and run the rest again, repeating a channel
            // download that may have just spent minutes failing
            auto num = std::exchange(downloadInfo.Num, 1);
            shNotifyReceivedFile.thiscall<void>(self, connection, packageIndex, error, skipped);
            downloadInfo.Num = num;
            return;
        }

        shNotifyReceivedFile.thiscall<void>(self, connection, packageIndex, error, skipped);
    }
}

FEATURE(IpDrv, DownloadRetry)
{
    if (!bDownloadRetry)
        return;

    auto engine = GetModuleHandleW(L"Engine");
    auto ipDrv  = GetModuleHandleW(L"IpDrv");

    // UNetPendingLevel::NotifyReceivedFile is only reached through its FNetworkNotify vtable
    auto notifyReceivedFile = FindModulePattern(engine, { "55 8B EC 6A FF 68 ? ? ? ? 64 A1 00 00 00 00 50 64 89 25 00 00 00 00 83 EC 1C 53 56 8B 75 0C 57 8B 7D 08 8B D9 8B 8F C8 00 00 00" });
    auto receiveFile = GetProcAddress(engine, "?ReceiveFile@UNetConnection@@QAEXH@Z");

    // UHTTPDownload::Tick polls connect() with no except set, so a refused connection is never
    // seen and always waits out the full timeout
    auto timeout = FindModulePattern(ipDrv, { "DC A6 F0 04 00 00 DC 1D ? ? ? ? DF E0 F6 C4 41" });

    ppHTTPDownloadClass = reinterpret_cast<void**>(GetProcAddress(ipDrv, "autoclassUHTTPDownload"));
    LocalizeError       = reinterpret_cast<decltype(LocalizeError)>(GetProcAddress(GetModuleHandleW(L"Core"), "?LocalizeError@@YAPBGPBG00@Z"));

    if (notifyReceivedFile.empty() || !receiveFile || timeout.empty() || !ppHTTPDownloadClass || !LocalizeError)
    {
        spdlog::error("DownloadRetry: NotifyReceivedFile {}, ReceiveFile {}, connect timeout {}, HTTPDownload class {}, LocalizeError {}",
                      !notifyReceivedFile.empty(), (void*)receiveFile, !timeout.empty(), (void*)ppHTTPDownloadClass, (void*)LocalizeError);
        return;
    }

    shNotifyReceivedFile = safetyhook::create_inline(notifyReceivedFile.get_first(), NotifyReceivedFile);
    shReceiveFile        = safetyhook::create_inline(receiveFile, ReceiveFile);
    injector::WriteMemory(timeout.get_first(8), &fConnectTimeout, true);
    spdlog::info("DownloadRetry: {} HTTP attempts per file, {}s connect timeout", iHTTPAttempts, fConnectTimeout);
}
