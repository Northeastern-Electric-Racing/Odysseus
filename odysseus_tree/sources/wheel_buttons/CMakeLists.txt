cmake_minimum_required(VERSION 3.21.1)

project(wheel_buttons LANGUAGES C)

set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Collect all source files
file(GLOB SOURCES "${PROJECT_SOURCE_DIR}/src/*.c")

# Create executable FIRST
add_executable(${PROJECT_NAME} ${SOURCES})

# THEN attach include directories
target_include_directories(${PROJECT_NAME}
    PRIVATE ${PROJECT_SOURCE_DIR}/inc
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE gpiod
)

install(TARGETS ${PROJECT_NAME} DESTINATION bin)
