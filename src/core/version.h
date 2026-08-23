#pragma once

#define APP_NAME        "EnhancedRS3"
#define APP_COMPANY     "Joshhhuaaa"
#define APP_COPYRIGHT   "Copyright (c) 2026 Joshhhuaaa"
#define APP_DESCRIPTION "Enhanced RS3"
#define APP_FILENAME    APP_NAME ".asi"

#define VERSION_MAJOR    1
#define VERSION_MINOR    0
#define VERSION_REVISION ""

#define STRINGIFY_(x)   #x
#define STRINGIFY(x)    STRINGIFY_(x)
#define APP_STRING  STRINGIFY(VERSION_MAJOR) "." STRINGIFY(VERSION_MINOR) VERSION_REVISION
#define VERSION_NUMBER  VERSION_MAJOR, VERSION_MINOR, 0, 0
