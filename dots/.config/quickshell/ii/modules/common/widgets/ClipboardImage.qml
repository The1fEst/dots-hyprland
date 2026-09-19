import qs.modules.common
import qs.modules.common.widgets
import qs.services
import qs.modules.common.functions
import Qt5Compat.GraphicalEffects
import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    property string entry
    property real maxWidth
    property real maxHeight
    property bool blur: false
    property string blurText: "Image hidden"

    property string imageDecodePath: Directories.clipboardDecode
    property string imageDecodeFileName: `${entryNumber}`
    property string imageDecodeFilePath: `${imageDecodePath}/${imageDecodeFileName}`
    property string source

    property int entryNumber: {
        if (!root.entry)
            return 0;
        const match = root.entry.match(/^(\d+)\t/);
        return match ? parseInt(match[1]) : 0;
    }
    readonly property int imageWidth: image.sourceSize.width
    readonly property int imageHeight: image.sourceSize.height
    readonly property real scale: {
        if (root.imageWidth <= 0 || root.imageHeight <= 0)
            return 0;
        return Math.min(root.maxWidth / root.imageWidth, root.maxHeight / root.imageHeight, 1);
    }

    color: Appearance.colors.colLayer1
    radius: Appearance.rounding.small
    implicitHeight: imageHeight * scale
    implicitWidth: imageWidth * scale

    Component.onCompleted: {
        decodeImageProcess.running = true;
    }

    Process {
        id: decodeImageProcess
        command: ["bash", "-c", `[ -f ${imageDecodeFilePath} ] || ${Clipboard.binary} decode ${root.entryNumber} > '${imageDecodeFilePath}'`]
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                root.source = imageDecodeFilePath;
            } else {
                console.error("[ClipboardImage] Failed to decode image for entry:", root.entry);
                root.source = "";
            }
        }
    }

    Component.onDestruction: {
        Quickshell.execDetached(["bash", "-c", `[ -f '${imageDecodeFilePath}' ] && rm -f '${imageDecodeFilePath}'`]);
    }

    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            width: image.width
            height: image.height
            radius: root.radius
        }
    }

    StyledImage {
        id: image
        anchors.fill: parent

        source: Qt.resolvedUrl(root.source)
        fillMode: Image.PreserveAspectFit
        antialiasing: true
        asynchronous: true
    }

    Loader {
        id: blurLoader
        active: root.blur
        anchors.fill: image
        sourceComponent: GaussianBlur {
            source: image
            radius: 35
            samples: radius * 2 + 1

            Rectangle {
                anchors.fill: parent
                color: ColorUtils.transparentize(Appearance.colors.colLayer0, 0.5)

                Column {
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    MaterialSymbol {
                        visible: width <= image.width
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "visibility_off"
                        font.pixelSize: 28
                    }
                    StyledText {
                        visible: width <= image.width
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.blurText
                        color: Appearance.colors.colOnSurface
                        font.pixelSize: Appearance.font.pixelSize.smallie
                    }
                }
            }
        }
    }
}
