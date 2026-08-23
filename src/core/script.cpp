#include "stdafx.h"
#include "script.hpp"

namespace
{
    // FNAME_Find leaves the name table alone, so a name the game never registered
    // resolves to NAME_None and the lookup simply misses.
    constexpr int FNAME_Find = 0;

    // All derived from Core.dll rather than assumed:
    //   UObject::Class      +0x24  UObject::FindObjectField   mov ecx,[esi+0x24]
    //   UField::Name        +0x20  UObject::FindObjectField   cmp [ecx+0x20],eax
    //   UField::SuperField  +0x2c  UStruct::GetInheritanceSuper
    //   UField::Next        +0x30  UStruct::AddCppProperty    mov [edx+0x30],eax
    //   UStruct::Children   +0x3c  UStruct::AddCppProperty    mov eax,[ecx+0x3c]
    //   UProperty::Offset   +0x44  UIntProperty::Link         mov word [esi+0x44],ax
    constexpr size_t kObjectClass    = 0x24;
    constexpr size_t kFieldName      = 0x20;
    constexpr size_t kFieldSuper     = 0x2c;
    constexpr size_t kFieldNext      = 0x30;
    constexpr size_t kStructChildren = 0x3c;
    constexpr size_t kPropertyOffset = 0x44;
    //   UBoolProperty::BitMask +0x54  UBoolProperty::Identical   and eax,[ecx+0x54]
    constexpr size_t kBoolBitMask    = 0x54;

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

        if (auto core = GetModuleHandleW(L"Core"))
            s_fnameCtor = reinterpret_cast<FNameCtorFn>(
                GetProcAddress(core, "??0FName@@QAE@PB_WW4EFindName@@@Z"));

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

        // UObject::FindObjectField hashes one class's own fields only, so an inherited
        // property never resolves through it - Actor is declared on Engine.Player but
        // queried on WinDrv.WindowsViewport. Walk the chain ourselves instead.
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
