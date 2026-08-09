import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import qs.theme // Ensure your Theme singleton is imported

Item {
    id: appListRoot

    signal appLaunched()
    property var filteredApps: []

    function updateFilter() {
        let allApps = DesktopEntries.applications.values;
        
        if (!allApps) {
            filteredApps = [];
            return;
        }

        let term = searchInput.text.toLowerCase();

        if (term === "") {
            filteredApps = allApps;
        } else {
            filteredApps = allApps.filter(app => 
                app.name.toLowerCase().includes(term) ||
                (app.genericName && app.genericName.toLowerCase().includes(term))
            );
        }
        
        listView.currentIndex = 0;
    }

    Connections {
        target: DesktopEntries
        function onApplicationsChanged() {
            appListRoot.updateFilter();
        }
    }

    Component.onCompleted: updateFilter()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16 // MD3 standard margin
        spacing: 12

        TextField {
            id: searchInput
            Layout.fillWidth: true
            Layout.preferredHeight: 56 // MD3 standard search bar height
            
            placeholderText: "Search apps"
            placeholderTextColor: Theme.on_surface_variant
            color: Theme.on_surface
            font.pixelSize: 16
            
            Component.onCompleted: forceActiveFocus()
            selectByMouse: true

            onTextChanged: appListRoot.updateFilter()

            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Up) {
                    listView.decrementCurrentIndex();
                    event.accepted = true;
                } else if (event.key === Qt.Key_Down) {
                    listView.incrementCurrentIndex();
                    event.accepted = true;
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    if (appListRoot.filteredApps && appListRoot.filteredApps.length > 0) {
                        appListRoot.filteredApps[listView.currentIndex].execute();
                        appListRoot.appLaunched();
                    }
                    event.accepted = true;
                } else if (event.key === Qt.Key_Escape) {
                    if (text !== "") {
                        text = "";
                    } else {
                        appListRoot.appLaunched();
                    }
                    event.accepted = true;
                }
            }

            background: Rectangle {
                color: Theme.surface_variant
                radius: 28 // 56 / 2 creates the MD3 pill shape
                border.color: searchInput.activeFocus ? Theme.primary : "transparent"
                border.width: searchInput.activeFocus ? 2 : 0
            }

            // Left search icon
            IconImage {
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                implicitSize: 20
                source: Quickshell.iconPath("search-symbolic")
                // Note: If IconImage supports color tinting, uncomment the line below:
                // color: Theme.on_surface_variant
            }

            leftPadding: 56 
            rightPadding: 48 

            // Right clear button
            MouseArea {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 48
                visible: searchInput.text !== ""
                cursorShape: Qt.PointingHandCursor
                
                onClicked: searchInput.text = ""

                IconImage {
                    anchors.centerIn: parent
                    implicitSize: 20
                    source: Quickshell.iconPath("edit-clear-symbolic")
                    opacity: 0.8 // Soften the icon slightly
                    // color: Theme.on_surface_variant
                }
            }
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 4 // Tighter spacing so the selection backgrounds flow nicely
            clip: true

            model: appListRoot.filteredApps

            delegate: Component {
                Item {
                    width: ListView.view.width
                    height: 72 // MD3 standard list item height
                    
                    property bool isSelected: ListView.view.currentIndex === index
                    property bool isHovered: mouseArea.containsMouse

                    Rectangle {
                        anchors.fill: parent
                        // A slight margin so the highlight doesn't touch the very edge of the list
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        radius: 16 
                        
                        // MD3 state layer logic
                        color: (isSelected || isHovered) ? Theme.secondary_container : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            spacing: 16

                            IconImage {
                                Layout.preferredWidth: 48
                                Layout.preferredHeight: 48
                                Layout.alignment: Qt.AlignVCenter
                                source: Quickshell.iconPath(modelData.icon)
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 2

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.name
                                    // Match text color to the background container
                                    color: (isSelected || isHovered) ? Theme.on_secondary_container : Theme.on_surface
                                    font.bold: true
                                    font.pixelSize: 16
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.comment ? modelData.comment : "Application"
                                    color: (isSelected || isHovered) ? Theme.on_secondary_container : Theme.on_surface_variant
                                    opacity: (isSelected || isHovered) ? 0.9 : 1.0
                                    font.pixelSize: 14
                                    elide: Text.ElideRight
                                }
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            
                            onEntered: ListView.view.currentIndex = index
                            
                            onClicked: {
                                modelData.execute();
                                appListRoot.appLaunched();
                            }
                        }
                    }
                }
            }
        }
    }
}