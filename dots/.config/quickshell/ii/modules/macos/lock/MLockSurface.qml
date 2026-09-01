pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.services
import qs.modules.common
import qs.modules.common.panels.lock
import qs.modules.common.widgets
import qs.modules.macos.looks

MouseArea {
    id: root

    required property LockContext context

    property string displayName: SystemInfo.username
    readonly property bool blurred: Config.options.lock.blur.enable
    readonly property string hint: root.context.fingerprintsConfigured ? Translation.tr("Touch ID or Enter Password") : Translation.tr("Enter Password")
    readonly property real avatarSize: Math.round(root.height * 0.049)

    function focusField(): void {
        input.forceActiveFocus();
    }

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton
    onPressed: root.focusField()
    onPositionChanged: root.focusField()

    Component.onCompleted: {
        root.focusField();
        fullNameProc.running = true;
    }

    Connections {
        target: root.context

        function onShouldReFocus() {
            root.focusField();
        }
    }

    // The login name is what the system knows; macOS shows the person's name. Asking the
    // shell who it is avoids racing SystemInfo, which fills in its username later.
    Process {
        id: fullNameProc
        command: ["bash", "-c", `getent passwd "$(id -un)" | cut -d: -f5 | cut -d, -f1`]
        stdout: StdioCollector {
            id: fullNameCollector
            onStreamFinished: {
                const name = fullNameCollector.text.trim();
                if (name.length > 0)
                    root.displayName = name;
            }
        }
    }

    Keys.onPressed: event => {
        root.context.resetClearTimer();
        if (event.key === Qt.Key_Escape)
            root.context.currentText = "";
        root.focusField();
    }

    Item {
        id: backdrop
        anchors.fill: parent

        Image {
            id: wallpaper
            anchors.fill: parent
            visible: !root.blurred
            source: Config.options.background.wallpaperPath
            fillMode: Image.PreserveAspectCrop
            cache: true
            asynchronous: true
        }

        MultiEffect {
            anchors.fill: parent
            visible: root.blurred
            source: wallpaper
            scale: Config.options.lock.blur.extraZoom
            blurEnabled: true
            blurMax: 64
            blur: 1
        }

        Rectangle {
            id: scrim
            anchors.fill: parent
            color: "#26000000"
        }
    }

    // What the glass refracts is the finished background, scrim included, so the clock
    // sits in the same light as everything around it.
    ShaderEffectSource {
        id: backdropSharp
        visible: false
        live: true
        sourceItem: backdrop
        width: root.width
        height: root.height
    }

    Item {
        id: backdropBlur
        anchors.fill: parent
        visible: false
        layer.enabled: true

        MultiEffect {
            anchors.fill: parent
            source: backdropSharp
            blurEnabled: true
            blurMax: Looks.glass.blurMax
            blur: Looks.glass.blur
        }
    }

    // The password field flattens the wallpaper far harder than the glass refracts it.
    Item {
        id: fieldPlate
        anchors.fill: parent
        visible: false
        layer.enabled: true

        MultiEffect {
            anchors.fill: parent
            source: backdropSharp
            blurEnabled: true
            blurMax: 96
            blur: 1
        }
    }


    Row {
        anchors {
            right: parent.right
            top: parent.top
            rightMargin: 22
            topMargin: 16
        }
        spacing: 12

        Row {
            anchors.verticalCenter: parent.verticalCenter
            visible: HyprlandXkb.currentLayoutCode.length > 0
            spacing: 5

            MText {
                anchors.verticalCenter: parent.verticalCenter
                text: HyprlandXkb.currentLayoutCode.toUpperCase()
                color: "#ffffff"
            }

            MaterialSymbol {
                anchors.verticalCenter: parent.verticalCenter
                text: "keyboard"
                iconSize: 18
                color: "#ffffff"
            }
        }

        MaterialSymbol {
            anchors.verticalCenter: parent.verticalCenter
            visible: Battery.available
            text: Battery.isCharging ? "battery_charging_full" : "battery_full"
            iconSize: 18
            color: Battery.isLow && !Battery.isCharging ? Looks.colors.red : "#ffffff"
        }

        MaterialSymbol {
            anchors.verticalCenter: parent.verticalCenter
            text: Network.materialSymbol
            iconSize: 18
            color: "#ffffff"
        }
    }

    // Everything is sized off the screen height, the way the macOS lock scales.
    Column {
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: Math.round(parent.height * 0.09)
        }
        // The padding each glass text carries for its field is invisible, so the gap the
        // layout should keep is measured between the letters and the padding taken back.
        spacing: Math.round(root.height * 0.0043) - date.pad - clock.pad

        MGlassText {
            id: date
            anchors.horizontalCenter: parent.horizontalCenter
            backdrop: backdropSharp
            backdropBlur: backdropBlur
            text: DateTime.longDate
            display: true
            emphasized: true
            font.pixelSize: Math.round(root.height * 0.033)
        }

        MGlassText {
            id: clock
            anchors.horizontalCenter: parent.horizontalCenter
            backdrop: backdropSharp
            backdropBlur: backdropBlur
            text: DateTime.time
            display: true
            font.pixelSize: Math.round(root.height * 0.142)
            font.styleName: "Bold"
        }
    }

    Column {
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: Math.round(parent.height * 0.842)
        }
        spacing: 0

        ClippingRectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.avatarSize
            height: width
            radius: width / 2
            color: "#33ffffff"
            antialiasing: true

            StyledImage {
                id: avatar
                anchors.fill: parent
                source: Directories.userAvatarPathAccountsService
                fallbacks: [Directories.userAvatarPathRicersAndWeirdSystems, Directories.userAvatarPathRicersAndWeirdSystems2]
                sourceSize: Qt.size(152, 152)
                fillMode: Image.PreserveAspectCrop
            }

            MaterialSymbol {
                anchors.centerIn: parent
                visible: avatar.status !== Image.Ready
                text: "person"
                iconSize: Math.round(parent.width * 0.55)
                color: "#ffffff"
            }
        }

        Item {
            width: 1
            height: Math.round(root.avatarSize * 0.24)
        }

        Item {
            id: field
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.round(root.avatarSize * 2.55)
            height: Math.round(root.avatarSize * 0.46)
            opacity: root.context.unlockInProgress ? 0.6 : 1

            readonly property point plateOrigin: {
                root.width;
                root.height;
                field.width;
                field.height;
                return field.mapToItem(root, 0, 0);
            }

            // Not the glass material: inside the macOS pill the wallpaper flattens into
            // an even plate, with no bevel or rim of its own.
            // Until there is a password to hide, macOS names the account instead of
            // offering a field, and the pill only appears once you start typing.
            MText {
                anchors.centerIn: parent
                visible: input.text.length === 0
                text: root.displayName
                font.pixelSize: Math.round(root.avatarSize * 0.32)
                font.styleName: "Bold"
                color: "#ffffff"
            }

            ClippingRectangle {
                id: plate
                anchors.fill: parent
                visible: input.text.length > 0
                radius: field.height / 2
                color: "transparent"
                antialiasing: true

                ShaderEffectSource {
                    live: true
                    sourceItem: fieldPlate
                    sourceRect: Qt.rect(field.plateOrigin.x, field.plateOrigin.y, field.width, field.height)
                    width: field.width
                    height: field.height
                }

                Rectangle {
                    anchors.fill: parent
                    color: "#88000000"
                }
            }

            TextInput {
                id: input
                anchors {
                    fill: parent
                    leftMargin: Math.round(root.avatarSize * 0.13)
                    rightMargin: submit.width + Math.round(root.avatarSize * 0.12)
                }
                verticalAlignment: Text.AlignVCenter
                enabled: !root.context.unlockInProgress
                echoMode: TextInput.Password
                passwordCharacter: "•"
                font.family: Looks.font.text
                font.pixelSize: Math.round(field.height * 0.49)
                color: "#80ffffff"
                selectionColor: Looks.accent
                selectedTextColor: "#ffffff"
                clip: true

                // An empty field shows the placeholder alone; the caret only joins once
                // there is something to point at. TextInput drives cursorVisible off
                // focus, so the delegate is what has to hold back.
                cursorDelegate: Rectangle {
                    visible: input.text.length > 0
                    width: 2
                    radius: 1
                    color: "#50ffffff"
                }

                onTextChanged: root.context.currentText = input.text
                onAccepted: root.context.tryUnlock()

                Connections {
                    target: root.context

                    // The context clears the password on a failed attempt and on its
                    // own timer, so the field follows it rather than the other way
                    // round.
                    function onCurrentTextChanged() {
                        if (input.text !== root.context.currentText)
                            input.text = root.context.currentText;
                    }
                }

            }

            Rectangle {
                id: submit
                anchors {
                    right: parent.right
                    rightMargin: Math.round(root.avatarSize * 0.02)
                    verticalCenter: parent.verticalCenter
                }
                width: Math.round(root.avatarSize * 0.385)
                height: width
                radius: width / 2
                antialiasing: true
                opacity: input.text.length > 0 ? 1 : 0
                color: "transparent"
                border.width: 1.5
                border.color: "#40ffffff"

                MaterialSymbol {
                    anchors.centerIn: parent
                    text: "arrow_forward"
                    iconSize: Math.round(parent.width * 0.6)
                    color: "#40ffffff"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.context.tryUnlock()
                }
            }
        }

        Item {
            width: 1
            height: Math.round(root.avatarSize * 0.17)
        }

        // With the name standing in for the empty field, this line is what says to type.
        MText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.context.showFailure ? Translation.tr("Incorrect password") : root.hint
            font.pixelSize: Math.round(root.height * 0.0106)
            emphasized: true
            color: root.context.showFailure ? Looks.colors.red : "#8cffffff"
        }
    }
}
