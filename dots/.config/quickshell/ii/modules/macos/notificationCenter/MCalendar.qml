pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.modules.common
import qs.modules.macos.looks

Item {
    id: root

    readonly property var locale: Qt.locale(Config.options?.calendar.locale ?? "en-GB")
    readonly property date today: clock.date
    readonly property int year: today.getFullYear()
    readonly property int month: today.getMonth()
    readonly property int firstWeekday: locale.firstDayOfWeek
    readonly property int leading: (new Date(year, month, 1).getDay() - firstWeekday + 7) % 7
    readonly property int daysInMonth: new Date(year, month + 1, 0).getDate()

    property real cellSize: 24

    implicitWidth: cellSize * 7
    implicitHeight: monthLabel.height + 4 + header.height + 2 + grid.height

    SystemClock {
        id: clock
        precision: SystemClock.Hours
    }

    MText {
        id: monthLabel
        text: root.locale.standaloneMonthName(root.month, Locale.LongFormat).toUpperCase()
        font.pixelSize: Looks.font.size.small
        emphasized: true
        color: Looks.colors.red
    }

    Row {
        id: header
        anchors.top: monthLabel.bottom
        anchors.topMargin: 4

        Repeater {
            model: 7

            MText {
                required property int index

                width: root.cellSize
                horizontalAlignment: Text.AlignHCenter
                text: root.locale.dayName((root.firstWeekday + index) % 7, Locale.NarrowFormat)
                font.pixelSize: Looks.font.size.tiny
                color: Looks.colors.secondary
            }
        }
    }

    Grid {
        id: grid
        anchors.top: header.bottom
        anchors.topMargin: 2
        columns: 7

        Repeater {
            model: root.leading + root.daysInMonth

            Item {
                required property int index

                readonly property int day: index - root.leading + 1
                readonly property bool isToday: day === root.today.getDate()

                width: root.cellSize
                height: root.cellSize

                Rectangle {
                    visible: parent.isToday
                    anchors.centerIn: parent
                    width: root.cellSize - 4
                    height: width
                    radius: width / 2
                    color: Looks.colors.red
                }

                MText {
                    visible: parent.day > 0
                    anchors.centerIn: parent
                    text: parent.day
                    font.pixelSize: Looks.font.size.small
                    color: parent.isToday ? "#ffffff" : Looks.colors.primary
                }
            }
        }
    }
}
