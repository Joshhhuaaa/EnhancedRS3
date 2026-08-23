#pragma once

// The game loads its packages long after the ASI is in, so a fix has to wait for
// the dll it patches. Pick the module that owns the code you are hooking.
enum class GameModule
{
    Startup,
    Core,
    Engine,
    Fire,
    IpDrv,
    R6Abstract,
    R6Engine,
    R6Game,
    R6GameService,
    R6Weapons,
    D3DDrv,
    WinDrv,
    Window,
    DareAudio,
};

using FeatureFn = void(*)();

struct Feature
{
    Feature(GameModule module, FeatureFn fn);
};

void RegisterFeatures();

#define FEATURE(module, name)                                       \
    static void name();                                             \
    static Feature name##_Feature(GameModule::module, name);        \
    static void name()
