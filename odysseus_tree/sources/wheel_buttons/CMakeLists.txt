cmake_minimum_required(VERSION 3.21.1)

project(wheel_buttons LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)

set(PROJECT_SOURCES
    src/main.cpp

    src/util/logging.h
    src/util/logging.cpp
)

add_executable(wheel_buttons ${PROJECT_SOURCES})

target_include_directories(wheel_buttons PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)