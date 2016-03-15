project(Examples)

cmake_minimum_required(VERSION 3.1)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib;${CppWrapper_DIR}/../")
list(APPEND CMAKE_CXX_FLAGS "-std=c++11")

find_package(Qt5Quick)
find_package(Qt5Core)
find_package(Qt5Widgets)
find_package(CppWrapper)

add_library(qml_wrapper SHARED wrap_qml.hpp wrap_qml.cpp ${MOC_BUILT_SOURCES} ${UI_BUILT_SOURCES})
target_link_libraries(qml_wrapper Qt5::Core Qt5::Quick Qt5::Widgets CppWrapper::cpp_wrapper)

install(TARGETS
  qml_wrapper
LIBRARY DESTINATION lib)
