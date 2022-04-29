cmake_minimum_required(VERSION 3.4)
project(fuzzme)

#set(CMAKE_BUILD_TYPE Debug)

set(CMAKE_CXX_STANDARD 11)

add_compile_options(-Wall -Wextra)

option(BUILD_FUZZERS "Build fuzzers" ON)

set(SRC_DIR "${PROJECT_SOURCE_DIR}/src")

add_executable(user ${SRC_DIR}/user.cpp)

if(BUILD_FUZZERS)
    add_subdirectory(fuzz)
endif()

