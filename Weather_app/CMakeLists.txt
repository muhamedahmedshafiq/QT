cmake_minimum_required(VERSION 3.16)
project(Weather_app VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

# ✅ Find BOTH Quick and Network together in ONE line
find_package(Qt6 REQUIRED COMPONENTS Quick Network)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appWeather_app
    main.cpp
    weathermanager.cpp      
    weathermanager.h        
)

qt_add_qml_module(appWeather_app
    URI Weather_app
    QML_FILES
        Main.qml
    RESOURCES
        weather.jpeg
)

set_target_properties(appWeather_app PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

# ✅ Link to the CORRECT target name (appWeather_app, not myapp)
target_link_libraries(appWeather_app
    PRIVATE Qt6::Quick Qt6::Network
)

include(GNUInstallDirs)
install(TARGETS appWeather_app
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
