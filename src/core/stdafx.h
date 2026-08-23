#pragma once
#define NOMINMAX
#define WIN32_LEAN_AND_MEAN

#include <windows.h>
#include <subauth.h>
#include <stdint.h>

#include <algorithm>
#include <cstdio>
#include <filesystem>
#include <format>
#include <fstream>
#include <functional>
#include <map>
#include <memory>
#include <mutex>
#include <sstream>
#include <string>
#include <string_view>
#include <vector>

#include <injector/injector.hpp>
#include <injector/hooking.hpp>
#include <Hooking.Patterns.h>
#include <safetyhook.hpp>
#include <spdlog/spdlog.h>

#include "callbacks.h"

#ifndef CEXP
#define CEXP extern "C" __declspec(dllexport)
#endif
