import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: root

    forceWidth: true

    readonly property var roleIcons: ({
            web: "language",
            mail: "mail",
            calendar: "calendar_month",
            music: "music_note",
            video: "movie",
            photos: "image",
            text: "description",
            files: "folder"
        })

    readonly property var roleTitles: ({
            web: Translation.tr("Web"),
            mail: Translation.tr("Mail"),
            calendar: Translation.tr("Calendar"),
            music: Translation.tr("Music"),
            video: Translation.tr("Video"),
            photos: Translation.tr("Photos"),
            text: Translation.tr("Text"),
            files: Translation.tr("Files")
        })

    ContentSection {
        icon: "apps"
        title: Translation.tr("Default Apps")

        Repeater {
            model: DefaultApps.roles

            delegate: ContentSubsection {
                id: role
                required property var modelData

                title: root.roleTitles[role.modelData.key] ?? role.modelData.title

                StyledComboBox {
                    buttonIcon: root.roleIcons[role.modelData.key] ?? "apps"
                    textRole: "name"
                    model: role.modelData.candidates
                    currentIndex: Math.max(0, role.modelData.candidates.findIndex(candidate => candidate.entry === role.modelData.default))
                    onActivated: index => DefaultApps.set(role.modelData.mime, role.modelData.candidates[index].entry)
                }
            }
        }
    }

    ContentSection {
        icon: "terminal"
        title: Translation.tr("Commands")

        ContentSubsection {
            title: Translation.tr("What the shell's own buttons open")

            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Terminal")
                text: Config.options.apps.terminal
                onEditingFinished: {
                    Config.options.apps.terminal = text;
                }
            }
            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Task manager")
                text: Config.options.apps.taskManager
                onEditingFinished: {
                    Config.options.apps.taskManager = text;
                }
            }
            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Volume mixer")
                text: Config.options.apps.volumeMixer
                onEditingFinished: {
                    Config.options.apps.volumeMixer = text;
                }
            }
            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Bluetooth settings")
                text: Config.options.apps.bluetooth
                onEditingFinished: {
                    Config.options.apps.bluetooth = text;
                }
            }
            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Network settings")
                text: Config.options.apps.network
                onEditingFinished: {
                    Config.options.apps.network = text;
                }
            }
            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Ethernet settings")
                text: Config.options.apps.networkEthernet
                onEditingFinished: {
                    Config.options.apps.networkEthernet = text;
                }
            }
            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("User management")
                text: Config.options.apps.manageUser
                onEditingFinished: {
                    Config.options.apps.manageUser = text;
                }
            }
            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Change password")
                text: Config.options.apps.changePassword
                onEditingFinished: {
                    Config.options.apps.changePassword = text;
                }
            }
            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("System update")
                text: Config.options.apps.update
                onEditingFinished: {
                    Config.options.apps.update = text;
                }
            }
        }
    }
}
