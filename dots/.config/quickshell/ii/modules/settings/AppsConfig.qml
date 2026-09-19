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
                    boundIndex: Math.max(0, role.modelData.candidates.findIndex(candidate => candidate.entry === role.modelData.default))
                    onActivated: index => DefaultApps.set(role.modelData.mime, role.modelData.candidates[index].entry)
                }
            }
        }
    }

    property alias ruleClass: classField.text
    property int ruleIndex: 0
    property alias ruleValue: valueField.text

    readonly property var ruleKinds: [
        {
            displayName: Translation.tr("Always floating"),
            rule: "float",
            kind: "flag"
        },
        {
            displayName: Translation.tr("Always tiled"),
            rule: "tile",
            kind: "flag"
        },
        {
            displayName: Translation.tr("Pinned to every workspace"),
            rule: "pin",
            kind: "flag"
        },
        {
            displayName: Translation.tr("Opens fullscreen"),
            rule: "fullscreen",
            kind: "flag"
        },
        {
            displayName: Translation.tr("No blur behind it"),
            rule: "no_blur",
            kind: "flag"
        },
        {
            displayName: Translation.tr("No shadow"),
            rule: "no_shadow",
            kind: "flag"
        },
        {
            displayName: Translation.tr("Square corners"),
            rule: "no_rounding",
            kind: "flag"
        },
        {
            displayName: Translation.tr("Draw without waiting for the screen"),
            rule: "immediate",
            kind: "flag"
        },
        {
            displayName: Translation.tr("Opacity (%)"),
            rule: "opacity",
            kind: "percent"
        },
        {
            displayName: Translation.tr("Opens on workspace"),
            rule: "workspace",
            kind: "text"
        }
    ]

    readonly property var runningClasses: {
        const seen = [];
        for (const window of HyprlandData.windowList) {
            const windowClass = window.class ?? "";
            if (windowClass.length > 0 && !seen.includes(windowClass))
                seen.push(windowClass);
        }
        return seen.sort();
    }

    readonly property var chosenRule: root.ruleKinds[root.ruleIndex] ?? root.ruleKinds[0]

    function ruleSummary(rule: var): string {
        const known = root.ruleKinds.find(kind => kind.rule === rule.rule);
        if (!known)
            return `${rule.rule} = ${rule.value}`;
        if (known.kind === "flag")
            return known.displayName;
        if (known.kind === "percent")
            return `${known.displayName.replace(" (%)", "")}: ${Math.round(Number(rule.value) * 100)}%`;
        return `${known.displayName}: ${rule.value}`;
    }

    function addRule(): void {
        const kind = root.chosenRule;
        if (kind.kind === "flag")
            WindowRules.add(root.ruleClass, kind.rule, "true");
        else if (kind.kind === "percent")
            WindowRules.add(root.ruleClass, kind.rule, String(Math.max(1, Math.min(100, Number(root.ruleValue) || 100)) / 100));
        else
            WindowRules.add(root.ruleClass, kind.rule, root.ruleValue);
        root.ruleClass = "";
        root.ruleValue = "";
    }

    ContentSection {
        icon: "select_window"
        title: Translation.tr("Window rules")

        ContentSubsection {
            title: Translation.tr("What each application's windows do")

            StyledText {
                visible: WindowRules.rules.length === 0
                Layout.leftMargin: 8
                text: Translation.tr("No rules yet")
                color: Appearance.colors.colSubtext
            }

            Repeater {
                model: WindowRules.rules

                delegate: Rectangle {
                    id: ruleRow
                    required property var modelData

                    Layout.fillWidth: true
                    implicitHeight: 48
                    radius: Appearance.rounding.small
                    color: Appearance.colors.colLayer2

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: 12
                            rightMargin: 6
                        }
                        spacing: 10

                        StyledText {
                            Layout.fillWidth: true
                            text: ruleRow.modelData.class
                            elide: Text.ElideRight
                            color: Appearance.colors.colOnLayer2
                        }

                        StyledText {
                            text: root.ruleSummary(ruleRow.modelData)
                            color: Appearance.colors.colSubtext
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }

                        RippleButton {
                            buttonRadius: Appearance.rounding.full
                            implicitWidth: 32
                            implicitHeight: 32
                            onClicked: WindowRules.remove(ruleRow.modelData.class, ruleRow.modelData.rule)
                            contentItem: MaterialSymbol {
                                anchors.centerIn: parent
                                horizontalAlignment: Text.AlignHCenter
                                text: "remove"
                                iconSize: 20
                                color: Appearance.colors.colOnLayer2
                            }
                            StyledToolTip {
                                text: Translation.tr("Remove")
                            }
                        }
                    }
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Add a rule")
            tooltip: Translation.tr("The application is matched by its window class, which is what hyprctl clients calls class")

            MaterialTextField {
                id: classField
                Layout.fillWidth: true
                placeholderText: Translation.tr("Window class")
            }

            StyledComboBox {
                visible: root.runningClasses.length > 0
                buttonIcon: "window"
                textRole: "displayName"
                model: root.runningClasses.map(windowClass => ({
                            displayName: windowClass
                        }))
                onActivated: index => root.ruleClass = root.runningClasses[index]
            }

            StyledComboBox {
                buttonIcon: "rule"
                textRole: "displayName"
                model: root.ruleKinds
                boundIndex: root.ruleIndex
                onActivated: index => root.ruleIndex = index
            }

            MaterialTextField {
                id: valueField
                Layout.fillWidth: true
                visible: root.chosenRule.kind !== "flag"
                placeholderText: root.chosenRule.kind === "percent" ? Translation.tr("100") : Translation.tr("e.g. 3 or special:magic")
            }

            RippleButtonWithIcon {
                enabled: root.ruleClass.length > 0
                materialIcon: "add"
                mainText: Translation.tr("Add rule")
                onClicked: root.addRule()
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
                placeholderText: Translation.tr("Network connection editor")
                text: Config.options.apps.network
                onEditingFinished: {
                    Config.options.apps.network = text;
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
