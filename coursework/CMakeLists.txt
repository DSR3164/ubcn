cmake_minimum_required(VERSION 3.15)
project(dsp LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

find_package(pybind11 REQUIRED)

pybind11_add_module(dsp dsp.cpp)
target_link_libraries(dsp PRIVATE pybind11::module fftw3)
