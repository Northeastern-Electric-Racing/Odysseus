cmake_minimum_required(VERSION 3.21.1)

project(wheel_buttons LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)

set(PROJECT_SOURCES
    src/main.cpp
)

add_executable(wheel_buttons src/main.cpp)