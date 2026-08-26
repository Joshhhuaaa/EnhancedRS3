#pragma once

inline HMODULE baseModule = nullptr;
inline std::filesystem::path sExePath;
inline std::string sExeName;
inline std::filesystem::path sAsiPath;
inline bool bEditor = false;

// Tracks whether the game window currently owns mouse input
inline bool bInputFocus = false;

void InitPaths();

// Retail and the digital release need different signatures often enough to be worth
// passing both. Returns the first one that hits.
inline hook::pattern FindModulePattern(HMODULE module, std::initializer_list<std::string_view> patterns)
{
    for (auto& pattern : patterns)
    {
        auto found = hook::module_pattern(module, pattern);
        if (!found.empty())
            return found;
    }

    return hook::module_pattern(module, *patterns.begin());
}

namespace Memory
{
    void* ReadIAT(HMODULE callerModule, const char* targetModule, const char* targetFunction);
    bool  WriteIAT(HMODULE callerModule, const char* targetModule, const char* targetFunction, void* detour);
}
