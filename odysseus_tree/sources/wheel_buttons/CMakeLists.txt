cmake_minimum_required(VERSION 3.21.1)

project(wheel_buttons LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_BUILD_TYPE Debug)
set(CMAKE_CXX_FLAGS_DEBUG "-g -O0")

set(PROJECT_SOURCES
    src/main.cpp

    src/util/logging.h
    src/util/logging.cpp
    
    src/connection/unix_socket_client.h
    src/connection/unix_socket_client.cpp
    src/connection/config.h
)

add_executable(wheel_buttons ${PROJECT_SOURCES})

target_include_directories(wheel_buttons PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)