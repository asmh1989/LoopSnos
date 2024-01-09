cmake_minimum_required(VERSION 3.16)

project(LoopSnos VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.2 REQUIRED COMPONENTS  Charts Quick QuickControls2 WebSockets SerialPort)

add_subdirectory(Qt-AES)

#qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appLoopSnos
    src/main.cpp
)

#set_source_files_properties(Database.qml PROPERTIES
#    QT_QML_SINGLETON_TYPE TRUE
#)

qt_add_qml_module(appLoopSnos
    URI LoopSnos
    VERSION 1.0
    SOURCES src/fileio.h src/fileio.cpp
    SOURCES src/qmlemsocket.h src/qmlemsocket.cpp
    SOURCES src/model.h
    SOURCES src/utils.h src/utils.cpp

    RESOURCES images.qrc
    SOURCES src/TextFieldDoubleValidator.h
    SOURCES src/syssettings.h src/syssettings.cpp

 QML_FILES AirBagPage.qml EmSocketManager.qml
    EventBus.qml
    HomePage.qml
    SensorsPage.qml
    Database.qml
    SnoView.qml
    Toast.qml
    ToastManager.qml
    view/GrayLabel.qml
    view/MyInput.qml
    Main.qml
    common.js
    DataAnalysisPage.qml
    CurveAnalysisPage.qml
    view/AutoYChartView.qml
    LoopPage.qml
)

# configure_file(${CMAKE_SOURCE_DIR}/config/sensors.json ${CMAKE_BINARY_DIR}/config/sensors.json COPYONLY)


# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appLoopSnos PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appLoopSnos
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appLoopSnos
    PUBLIC Qt6::QuickControls2
    Qt6::Quick
    Qt6::WebSockets
    Qt6::Charts
    Qt6::SerialPort
    QtAES
)

include(GNUInstallDirs)
install(TARGETS appLoopSnos
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
