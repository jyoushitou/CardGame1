cmake_minimum_required(VERSION 3.15)
project(bridge CXX)

set(CMAKE_CXX_STANDARD 17)

add_library(bridge SHARED
    util.cpp
    window.cpp
    render.cpp
    events.cpp
    edit.cpp
    clipboard.cpp
    config.cpp
    image.cpp
    dialog.cpp
)

target_link_libraries(bridge PRIVATE user32 gdi32 gdiplus dwmapi)

set_target_properties(bridge PROPERTIES
    PREFIX ""
    OUTPUT_NAME "bridge"
    SUFFIX ".dll"
)
