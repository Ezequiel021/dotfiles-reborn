cmake_minimum_required(VERSION 3.16)
project(quickshell VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Qml Gui)

# C++ sources
set(SOURCES
    delta/StyledRectangle.cpp
    delta/Triangle.cpp
)

set(HEADERS
    delta/triangle.h
)

# Resources
set(QML_RESOURCES
    qml.qrc
)

# Create executable
add_executable(${PROJECT_NAME}
    ${SOURCES}
    ${HEADERS}
    ${QML_RESOURCES}
)

target_include_directories(${PROJECT_NAME} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/delta
)

target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Quick
    Qt6::Qml
    Qt6::Gui
)

# QML import path for design support
set_target_properties(${PROJECT_NAME} PROPERTIES
    QT_QML_IMPORT_PATH "${CMAKE_CURRENT_SOURCE_DIR}"
)
