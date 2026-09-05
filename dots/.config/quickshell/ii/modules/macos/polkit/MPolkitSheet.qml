pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.macos.controls
import qs.modules.macos.looks

Item {
    id: root

    readonly property bool hideResponse: !(PolkitService.flow?.responseVisible ?? false)
    readonly property string appIcon: PolkitService.flow?.iconName ?? ""
    readonly property real contentInset: 16
    readonly property real textInset: 6
    readonly property real topInset: 20
    readonly property real bottomInset: 16
    readonly property real iconSize: 72
    readonly property real buttonWidth: 110
    readonly property real buttonGap: 8
    readonly property color fieldColor: Looks.dark ? "#73000000" : "#d9ffffff"

    function submit(): void {
        PolkitService.submit(input.text);
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape)
            PolkitService.cancel();
    }

    Component.onCompleted: Qt.callLater(input.forceActiveFocus)

    Connections {
        target: PolkitService

        function onInteractionAvailableChanged() {
            if (!PolkitService.interactionAvailable)
                return;
            input.text = "";
            input.forceActiveFocus();
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#66000000"
        opacity: 0
        Component.onCompleted: opacity = 1

        Behavior on opacity {
            NumberAnimation {
                duration: Looks.animation.fast
                easing.type: Easing.OutCubic
            }
        }
    }

    MGlassBackdrop {
        id: backdrop
        panelWidth: root.width
        panelHeight: root.height
    }

    MGlass {
        id: sheet
        backdrop: backdrop
        anchors.centerIn: parent
        width: 260
        height: column.implicitHeight + root.topInset + root.bottomInset
        scale: 0.94
        opacity: 0
        Component.onCompleted: {
            scale = 1;
            opacity = 1;
        }

        Behavior on scale {
            NumberAnimation {
                duration: Looks.animation.fast
                easing.type: Easing.OutCubic
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Looks.animation.fast
                easing.type: Easing.OutCubic
            }
        }

        Column {
            id: column
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                topMargin: root.topInset
                leftMargin: root.contentInset
                rightMargin: root.contentInset
            }
            spacing: 0

            Item {
                x: root.textInset
                width: root.iconSize
                height: root.iconSize

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: Looks.colors.primary
                    antialiasing: true

                    MSymbol {
                        anchors.centerIn: parent
                        symbol: "lock.fill"
                        width: 30
                        height: 40
                        color: Looks.dark ? "#000000" : "#ffffff"
                    }
                }

                Rectangle {
                    anchors {
                        right: parent.right
                        bottom: parent.bottom
                    }
                    visible: root.appIcon.length > 0
                    width: 28
                    height: 28
                    radius: width / 2
                    color: Looks.accent
                    antialiasing: true

                    IconImage {
                        anchors.centerIn: parent
                        implicitSize: 20
                        source: Quickshell.iconPath(root.appIcon, "image-missing")
                        smooth: true
                    }
                }
            }

            Item {
                width: 1
                height: 34
            }

            MText {
                x: root.textInset
                width: parent.width - root.textInset * 2
                text: PolkitService.cleanMessage
                font.pixelSize: Looks.font.style.title3.size
                emphasized: true
                color: Looks.colors.primary
                wrapMode: Text.Wrap
                lineHeight: 20
                lineHeightMode: Text.FixedHeight
            }

            Item {
                width: 1
                height: 6
            }

            MText {
                x: root.textInset
                width: parent.width - root.textInset * 2
                text: Translation.tr("Enter your password to continue.")
                font.pixelSize: Looks.font.style.body.size
                color: Looks.colors.primary
                wrapMode: Text.Wrap
                lineHeight: 20
                lineHeightMode: Text.FixedHeight
            }

            Item {
                width: 1
                height: 32
            }

            Rectangle {
                width: parent.width
                height: 33
                radius: Looks.radius.normal
                color: root.fieldColor
                border.width: 1
                border.color: Looks.colors.quinary
                antialiasing: true

                MText {
                    anchors {
                        fill: parent
                        leftMargin: root.textInset
                    }
                    verticalAlignment: Text.AlignVCenter
                    text: Quickshell.env("USER")
                    font.pixelSize: Looks.font.style.title3.size
                    color: Looks.colors.primary
                }
            }

            Item {
                width: 1
                height: 14
            }

            Rectangle {
                width: parent.width
                height: 33
                radius: Looks.radius.normal
                color: root.fieldColor
                border.width: input.activeFocus ? 2 : 1
                border.color: input.activeFocus ? Looks.accent : Looks.colors.quinary
                antialiasing: true

                TextInput {
                    id: input
                    anchors {
                        fill: parent
                        leftMargin: root.textInset
                        rightMargin: root.textInset
                    }
                    verticalAlignment: Text.AlignVCenter
                    focus: true
                    enabled: PolkitService.interactionAvailable
                    echoMode: root.hideResponse ? TextInput.Password : TextInput.Normal
                    passwordCharacter: "•"
                    font.family: Looks.font.text
                    font.pixelSize: Looks.font.style.title3.size
                    color: Looks.colors.primary
                    selectionColor: Looks.accent
                    selectedTextColor: "#ffffff"
                    selectByMouse: true
                    clip: true
                    onAccepted: root.submit()

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape)
                            PolkitService.cancel();
                    }

                    MText {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        visible: input.text.length === 0
                        text: PolkitService.cleanPrompt
                        font.pixelSize: Looks.font.style.title3.size
                        color: Looks.colors.secondary
                    }
                }
            }

            Item {
                width: 1
                height: 24
            }

            Row {
                spacing: root.buttonGap

                MPushButton {
                    controlHeight: Looks.control.large
                    minimumWidth: root.buttonWidth
                    label: Translation.tr("Cancel")
                    onClicked: PolkitService.cancel()
                }

                MPushButton {
                    controlHeight: Looks.control.large
                    minimumWidth: root.buttonWidth
                    label: Translation.tr("Continue")
                    prominent: true
                    opacity: PolkitService.interactionAvailable ? 1 : 0.4
                    onClicked: {
                        if (PolkitService.interactionAvailable)
                            root.submit();
                    }
                }
            }
        }
    }

}
