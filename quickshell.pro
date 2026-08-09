QT += qml quick gui

CONFIG += c++17
TARGET = quickshell

# Project structure
TEMPLATE = app

# Source files (C++)
SOURCES += \
    $$PWD/delta/StyledRectangle.cpp \
    $$PWD/delta/Triangle.cpp

HEADERS += \
    $$PWD/delta/Triangle.h

# QML files (for Qt Creator awareness)
QML_FILES = \
    $$PWD/shell.qml \
    $$PWD/templates/AnimatedPanel.qml \
    $$PWD/templates/AnimatedPopup.qml \
    $$PWD/templates/StyledRect.qml \
    $$PWD/templates/StyledText.qml \
    $$PWD/theme/Theme.qml \
    $$PWD/tokens/Tokens.qml \
    $$PWD/widgets/bar/Bar.qml \
    $$PWD/widgets/bar/Workspaces.qml \
    $$PWD/widgets/bar/WorkspacesV2.qml \
    $$PWD/widgets/bar/Tags.qml \
    $$PWD/widgets/bar/ClockWidget.qml \
    $$PWD/widgets/bar/Time.qml \
    $$PWD/widgets/bar/System.qml \
    $$PWD/widgets/bar/Title.qml \
    $$PWD/widgets/bar/Tray.qml \
    $$PWD/widgets/bar/TrayIcon.qml \
    $$PWD/widgets/bar/TrayMenu.qml \
    $$PWD/widgets/bar/hardware/Wifi.qml \
    $$PWD/widgets/bar/menus/MenuWindow.qml \
    $$PWD/widgets/control/Panel.qml \
    $$PWD/widgets/control/AppGrid.qml \
    $$PWD/widgets/control/ClockWeather.qml \
    $$PWD/widgets/control/Media.qml \
    $$PWD/widgets/launcher/Launcher.qml \
    $$PWD/widgets/osd/Volume.qml \
    $$PWD/widgets/modules/Wifi.qml \
    $$PWD/widgets/examples/Osd.qml \
    $$PWD/widgets/examples/Panel.qml

OTHER_FILES += \
    $$QML_FILES \
    $$PWD/theme/qmldir \
    $$PWD/tokens/qmldir \
    $$PWD/templates/qmldir \
    $$PWD/theme/Theme.json \
    $$PWD/theme/Themeold \
    $$PWD/widgets/bar/scripts/nmstatus.sh \
    $$PWD/widgets/bar/scripts/sys_status.sh \
    $$PWD/widgets/modules/scan.sh

# Include paths
INCLUDEPATH += \
    $$PWD/delta

# QML import paths (for Qt Creator)
QML_IMPORT_PATH = $$PWD

# QML design support
QML_DESIGNER_IMPORT_PATH = $$PWD

# Resources
RESOURCES += \
    qml.qrc

# Default rules for deployment
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
