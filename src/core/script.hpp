#pragma once

// Live read and write of UnrealScript properties by name, resolved through Core.dll's own
// reflection, so it reaches any var on any class whether or not it is config.
//
// Bools are bitfields, so they go through GetBool/SetBool rather than Get<bool>.
namespace Script
{
    // Address of a property's storage inside an object, or nullptr if the object's class
    // has no field by that name. Names a var, not a function.
    void* Field(void* object, const wchar_t* name);

    template<typename T>
    T Get(void* object, const wchar_t* name, T fallback = T{})
    {
        void* field = Field(object, name);
        return field ? *static_cast<T*>(field) : fallback;
    }

    template<typename T>
    bool Set(void* object, const wchar_t* name, T value)
    {
        void* field = Field(object, name);
        if (!field)
            return false;

        *static_cast<T*>(field) = value;
        return true;
    }

    // UnrealScript packs several bools into one dword, so these apply the property's
    // UBoolProperty mask instead of reading or writing the storage directly.
    bool GetBool(void* object, const wchar_t* name, bool fallback = false);
    bool SetBool(void* object, const wchar_t* name, bool value);

    // True when the object's class is exactly this one, not a subclass of it.
    bool IsClass(void* object, const wchar_t* className);

    // True when the object's class is this one or anything derived from it.
    bool IsA(void* object, const wchar_t* className);
}
