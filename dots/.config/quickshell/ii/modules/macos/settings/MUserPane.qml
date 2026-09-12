pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.macos.controls
import qs.modules.macos.looks

Column {
    id: root

    readonly property int avatarSize: 110
    readonly property real avatarGlyphRatio: 0.55
    readonly property int nameGap: 14
    readonly property int headerHeight: 180

    spacing: Looks.settings.formGap

    Item {
        width: parent.width
        height: root.headerHeight

        ClippingRectangle {
            id: avatar
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
            }
            width: root.avatarSize
            height: width
            radius: width / 2
            color: Looks.colors.quaternary
            antialiasing: true

            StyledImage {
                id: portrait
                anchors.fill: parent
                source: UserAccount.iconFile.length > 0 ? `file://${UserAccount.iconFile}` : ""
                sourceSize: Qt.size(avatar.width * 2, avatar.width * 2)
                fillMode: Image.PreserveAspectCrop
            }

            MSymbol {
                anchors.centerIn: parent
                visible: portrait.status !== Image.Ready
                symbol: "person.fill"
                height: parent.height * root.avatarGlyphRatio
                color: Looks.colors.secondary
            }
        }

        MText {
            id: name
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: avatar.bottom
                topMargin: root.nameGap
            }
            text: UserAccount.displayName
            textStyle: Looks.font.style.title3
            emphasized: true
        }

        MText {
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: name.bottom
            }
            visible: UserAccount.email.length > 0
            text: UserAccount.email
            color: Looks.colors.secondary
        }
    }

    MSettingsGroup {
        width: parent.width

        MSettingsRow {
            label: qsTr("Name")

            MTextField {
                text: UserAccount.realName
                placeholder: UserAccount.userName
                onCommitted: value => UserAccount.set("RealName", "s", value)
            }
        }

        MSettingsRow {
            label: qsTr("Username")
            value: UserAccount.userName
        }

        MSettingsRow {
            label: qsTr("Account type")
            value: UserAccount.administrator ? qsTr("Administrator") : qsTr("Standard")
        }

        MSettingsRow {
            label: qsTr("Email address")
            separator: false

            MTextField {
                text: UserAccount.email
                onCommitted: value => UserAccount.set("Email", "s", value)
            }
        }
    }

    MSettingsGroup {
        width: parent.width

        MSettingsRow {
            label: qsTr("Password")
            detail: qsTr("Change the password you use to log in and to unlock the screen.")
            wrapDetail: true
            separator: false

            MPushButton {
                label: qsTr("Change Password…")
                onClicked: Quickshell.execDetached(["bash", "-c", `${Config.options.apps.terminal} passwd`])
            }
        }
    }
}
