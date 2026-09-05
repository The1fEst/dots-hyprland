pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.macos.controls
import qs.modules.macos.looks

Column {
    id: root

    spacing: Looks.settings.formGap

    Item {
        width: parent.width
        height: Looks.settings.accountHeaderHeight

        ClippingRectangle {
            id: avatar
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
            }
            width: Looks.settings.accountAvatarSize
            height: width
            radius: width / 2
            color: Looks.colors.quaternary
            antialiasing: true

            StyledImage {
                id: portrait
                anchors.fill: parent
                source: MAccount.iconFile.length > 0 ? `file://${MAccount.iconFile}` : ""
                sourceSize: Qt.size(avatar.width * 2, avatar.width * 2)
                fillMode: Image.PreserveAspectCrop
            }

            MSymbol {
                anchors.centerIn: parent
                visible: portrait.status !== Image.Ready
                symbol: "person.fill"
                height: parent.height * Looks.settings.accountGlyphRatio
                color: Looks.colors.secondary
            }
        }

        MText {
            id: name
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: avatar.bottom
                topMargin: Looks.settings.accountNameGap
            }
            text: MAccount.displayName
            textStyle: Looks.font.style.title3
            emphasized: true
        }

        MText {
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: name.bottom
            }
            visible: MAccount.email.length > 0
            text: MAccount.email
            color: Looks.colors.secondary
        }
    }

    MSettingsGroup {
        width: parent.width

        MSettingsRow {
            label: qsTr("Name")

            MTextField {
                text: MAccount.realName
                placeholder: MAccount.userName
                onCommitted: value => MAccount.set("RealName", "s", value)
            }
        }

        MSettingsRow {
            label: qsTr("Username")
            value: MAccount.userName
        }

        MSettingsRow {
            label: qsTr("Account type")
            value: MAccount.administrator ? qsTr("Administrator") : qsTr("Standard")
        }

        MSettingsRow {
            label: qsTr("Email address")
            separator: false

            MTextField {
                text: MAccount.email
                onCommitted: value => MAccount.set("Email", "s", value)
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
