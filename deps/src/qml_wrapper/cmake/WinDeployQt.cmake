get_filename_component(VC_DIR "${CMAKE_LINKER}" DIRECTORY)
set(ENV{VCINSTALLDIR} "${VC_DIR}/../../")
execute_process(COMMAND ${QtCore_location}/windeployqt --qmldir "${CMAKE_SOURCE_DIR}../../../test/qml/main.qml" "${CMAKE_INSTALL_PREFIX}/lib/qml_wrapper.dll")
