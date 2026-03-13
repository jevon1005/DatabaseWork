cmake_minimum_required(VERSION 3.16)

project(RailwaySystem VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS
    Gui
    Qml
    Quick
    QuickControls2
)
find_package(Qt6 REQUIRED COMPONENTS Core)
find_package(Qt6 REQUIRED COMPONENTS Core)
find_package(Qt6 REQUIRED COMPONENTS Core)
find_package(Qt6 REQUIRED COMPONENTS Core)
find_package(Qt6 REQUIRED COMPONENTS Core)
find_package(Qt6 REQUIRED COMPONENTS Core)
find_package(Qt6 REQUIRED COMPONENTS Core)

qt_standard_project_setup(REQUIRES 6.8)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

add_executable(appRailwaySystem
    main.cpp
    images.qrc
    accountmanager.h accountmanager.cpp
    userprofile.h userprofile.cpp
    user.h user.cpp
    admin.h admin.cpp

    city.h city.cpp
    stationmanager.h stationmanager.cpp
    station.h station.cpp
    bookingsystem.h bookingsystem.cpp
    order.h order.cpp
    passenger.h passenger.cpp
    time.h time.cpp
    timetable.h timetable.cpp
    date.h date.cpp
    ordermanager.h ordermanager.cpp
    train.h train.cpp
    trainmanager.h trainmanager.cpp
    passengermanager.h passengermanager.cpp

)

target_link_libraries(appRailwaySystem
    PRIVATE Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2
)
target_link_libraries(appRailwaySystem PRIVATE Qt6::Core)
target_link_libraries(appRailwaySystem PRIVATE Qt6::Core)
target_link_libraries(appRailwaySystem PRIVATE Qt6::Core)
target_link_libraries(appRailwaySystem PRIVATE Qt6::Core)
target_link_libraries(appRailwaySystem PRIVATE Qt6::Core)
target_link_libraries(appRailwaySystem PRIVATE Qt6::Core)
target_link_libraries(appRailwaySystem PRIVATE Qt6::Core)

set_target_properties(appRailwaySystem PROPERTIES
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

install(TARGETS appRailwaySystem
    BUNDLE DESTINATION .
    RUNTIME DESTINATION .
)
