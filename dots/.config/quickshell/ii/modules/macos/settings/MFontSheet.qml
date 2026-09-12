pragma ComponentBehavior: Bound

import QtQuick
import qs.services
import qs.modules.macos.controls
import qs.modules.macos.looks

MSheet {
    id: root

    property string role: ""
    property string family: ""
    property string style: ""
    property int size: 10

    readonly property int familyColumn: 240
    readonly property int styleColumn: 150
    readonly property int sizeColumn: 76
    readonly property int columnGap: 12
    readonly property int listHeight: 220
    readonly property int sampleHeight: 56

    readonly property var styles: DesktopAppearance.families[root.family] ?? []

    readonly property bool everyRole: root.role === "all"
    property bool takesFamily: true
    property bool takesStyle: true
    property bool takesSize: true

    signal chosen(string role, var parts)

    function edit(role: string, font: var): void {
        root.role = role;
        root.family = font.family;
        root.style = font.style;
        root.size = font.size;
        root.takesFamily = role !== "all";
        root.takesStyle = role !== "all";
        root.takesSize = role !== "all";
        DesktopAppearance.loadFamilies();
        root.open();
    }

    width: root.padding * 2 + root.familyColumn + root.styleColumn + root.sizeColumn + root.columnGap * 2
    confirmLabel: qsTr("Select")
    confirmEnabled: root.takesFamily || root.takesStyle || root.takesSize

    onConfirmed: {
        const parts = {};
        if (root.takesFamily)
            parts.family = root.family;
        if (root.takesStyle)
            parts.style = root.style;
        if (root.takesSize)
            parts.size = root.size;
        root.chosen(root.role, parts);
    }

    component Heading: Item {
        id: heading

        required property string label
        required property bool taken
        required property var take

        implicitWidth: root.everyRole ? box.implicitWidth : plain.implicitWidth
        implicitHeight: Looks.control.regular

        MCheckbox {
            id: box
            anchors.verticalCenter: parent.verticalCenter
            visible: root.everyRole
            label: heading.label
            emphasized: true
            checked: heading.taken
            onToggled: value => heading.take(value)
        }

        MText {
            id: plain
            anchors.verticalCenter: parent.verticalCenter
            visible: !root.everyRole
            text: heading.label
            emphasized: true
        }
    }

    body: Column {
        id: sheetBody

        spacing: Looks.settings.formGap

        Row {
            spacing: root.columnGap

            Column {
                spacing: 6

                Heading {
                    label: qsTr("Font")
                    taken: root.takesFamily
                    take: value => root.takesFamily = value
                }

                MChoiceList {
                    width: root.familyColumn
                    height: root.listHeight
                    available: root.takesFamily
                    previewsFamilies: true
                    options: DesktopAppearance.familyNames
                    current: root.family
                    onSelected: value => {
                        root.family = value;
                        if (!root.styles.includes(root.style))
                            root.style = root.styles[0] ?? "Regular";
                    }
                }
            }

            Column {
                spacing: 6

                Heading {
                    label: qsTr("Font style")
                    taken: root.takesStyle
                    take: value => root.takesStyle = value
                }

                MChoiceList {
                    width: root.styleColumn
                    height: root.listHeight
                    available: root.takesStyle
                    previewsStylesOf: root.family
                    options: root.styles
                    current: root.style
                    onSelected: value => root.style = value
                }
            }

            Column {
                spacing: 6

                Heading {
                    label: qsTr("Size")
                    taken: root.takesSize
                    take: value => root.takesSize = value
                }

                MNumberField {
                    available: root.takesSize
                    from: 5
                    to: 72
                    value: root.size
                    onEdited: value => root.size = value
                }

                MChoiceList {
                    width: root.sizeColumn
                    height: root.listHeight - Looks.control.regular - 6
                    available: root.takesSize
                    options: DesktopAppearance.sizes.map(one => String(one))
                    current: String(root.size)
                    onSelected: value => root.size = parseInt(value)
                }
            }
        }

        Column {
            spacing: 6

            MText {
                text: qsTr("Sample")
                emphasized: true
            }

            Rectangle {
                width: sheetBody.width
                height: root.sampleHeight
                radius: Looks.settings.formRadius
                color: Looks.colors.quinary
                antialiasing: true

                MText {
                    anchors.centerIn: parent
                    width: parent.width - Looks.settings.formRowInset * 2
                    text: qsTr("The Quick Brown Fox Jumps Over The Lazy Dog")
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    font.family: root.family
                    font.styleName: root.style
                    font.pixelSize: root.size + 4
                    color: Looks.colors.primary
                }
            }
        }
    }
}
