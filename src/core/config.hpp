#pragma once

namespace Config
{
    void Read();

    enum class Kind { Bool, Int, Float };

    class Setting
    {
    protected:
        Setting(const char* section, const char* key, Kind kind, float value);

    public:
        const char* section;
        const char* key;
        Kind        kind;
        float       value;
    };

    struct Value : Setting
    {
        Value(const char* section, const char* key, bool defaultValue)
            : Setting(section, key, Kind::Bool, defaultValue ? 1.0f : 0.0f) {}
        Value(const char* section, const char* key, int32_t defaultValue)
            : Setting(section, key, Kind::Int, static_cast<float>(defaultValue)) {}

        operator int32_t() const { return static_cast<int32_t>(value); }
    };

    struct Float : Setting
    {
        Float(const char* section, const char* key, float defaultValue)
            : Setting(section, key, Kind::Float, defaultValue) {}

        operator float() const { return value; }
    };
}
