cmake_minimum_required(VERSION 3.0.0)

include(cmake/hunter.cmake) # huntergate

project(ncnn VERSION 2018.03.14)

option(NCNN_OPENMP "openmp support" ON)
option(NCNN_STDIO "load model from external file" ON)
option(NCNN_STRING "plain and verbose string" ON)
option(NCNN_OPENCV "minimal opencv structure emulation" OFF)
option(NCNN_BENCHMARK "print benchmark information for every layer" OFF)
option(NCNN_BUILD_EXAMPLES "build ncnn examples" OFF)
option(NCNN_BUILD_BENCHMARK "build the benchmarks" OFF)
option(NCNN_BUILD_TOOLS "build ncnn tools" OFF)
option(NCNN_LOCAL_TOOLCHAIN "use internal default compiler flags" ON)

if(NCNN_OPENMP)
    find_package(OpenMP) # >= 3.0 for 'collapse'
    if((OpenMP_CXX_FOUND OR OPENMP_FOUND) AND OpenMP_CXX_VERSION_MAJOR GREATER_EQUAL 3.0)
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
    endif()
endif()

if(NCNN_LOCAL_TOOLCHAIN)
  include(cmake/toolchain.cmake)
endif()

set(NCNN_TOP_DIR "${CMAKE_CURRENT_LIST_DIR}")

set(TARGETS_EXPORT_NAME "${PROJECT_NAME}Targets")

add_subdirectory(src)

if(NCNN_BUILD_EXAMPLES)
  add_subdirectory(examples)
endif()

if(NCNN_BUILD_BENCHMARK)
  add_subdirectory(benchmark)
endif()

if(NCNN_BUILD_TOOLS AND NOT ANDROID AND NOT IOS)
  add_subdirectory(tools)
endif()
