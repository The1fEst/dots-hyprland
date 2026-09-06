pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.macos.looks

Item {
    id: root

    property color color: "transparent"
    property bool selected: false
    property bool spectrum: false

    signal clicked

    readonly property int wellSize: 24
    readonly property int ringSize: 32
    readonly property int ringWidth: 3

    implicitWidth: root.ringSize
    implicitHeight: root.ringSize

    Rectangle {
        anchors.centerIn: parent
        visible: !root.spectrum
        width: root.wellSize
        height: width
        radius: width / 2
        antialiasing: true
        color: root.color
    }

    Canvas {
        id: wheel
        anchors.centerIn: parent
        visible: root.spectrum
        width: root.wellSize
        height: width

        onPaint: {
            const context = getContext("2d");
            context.reset();

            const radius = width / 2;
            const wheel = context.createConicalGradient(radius, radius, 0);
            for (let step = 0; step <= 12; step++)
                wheel.addColorStop(step / 12, Qt.hsva(step / 12, 0.82, 1, 1));

            context.beginPath();
            context.arc(radius, radius, radius, 0, Math.PI * 2);
            context.fillStyle = wheel;
            context.fill();
        }
    }

    Rectangle {
        anchors.fill: parent
        visible: root.selected
        radius: width / 2
        antialiasing: true
        color: "transparent"
        border.width: root.ringWidth
        border.color: "#979797"
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
