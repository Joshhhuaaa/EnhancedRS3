#include "stdafx.h"
#include "script.hpp"

namespace
{
    constexpr int FNAME_Find = 0;

    constexpr size_t kObjectOuter    = 0x18;
    constexpr size_t kObjectClass    = 0x24;
    constexpr size_t kFieldName      = 0x20;
    constexpr size_t kFieldSuper     = 0x2c;
    constexpr size_t kFieldNext      = 0x30;
    constexpr size_t kStructChildren = 0x40;
    constexpr size_t kPropertyOffset = 0x4c;
    constexpr size_t kBoolBitMask    = 0x70;

    using FNameCtorFn = void*(__thiscall*)(void* self, const wchar_t* name, int findType);

    FNameCtorFn s_fnameCtor = nullptr;
    bool        s_resolved = false;
    bool        s_failed = false;

    template<typename T>
    T Read(void* base, size_t offset)
    {
        return *reinterpret_cast<T*>(static_cast<uint8_t*>(base) + offset);
    }

    bool Resolve()
    {
        if (s_resolved)
            return true;
        if (s_failed)
            return false;

        // /Zc:wchar_t-: FName ctor mangles wchar_t* as PBG
        if (auto core = GetModuleHandleW(L"Core"))
            s_fnameCtor = reinterpret_cast<FNameCtorFn>(
                GetProcAddress(core, "??0FName@@QAE@PBGW4EFindName@@@Z"));

        if (!s_fnameCtor)
        {
            spdlog::error("[Script] Core.dll FName constructor not found");
            s_failed = true;
            return false;
        }

        s_resolved = true;
        return true;
    }
}

namespace
{
    // The matching UProperty, or nullptr. Callers that only want the storage address go
    // through Script::Field; bools need the property itself for its mask.
    void* FindProperty(void* object, const wchar_t* name)
    {
        if (!object || !Resolve())
            return nullptr;

        int fname = 0;
        s_fnameCtor(&fname, name, FNAME_Find);
        if (!fname)
            return nullptr;

        // UObject::FindObjectField only searches one class's fields. Walk the chain for inherited properties.
        for (void* cls = Read<void*>(object, kObjectClass); cls; cls = Read<void*>(cls, kFieldSuper))
        {
            for (void* field = Read<void*>(cls, kStructChildren); field; field = Read<void*>(field, kFieldNext))
            {
                // Matches functions and states too, so this assumes the caller named a var.
                if (Read<int>(field, kFieldName) == fname)
                    return field;
            }
        }

        return nullptr;
    }
}

void* Script::Field(void* object, const wchar_t* name)
{
    void* prop = FindProperty(object, name);
    return prop ? static_cast<uint8_t*>(object) + Read<uint16_t>(prop, kPropertyOffset) : nullptr;
}

void* Script::Declaration(void* object, const wchar_t* name)
{
    return FindProperty(object, name);
}

bool Script::GetBool(void* object, const wchar_t* name, bool fallback)
{
    void* prop = FindProperty(object, name);
    if (!prop)
        return fallback;

    auto storage = static_cast<uint8_t*>(object) + Read<uint16_t>(prop, kPropertyOffset);
    return (*reinterpret_cast<uint32_t*>(storage) & Read<uint32_t>(prop, kBoolBitMask)) != 0;
}

bool Script::SetBool(void* object, const wchar_t* name, bool value)
{
    void* prop = FindProperty(object, name);
    if (!prop)
        return false;

    auto storage = reinterpret_cast<uint32_t*>(static_cast<uint8_t*>(object) + Read<uint16_t>(prop, kPropertyOffset));
    auto mask = Read<uint32_t>(prop, kBoolBitMask);

    if (value)
        *storage |= mask;
    else
        *storage &= ~mask;

    return true;
}

bool Script::IsClass(void* object, const wchar_t* className)
{
    if (!object || !Resolve())
        return false;

    // A class the game never registered resolves to NAME_None, so an unknown name
    // simply misses instead of matching everything.
    int fname = 0;
    s_fnameCtor(&fname, className, FNAME_Find);
    if (!fname)
        return false;

    void* cls = Read<void*>(object, kObjectClass);
    return cls && Read<int>(cls, kFieldName) == fname;
}

bool Script::IsA(void* object, const wchar_t* className)
{
    if (!object || !Resolve())
        return false;

    int fname = 0;
    s_fnameCtor(&fname, className, FNAME_Find);
    if (!fname)
        return false;

    for (void* cls = Read<void*>(object, kObjectClass); cls; cls = Read<void*>(cls, kFieldSuper))
        if (Read<int>(cls, kFieldName) == fname)
            return true;

    return false;
}

bool Script::InPackage(void* object, const wchar_t* packageName)
{
    if (!object || !Resolve())
        return false;

    int fname = 0;
    s_fnameCtor(&fname, packageName, FNAME_Find);
    if (!fname)
        return false;

    while (void* outer = Read<void*>(object, kObjectOuter))
        object = outer;

    return Read<int>(object, kFieldName) == fname;
}
