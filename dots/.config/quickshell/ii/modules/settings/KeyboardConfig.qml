import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

ContentPage {
    id: root

    forceWidth: true

    property bool choosing: false
    property string chooserQuery: ""
    property string shortcutQuery: ""

    readonly property var shortcutGroups: {
        const terms = root.shortcutQuery.toLowerCase().split(/\s+/).filter(term => term.length > 0);
        const wanted = bind => {
            if (terms.length === 0)
                return true;
            const haystack = `${HyprlandKeybinds.labelOf(bind)} ${HyprlandKeybinds.keys(bind).join(" ")}`.toLowerCase();
            return terms.every(term => haystack.includes(term));
        };
        const groups = [];
        for (const category of HyprlandKeybinds.keybindCategories) {
            const binds = HyprlandKeybinds.keybinds.filter(bind => HyprlandKeybinds.categoryOf(bind) === category && wanted(bind));
            if (binds.length > 0)
                groups.push({
                    name: category,
                    binds: binds
                });
        }
        return groups;
    }

    readonly property var sources: XkbLayouts.codes.map((code, index) => ({
                code: code,
                variant: XkbLayouts.variantAt(index),
                name: XkbLayouts.nameOf(code, XkbLayouts.variantAt(index))
            }))

    readonly property var candidates: {
        const all = [];
        for (const layout of XkbLayouts.layouts) {
            all.push({
                code: layout.code,
                variant: "",
                name: layout.name
            });
            for (const variant of layout.variants)
                all.push({
                    code: layout.code,
                    variant: variant.code,
                    name: variant.name
                });
        }
        const terms = root.chooserQuery.toLowerCase().split(/\s+/).filter(term => term.length > 0);
        if (terms.length === 0)
            return all;
        return all.filter(entry => {
            const haystack = `${entry.name} ${entry.code} ${entry.variant}`.toLowerCase();
            return terms.every(term => haystack.includes(term));
        });
    }

    function optionGroup(code: string): var {
        return XkbLayouts.optionGroups.find(group => group.code === code) ?? null;
    }

    function optionPrefix(group: var): string {
        return (group?.options[0]?.code ?? "").split(":")[0];
    }

    function optionChoices(group: var, noneLabel: string): var {
        const choices = [
            {
                displayName: noneLabel,
                value: ""
            }
        ];
        for (const option of group?.options ?? [])
            choices.push({
                displayName: option.name,
                value: option.code
            });
        return choices;
    }

    function indexOfOption(choices: var, prefix: string): int {
        const chosen = XkbLayouts.optionOf(prefix);
        const found = choices.findIndex(choice => choice.value === chosen);
        return found !== -1 ? found : 0;
    }

    function applySources(sources: var): void {
        XkbLayouts.apply(sources.map(source => source.code), sources.map(source => source.variant));
    }

    function moveSource(index: int, to: int): void {
        if (to < 0 || to >= root.sources.length)
            return;
        const kept = root.sources.slice();
        const [moved] = kept.splice(index, 1);
        kept.splice(to, 0, moved);
        root.applySources(kept);
    }

    function removeSource(index: int): void {
        if (root.sources.length <= 1)
            return;
        const kept = root.sources.slice();
        kept.splice(index, 1);
        root.applySources(kept);
    }

    function addSource(entry: var): void {
        if (root.sources.some(source => source.code === entry.code && source.variant === entry.variant))
            return;
        root.applySources(root.sources.concat([entry]));
        root.choosing = false;
        root.chooserQuery = "";
    }

    ContentSection {
        icon: "keyboard"
        title: Translation.tr("Input Sources")

        ContentSubsection {
            title: Translation.tr("Keyboard layouts, in the order they are cycled through")

            Repeater {
                model: root.sources

                delegate: Rectangle {
                    id: sourceRow
                    required property int index
                    required property var modelData

                    Layout.fillWidth: true
                    implicitHeight: 44
                    radius: Appearance.rounding.small
                    color: Appearance.colors.colLayer2

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: 12
                            rightMargin: 6
                        }
                        spacing: 8

                        StyledText {
                            text: `${sourceRow.index + 1}`
                            color: Appearance.colors.colSubtext
                            font.pixelSize: Appearance.font.pixelSize.small
                        }
                        StyledText {
                            Layout.fillWidth: true
                            text: sourceRow.modelData.name
                            elide: Text.ElideRight
                            color: Appearance.colors.colOnLayer2
                        }
                        StyledText {
                            text: sourceRow.modelData.variant.length > 0 ? `${sourceRow.modelData.code} · ${sourceRow.modelData.variant}` : sourceRow.modelData.code
                            color: Appearance.colors.colSubtext
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }
                        RippleButton {
                            buttonRadius: Appearance.rounding.full
                            implicitWidth: 32
                            implicitHeight: 32
                            enabled: sourceRow.index > 0
                            onClicked: root.moveSource(sourceRow.index, sourceRow.index - 1)
                            contentItem: MaterialSymbol {
                                anchors.centerIn: parent
                                horizontalAlignment: Text.AlignHCenter
                                text: "keyboard_arrow_up"
                                iconSize: 20
                                color: parent.enabled ? Appearance.colors.colOnLayer2 : Appearance.colors.colSubtext
                            }
                            StyledToolTip {
                                text: Translation.tr("Move up")
                            }
                        }
                        RippleButton {
                            buttonRadius: Appearance.rounding.full
                            implicitWidth: 32
                            implicitHeight: 32
                            enabled: sourceRow.index < root.sources.length - 1
                            onClicked: root.moveSource(sourceRow.index, sourceRow.index + 1)
                            contentItem: MaterialSymbol {
                                anchors.centerIn: parent
                                horizontalAlignment: Text.AlignHCenter
                                text: "keyboard_arrow_down"
                                iconSize: 20
                                color: parent.enabled ? Appearance.colors.colOnLayer2 : Appearance.colors.colSubtext
                            }
                            StyledToolTip {
                                text: Translation.tr("Move down")
                            }
                        }
                        RippleButton {
                            buttonRadius: Appearance.rounding.full
                            implicitWidth: 32
                            implicitHeight: 32
                            enabled: root.sources.length > 1
                            onClicked: root.removeSource(sourceRow.index)
                            contentItem: MaterialSymbol {
                                anchors.centerIn: parent
                                horizontalAlignment: Text.AlignHCenter
                                text: "remove"
                                iconSize: 20
                                color: parent.enabled ? Appearance.colors.colOnLayer2 : Appearance.colors.colSubtext
                            }
                            StyledToolTip {
                                text: Translation.tr("Remove")
                            }
                        }
                    }
                }
            }

            RippleButtonWithIcon {
                Layout.topMargin: 4
                materialIcon: root.choosing ? "close" : "add"
                mainText: root.choosing ? Translation.tr("Cancel") : Translation.tr("Add input source")
                onClicked: {
                    root.choosing = !root.choosing;
                    root.chooserQuery = "";
                }
            }
        }

        ContentSubsection {
            visible: root.choosing
            title: Translation.tr("Add an input source")

            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Search layouts")
                onTextChanged: root.chooserQuery = text
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 260
                radius: Appearance.rounding.small
                color: Appearance.colors.colLayer2
                clip: true

                StyledListView {
                    anchors {
                        fill: parent
                        margins: 4
                    }
                    model: root.candidates
                    spacing: 2

                    delegate: RippleButton {
                        required property var modelData
                        width: ListView.view.width
                        implicitHeight: 34
                        buttonRadius: Appearance.rounding.small
                        colBackground: ColorUtils.transparentize(Appearance.colors.colLayer2)
                        onClicked: root.addSource({
                                code: modelData.code,
                                variant: modelData.variant
                            })

                        contentItem: RowLayout {
                            spacing: 8
                            StyledText {
                                Layout.fillWidth: true
                                Layout.leftMargin: 8
                                text: modelData.name
                                elide: Text.ElideRight
                                color: Appearance.colors.colOnLayer2
                            }
                            StyledText {
                                Layout.rightMargin: 8
                                text: modelData.variant.length > 0 ? `${modelData.code} · ${modelData.variant}` : modelData.code
                                color: Appearance.colors.colSubtext
                                font.pixelSize: Appearance.font.pixelSize.smaller
                            }
                        }
                    }
                }
            }
        }
    }

    component OptionCombo: ContentSubsection {
        id: combo

        required property string groupCode
        required property string noneLabel
        property string buttonIcon: ""

        readonly property var group: root.optionGroup(combo.groupCode)
        readonly property var choices: root.optionChoices(combo.group, combo.noneLabel)

        StyledComboBox {
            buttonIcon: combo.buttonIcon
            textRole: "displayName"
            model: combo.choices
            currentIndex: root.indexOfOption(combo.choices, root.optionPrefix(combo.group))
            onActivated: index => XkbLayouts.setOption(root.optionPrefix(combo.group), combo.choices[index].value)
        }
    }

    ContentSection {
        icon: "keyboard_alt"
        title: Translation.tr("Typing")

        OptionCombo {
            title: Translation.tr("Switch between layouts with")
            groupCode: "grp"
            buttonIcon: "swap_horiz"
            noneLabel: Translation.tr("Only the shell shortcut")
        }

        ContentSubsection {
            title: Translation.tr("Key repeat")

            ConfigRow {
                uniform: true

                OptionSpinBox {
                    icon: "timer"
                    text: Translation.tr("Delay (ms)")
                    current: HyprlandOptions.number("input:repeat_delay")
                    from: 100
                    to: 2000
                    stepSize: 25
                    onCommitted: delay => HyprlandOptions.set("input:repeat_delay", delay)
                }

                OptionSpinBox {
                    icon: "speed"
                    text: Translation.tr("Rate (per second)")
                    current: HyprlandOptions.number("input:repeat_rate")
                    from: 1
                    to: 100
                    stepSize: 1
                    onCommitted: rate => HyprlandOptions.set("input:repeat_rate", rate)
                }
            }
        }

        HyprlandSwitch {
            buttonIcon: "pin"
            text: Translation.tr("Num Lock when the session starts")
            option: "input:numlock_by_default"
        }

        HyprlandSwitch {
            buttonIcon: "language"
            text: Translation.tr("Shortcuts follow the symbol on the key")
            option: "input:resolve_binds_by_sym"

            StyledToolTip {
                text: Translation.tr("On: a shortcut is the letter it types, so it moves with the layout.\nOff: a shortcut is the place on the keyboard, so it stays put in any layout.")
            }
        }
    }

    ContentSection {
        icon: "emoji_symbols"
        title: Translation.tr("Special Character Entry")

        ContentSubsectionLabel {
            text: Translation.tr("Ways of typing symbols and letter variants")
        }

        OptionCombo {
            title: Translation.tr("Alternate characters key")
            groupCode: "lv3"
            buttonIcon: "keyboard_option_key"
            noneLabel: Translation.tr("None")
        }

        OptionCombo {
            title: Translation.tr("Compose key")
            groupCode: "Compose key"
            buttonIcon: "text_select_start"
            noneLabel: Translation.tr("None")
        }
    }

    ContentSection {
        icon: "shortcut"
        title: Translation.tr("Keyboard Shortcuts")

        MaterialTextField {
            Layout.fillWidth: true
            placeholderText: Translation.tr("Search shortcuts")
            onTextChanged: root.shortcutQuery = text
        }

        Repeater {
            model: root.shortcutGroups

            delegate: ContentSubsection {
                id: shortcutGroup
                required property var modelData

                title: shortcutGroup.modelData.name

                Repeater {
                    model: shortcutGroup.modelData.binds

                    delegate: RowLayout {
                        id: shortcutRow
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        spacing: 8

                        StyledText {
                            Layout.fillWidth: true
                            text: HyprlandKeybinds.labelOf(shortcutRow.modelData)
                            elide: Text.ElideRight
                            color: Appearance.colors.colOnLayer1
                        }

                        Repeater {
                            model: HyprlandKeybinds.keys(shortcutRow.modelData)

                            delegate: KeyboardKey {
                                required property string modelData
                                key: modelData
                            }
                        }
                    }
                }
            }
        }
    }
}
