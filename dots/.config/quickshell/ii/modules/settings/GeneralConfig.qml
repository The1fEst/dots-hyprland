import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

ContentPage {
    forceWidth: true

    ContentSection {
        icon: "person"
        title: Translation.tr("Account")

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 10
            Layout.bottomMargin: 10
            spacing: 20

            ClippingRectangle {
                implicitWidth: 80
                implicitHeight: 80
                radius: width / 2
                color: Appearance.colors.colLayer2
                antialiasing: true

                StyledImage {
                    id: portrait
                    anchors.fill: parent
                    source: UserAccount.iconFile.length > 0 ? `file://${UserAccount.iconFile}` : ""
                    sourceSize: Qt.size(160, 160)
                    fillMode: Image.PreserveAspectCrop
                }

                MaterialSymbol {
                    anchors.centerIn: parent
                    visible: portrait.status !== Image.Ready
                    text: "person"
                    iconSize: 40
                    color: Appearance.colors.colSubtext
                }
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter

                StyledText {
                    text: UserAccount.displayName
                    font.pixelSize: Appearance.font.pixelSize.title
                }
                StyledText {
                    text: UserAccount.administrator ? Translation.tr("%1 · Administrator").arg(UserAccount.userName) : Translation.tr("%1 · Standard").arg(UserAccount.userName)
                    color: Appearance.colors.colSubtext
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Name")

            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: UserAccount.userName
                text: UserAccount.realName
                onEditingFinished: {
                    UserAccount.set("RealName", "s", text);
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Email address")

            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("name@example.com")
                text: UserAccount.email
                onEditingFinished: {
                    UserAccount.set("Email", "s", text);
                }
            }
        }

        RippleButtonWithIcon {
            materialIcon: "password"
            mainText: Translation.tr("Change password…")
            onClicked: {
                AppLaunch.shell(`${Config.options.apps.terminal} passwd`);
            }
        }
    }
}
