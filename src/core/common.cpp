#include "stdafx.h"
#include "common.hpp"

void InitPaths()
{
    wchar_t path[MAX_PATH];
    GetModuleFileNameW(GetModuleHandleW(nullptr), path, MAX_PATH);

    auto exe = std::filesystem::path(path);
    sExePath = exe.parent_path();
    sExeName = exe.filename().string();
    if (GetModuleFileNameW(baseModule, path, MAX_PATH))
        sAsiPath = std::filesystem::path(path).parent_path();
    else
        sAsiPath = sExePath;
}

namespace
{
    IMAGE_THUNK_DATA* FindIATEntry(uint8_t* base, const char* targetModule, const char* targetFunction)
    {
        auto dos = reinterpret_cast<IMAGE_DOS_HEADER*>(base);
        auto nt = reinterpret_cast<IMAGE_NT_HEADERS*>(base + dos->e_lfanew);
        auto dir = nt->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT];
        if (!dir.VirtualAddress)
            return nullptr;

        auto imports = reinterpret_cast<IMAGE_IMPORT_DESCRIPTOR*>(base + dir.VirtualAddress);

        for (int i = 0; imports[i].Characteristics; ++i)
        {
            if (_stricmp(reinterpret_cast<const char*>(base + imports[i].Name), targetModule) != 0)
                continue;

            auto orig = reinterpret_cast<IMAGE_THUNK_DATA*>(base + imports[i].OriginalFirstThunk);
            auto thunk = reinterpret_cast<IMAGE_THUNK_DATA*>(base + imports[i].FirstThunk);

            for (; orig->u1.AddressOfData; ++orig, ++thunk)
            {
                if (orig->u1.Ordinal & IMAGE_ORDINAL_FLAG)
                    continue;

                auto byName = reinterpret_cast<IMAGE_IMPORT_BY_NAME*>(base + orig->u1.AddressOfData);
                if (strcmp(reinterpret_cast<const char*>(byName->Name), targetFunction) == 0)
                    return thunk;
            }
        }

        return nullptr;
    }
}

void* Memory::ReadIAT(HMODULE callerModule, const char* targetModule, const char* targetFunction)
{
    auto thunk = FindIATEntry(reinterpret_cast<uint8_t*>(callerModule), targetModule, targetFunction);
    return thunk ? reinterpret_cast<void*>(thunk->u1.Function) : nullptr;
}

bool Memory::WriteIAT(HMODULE callerModule, const char* targetModule, const char* targetFunction, void* detour)
{
    auto thunk = FindIATEntry(reinterpret_cast<uint8_t*>(callerModule), targetModule, targetFunction);
    if (!thunk)
        return false;

    DWORD oldProtect;
    if (!VirtualProtect(&thunk->u1.Function, sizeof(void*), PAGE_READWRITE, &oldProtect))
        return false;

    thunk->u1.Function = reinterpret_cast<ULONG_PTR>(detour);
    VirtualProtect(&thunk->u1.Function, sizeof(void*), oldProtect, &oldProtect);
    return true;
}
