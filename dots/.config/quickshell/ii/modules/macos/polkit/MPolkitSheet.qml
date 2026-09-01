pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.macos.looks

Item {
    id: root

    readonly property bool hideResponse: !(PolkitService.flow?.responseVisible ?? false)
    readonly property string appIcon: PolkitService.flow?.iconName ?? ""
    readonly property real textInset: 10
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
        width: 320
        height: column.implicitHeight + 49
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
                topMargin: 30
                leftMargin: 19
                rightMargin: 20
            }
            spacing: 0

            Item {
                x: root.textInset
                width: 44
                height: 44

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: Looks.colors.primary
                    antialiasing: true

                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "lock"
                        iconSize: 26
                        fill: 1
                        color: Looks.dark ? "#000000" : "#ffffff"
                    }
                }

                Rectangle {
                    anchors {
                        right: parent.right
                        bottom: parent.bottom
                    }
                    visible: root.appIcon.length > 0
                    width: 22
                    height: 22
                    radius: width / 2
                    color: Looks.accent
                    antialiasing: true

                    IconImage {
                        anchors.centerIn: parent
                        implicitSize: 16
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
                font.pixelSize: Looks.font.size.large
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
                font.pixelSize: Looks.font.size.medium
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
                    font.pixelSize: Looks.font.size.large
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
                    font.pixelSize: Looks.font.size.large
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
                        font.pixelSize: Looks.font.size.large
                        color: Looks.colors.secondary
                    }
                }
            }

            Item {
                width: 1
                height: 24
            }

            SheetButton {
                width: parent.width
                label: Translation.tr("Continue")
                primary: true
                enabled: PolkitService.interactionAvailable
                onActivated: root.submit()
            }

            Item {
                width: 1
                height: 10
            }

            SheetButton {
                width: parent.width
                label: Translation.tr("Cancel")
                onActivated: PolkitService.cancel()
            }
        }
    }

    component SheetButton: Rectangle {
        id: button

        property string label: ""
        property bool primary: false
        property bool enabled: true

        signal activated

        height: 34
        radius: height / 2
        antialiasing: true
        opacity: button.enabled ? 1 : 0.4
        color: button.primary ? Looks.accent : Looks.colors.quaternary

        MText {
            anchors.centerIn: parent
            text: button.label
            font.pixelSize: Looks.font.size.large
            emphasized: true
            color: button.primary ? "#ffffff" : Looks.colors.primary
        }

        MouseArea {
            anchors.fill: parent
            enabled: button.enabled
            cursorShape: Qt.PointingHandCursor
            onClicked: button.activated()
        }
    }
}
