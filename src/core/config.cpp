#include "stdafx.h"
#include "common.hpp"
#include "config.hpp"
#include "version.h"

#include <inipp/inipp.h>

namespace
{
    std::vector<Config::Setting*>& List()
    {
        static std::vector<Config::Setting*> list;
        return list;
    }

    std::string Strip(std::string text)
    {
        auto comment = text.find("//");
        if (comment != std::string::npos)
            text.erase(comment);

        auto last = text.find_last_not_of(" \t");
        return last == std::string::npos ? std::string() : text.substr(0, last + 1);
    }

    bool Parse(std::string text, Config::Kind kind, float& out)
    {
        text = Strip(text);
        std::transform(text.begin(), text.end(), text.begin(), ::tolower);

        if (kind == Config::Kind::Bool)
        {
            if (text == "1" || text == "true")  { out = 1.0f; return true; }
            if (text == "0" || text == "false") { out = 0.0f; return true; }
            return false;
        }

        return static_cast<bool>(std::istringstream(text) >> out);
    }

    std::string Format(float value, Config::Kind kind)
    {
        switch (kind)
        {
        case Config::Kind::Bool:  return value != 0.0f ? "1" : "0";
        case Config::Kind::Float: return std::format("{:.6f}", value);
        default:                  return std::to_string(static_cast<int32_t>(value));
        }
    }
}

Config::Setting::Setting(const char* section, const char* key, Kind kind, float value)
    : section(section), key(key), kind(kind), value(value)
{
    List().push_back(this);
}

void Config::Read()
{
    auto path = sAsiPath / (APP_NAME ".ini");
    spdlog::info("Config: {}", path.string());

    inipp::Ini<char> ini;
    {
        std::ifstream file(path);
        if (file)
            ini.parse(file);
        else
            spdlog::warn("Config: not found, using defaults");
    }

    for (auto* setting : List())
    {
        auto& section = ini.sections[setting->section];
        auto  it = section.find(setting->key);

        if (it != section.end())
            Parse(it->second, setting->kind, setting->value);

        spdlog::info("[{}] {} = {}", setting->section, setting->key, Format(setting->value, setting->kind));
    }
}
