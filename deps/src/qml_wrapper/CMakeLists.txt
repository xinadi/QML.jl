project(QML)

cmake_minimum_required(VERSION 3.1)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
list(APPEND CMAKE_CXX_FLAGS "-std=c++11")

find_package(Qt5Quick)
find_package(Qt5Core)
find_package(Qt5Widgets)
find_package(CxxWrap)

get_target_property(QtCore_location Qt5::Core LOCATION)
get_filename_component(QtCore_location ${QtCore_location} DIRECTORY)
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib;${CxxWrap_DIR}/../;${QtCore_location}")

if(WIN32)
  add_definitions(-DWIN32_LEAN_AND_MEAN)
  get_filename_component(VC_DIR "${CMAKE_LINKER}" DIRECTORY) # Visual studio dir is 3 levels up from the linker
  get_filename_component(VC_DIR "${VC_DIR}" DIRECTORY)
  get_filename_component(VC_DIR "${VC_DIR}" DIRECTORY)
  get_filename_component(QML_DIR "${CMAKE_SOURCE_DIR}" DIRECTORY) # Go up to the package test dir for QML examples
  get_filename_component(QML_DIR "${QML_DIR}" DIRECTORY)
  get_filename_component(QML_DIR "${QML_DIR}" DIRECTORY)
  set(QML_DIR "${QML_DIR}/test/qml")
  configure_file("${CMAKE_SOURCE_DIR}/cmake/WinDeployQt.cmake" "${CMAKE_BINARY_DIR}/WinDeployQt.cmake")
  configure_file("${CMAKE_SOURCE_DIR}/resources/resources.qrc" "${CMAKE_BINARY_DIR}/resources/resources.qrc" COPYONLY)
  configure_file("${CMAKE_SOURCE_DIR}/resources/qt.conf" "${CMAKE_BINARY_DIR}/resources/qt.conf")
  qt5_add_resources(RESOURCES ${CMAKE_BINARY_DIR}/resources/resources.qrc)
endif(WIN32)

add_library(qml_wrapper SHARED wrap_qml.hpp wrap_qml.cpp ${MOC_BUILT_SOURCES} ${UI_BUILT_SOURCES} ${RESOURCES})
target_link_libraries(qml_wrapper Qt5::Core Qt5::Quick Qt5::Widgets CxxWrap::cxx_wrap)

install(TARGETS
  qml_wrapper
LIBRARY DESTINATION lib
ARCHIVE DESTINATION lib
RUNTIME DESTINATION lib)
if(WIN32)
  install (SCRIPT "${CMAKE_BINARY_DIR}/WinDeployQt.cmake")
endif(WIN32)
