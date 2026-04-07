cmake_minimum_required(VERSION 3.16)

project(Network_project VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

# ✅ Enable AUTOMOC (needed for Q_OBJECT signals/slots)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.8)

# ✅ Added networkcontroller.h and networkcontroller.cpp
qt_add_executable(appNetwork_project
    main.cpp
    networkcontroller.h
    networkcontroller.cpp
)

qt_add_qml_module(appNetwork_project
    URI Network_project
    VERSION 1.0
    QML_FILES
        Main.qml
)

set_target_properties(appNetwork_project PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appNetwork_project
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS appNetwork_project
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)