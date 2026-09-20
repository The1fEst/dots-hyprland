import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

FloatingWindow {
    id: root
    property string firstRunFilePath: FileUtils.trimFileProtocol(`${Directories.state}/user/first_run.txt`)
    property string firstRunFileContent: "This file is just here to confirm you've been greeted :>"
    property real contentPadding: 8
    property bool showNextTime: false

    visible: GlobalStates.welcomeOpen
    onClosed: {
        GlobalStates.welcomeOpen = false;
        Quickshell.execDetached(["notify-send", Translation.tr("Welcome app"), Translation.tr("Enjoy! You can reopen the welcome app any time with <tt>Super+Shift+Alt+/</tt>. To open the settings app, hit <tt>Super+I</tt>"), "-a", "Shell"]);
    }
    title: Translation.tr("illogical-impulse Welcome")

    IpcHandler {
        target: "welcome"

        function open(): void {
            GlobalStates.welcomeOpen = true;
        }

        function close(): void {
            GlobalStates.welcomeOpen = false;
        }

        function toggle(): void {
            GlobalStates.welcomeOpen = !GlobalStates.welcomeOpen;
        }
    }

    minimumSize: Qt.size(600, 400)
    implicitWidth: 900
    implicitHeight: 650
    color: Appearance.m3colors.m3background



    ColumnLayout {
        anchors {
            fill: parent
            margins: contentPadding
        }

        focus: true
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Escape) {
                GlobalStates.welcomeOpen = false;
                event.accepted = true;
            }
        }

        Item {
            // Titlebar
            visible: Config.options?.windows.showTitlebar
            Layout.fillWidth: true
            implicitHeight: Math.max(welcomeText.implicitHeight, windowControlsRow.implicitHeight)
            StyledText {
                id: welcomeText
                anchors.verticalCenter: parent.verticalCenter
                x: Config.options.windows.centerTitle ? (parent.width - width) / 2 : 12
                color: Appearance.colors.colOnLayer0
                text: Translation.tr("Hi there! First things first...")
                font {
                    family: Appearance.font.family.title
                    pixelSize: Appearance.font.pixelSize.title
                    variableAxes: Appearance.font.variableAxes.title
                }
            }
            RowLayout { // Window controls row
                id: windowControlsRow
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                StyledText {
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    text: Translation.tr("Show next time")
                }
                StyledSwitch {
                    id: showNextTimeSwitch
                    checked: root.showNextTime
                    scale: 0.6
                    Layout.alignment: Qt.AlignVCenter
                    onCheckedChanged: {
                        if (checked) {
                            Quickshell.execDetached(["rm", root.firstRunFilePath]);
                        } else {
                            Quickshell.execDetached(["bash", "-c", `echo '${StringUtils.shellSingleQuoteEscape(root.firstRunFileContent)}' > '${StringUtils.shellSingleQuoteEscape(root.firstRunFilePath)}'`]);
                        }
                    }
                }
                RippleButton {
                    buttonRadius: Appearance.rounding.full
                    implicitWidth: 35
                    implicitHeight: 35
                    onClicked: root.close()
                    contentItem: MaterialSymbol {
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        text: "close"
                        iconSize: 20
                    }

                    StyledToolTip {
                        text: Translation.tr("Tip: Close a window with Super+Q")
                    }
                }
            }
        }

        Rectangle {
            // Content container
            color: Appearance.m3colors.m3surfaceContainerLow
            radius: Appearance.rounding.windowRounding - root.contentPadding
            implicitHeight: contentColumn.implicitHeight
            implicitWidth: contentColumn.implicitWidth
            Layout.fillWidth: true
            Layout.fillHeight: true

            ContentPage {
                id: contentColumn
                anchors.fill: parent

                ContentSection {
                    Layout.fillWidth: true
                    icon: "language"
                    title: Translation.tr("Language")

                    ContentSubsection {
                        title: Translation.tr("Select language")
                        ConfigSelectionArray {
                            id: languageSelector
                            currentValue: Config.options.language.ui
                            onSelected: newValue => {
                                Config.options.language.ui = newValue;
                            }
                            options: [
                                {
                                    displayName: Translation.tr("Auto (System)"),
                                    value: "auto"
                                },
                                ...Translation.allAvailableLanguages.map(lang => {
                                    return {
                                        displayName: lang,
                                        value: lang
                                    };
                                })]
                        }
                    }

                    // Removed section: "Generate translation with Gemini"
                }

                ContentSection {
                    id: displaySection
                    icon: "display_settings"
                    title: Translation.tr("Displays")

                    property string selectedOutput: ""
                    readonly property list<var> monitors: HyprlandData.monitorsAll
                    readonly property var monitor: displaySection.monitors.find(one => one.name === displaySection.selectedOutput) ?? displaySection.monitors[0] ?? null
                    readonly property string name: displaySection.monitor?.name ?? ""
                    readonly property real logicalWidth: Math.round((displaySection.monitor?.width ?? 0) / Math.max(0.01, displaySection.monitor?.scale ?? 1))
                    readonly property real logicalHeight: Math.round((displaySection.monitor?.height ?? 0) / Math.max(0.01, displaySection.monitor?.scale ?? 1))

                    function indexOfValue(model: var, value: var): int {
                        const found = model.findIndex(item => item.value === value);
                        return found !== -1 ? found : 0;
                    }

                    function apply(keys: var): void {
                        DisplayOptions.applyTo(displaySection.monitor, keys);
                    }

                    ConfigSelectionArray {
                        visible: displaySection.monitors.length > 1
                        currentValue: displaySection.name
                        onSelected: newValue => {
                            displaySection.selectedOutput = newValue;
                        }
                        options: displaySection.monitors.map(one => ({
                                    value: one.name,
                                    displayName: `${one.model || one.name} (${one.name})`
                                }))
                    }

                    MonitorArrangement {
                        Layout.fillWidth: true
                        visible: displaySection.monitors.length > 1
                        selected: displaySection.name
                        onPicked: name => displaySection.selectedOutput = name
                        onMoved: (name, x, y) => DisplayOptions.moveTo(name, x, y)
                    }

                    ConfigRow {
                        ContentSubsection {
                            title: Translation.tr("Resolution")

                            StyledComboBox {
                                buttonIcon: "aspect_ratio"
                                textRole: "displayName"
                                model: DisplayOptions.shownModesOf(displaySection.monitor, false).map(mode => ({
                                            displayName: mode.native ? Translation.tr("%1 × %2 (Default)").arg(mode.width).arg(mode.height) : `${mode.width} × ${mode.height}`,
                                            value: `${mode.width}x${mode.height}`,
                                            mode: mode
                                        }))
                                boundIndex: displaySection.indexOfValue(model, `${displaySection.logicalWidth}x${displaySection.logicalHeight}`)
                                onActivated: index => {
                                    const picked = model[index].mode;
                                    displaySection.apply({
                                        size: `${picked.mode.width}x${picked.mode.height}`,
                                        scale: picked.scale,
                                        rate: picked.rate ?? displaySection.monitor?.refreshRate
                                    });
                                }
                            }
                        }

                        ContentSubsection {
                            title: Translation.tr("Refresh rate")

                            StyledComboBox {
                                buttonIcon: "refresh"
                                textRole: "displayName"
                                model: DisplayOptions.ratesOf(displaySection.monitor).map(rate => ({
                                            displayName: Translation.tr("%1 Hz").arg(Math.round(rate)),
                                            value: Math.round(rate)
                                        }))
                                boundIndex: displaySection.indexOfValue(model, Math.round(displaySection.monitor?.refreshRate ?? 0))
                                onActivated: index => displaySection.apply({
                                        rate: model[index].value
                                    })
                            }
                        }
                    }
                }

                ContentSection {
                    id: soundSection
                    icon: "volume_up"
                    title: Translation.tr("Sound")

                    function deviceLabel(node: var): string {
                        const description = node?.description ?? "";
                        const device = node?.nickname ?? "";
                        if (device.length > 0 && description.length > device.length && description.startsWith(device))
                            return `${device} · ${description.slice(device.length).trim()}`;
                        return description || device || node?.name || "";
                    }

                    function deviceOptions(devices: var): var {
                        return devices.map(node => ({
                                    displayName: soundSection.deviceLabel(node),
                                    value: node
                                }));
                    }

                    function indexOfDevice(options: var, node: var): int {
                        const found = options.findIndex(option => option.value === node);
                        return found !== -1 ? found : 0;
                    }

                    PwObjectTracker {
                        objects: [...Audio.outputDevices, ...Audio.inputDevices]
                    }

                    ContentSubsection {
                        title: Translation.tr("Output")

                        StyledComboBox {
                            buttonIcon: "speaker"
                            textRole: "displayName"
                            model: soundSection.deviceOptions(Audio.outputDevices)
                            boundIndex: soundSection.indexOfDevice(model, Audio.sink)
                            onActivated: index => Audio.setDefaultSink(model[index].value)
                        }
                    }

                    ContentSubsection {
                        title: Translation.tr("Input")

                        StyledComboBox {
                            buttonIcon: "mic"
                            textRole: "displayName"
                            model: soundSection.deviceOptions(Audio.inputDevices)
                            boundIndex: soundSection.indexOfDevice(model, Audio.source)
                            onActivated: index => Audio.setDefaultSource(model[index].value)
                        }
                    }
                }

                ContentSection {
                    icon: "screenshot_monitor"
                    title: Translation.tr("Bar")

                    ConfigRow {
                        ContentSubsection {
                            title: Translation.tr("Bar position")
                            ConfigSelectionArray {
                                currentValue: (Config.options.bar.bottom ? 1 : 0) | (Config.options.bar.vertical ? 2 : 0)
                                onSelected: newValue => {
                                    Config.options.bar.bottom = (newValue & 1) !== 0;
                                    Config.options.bar.vertical = (newValue & 2) !== 0;
                                }
                                options: [
                                    {
                                        displayName: Translation.tr("Top"),
                                        icon: "arrow_upward",
                                        value: 0 // bottom: false, vertical: false
                                    },
                                    {
                                        displayName: Translation.tr("Left"),
                                        icon: "arrow_back",
                                        value: 2 // bottom: false, vertical: true
                                    },
                                    {
                                        displayName: Translation.tr("Bottom"),
                                        icon: "arrow_downward",
                                        value: 1 // bottom: true, vertical: false
                                    },
                                    {
                                        displayName: Translation.tr("Right"),
                                        icon: "arrow_forward",
                                        value: 3 // bottom: true, vertical: true
                                    }
                                ]
                            }
                        }
                        ContentSubsection {
                            title: Translation.tr("Bar style")

                            ConfigSelectionArray {
                                currentValue: Config.options.bar.cornerStyle
                                onSelected: newValue => {
                                    Config.options.bar.cornerStyle = newValue; // Update local copy
                                }
                                options: [
                                    {
                                        displayName: Translation.tr("Hug"),
                                        icon: "line_curve",
                                        value: 0
                                    },
                                    {
                                        displayName: Translation.tr("Float"),
                                        icon: "page_header",
                                        value: 1
                                    },
                                    {
                                        displayName: Translation.tr("Rect"),
                                        icon: "toolbar",
                                        value: 2
                                    }
                                ]
                            }
                        }
                    }
                }

                ContentSection {
                    icon: "format_paint"
                    title: Translation.tr("Style & wallpaper")

                    ButtonGroup {
                        Layout.alignment: Qt.AlignHCenter
                        LightDarkPreferenceButton {
                            dark: false
                        }
                        LightDarkPreferenceButton {
                            dark: true
                        }
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        RippleButtonWithIcon {
                            materialIcon: "wallpaper"
                            StyledToolTip {
                                text: Translation.tr("Pick wallpaper image on your system")
                            }
                            onClicked: {
                                Quickshell.execDetached([`${Directories.wallpaperSwitchScriptPath}`]);
                            }
                            mainContentComponent: Component {
                                RowLayout {
                                    spacing: 10
                                    StyledText {
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        text: Translation.tr("Choose file")
                                        color: Appearance.colors.colOnSecondaryContainer
                                    }
                                    RowLayout {
                                        spacing: 3
                                        KeyboardKey {
                                            key: "Ctrl"
                                        }
                                        KeyboardKey {
                                            key: "󰖳"
                                        }
                                        StyledText {
                                            Layout.alignment: Qt.AlignVCenter
                                            text: "+"
                                        }
                                        KeyboardKey {
                                            key: "T"
                                        }
                                    }
                                }
                            }
                        }
                    }

                    NoticeBox {
                        Layout.fillWidth: true
                        text: Translation.tr("Change any time later with /dark, /light, /wallpaper in the launcher\nIf the shell's colors aren't changing:\n    1. Open the right sidebar with Super+N\n    2. Click \"Reload Hyprland & Quickshell\" in the top-right corner")
                    }
                }

                ContentSection {
                    icon: "bedtime"
                    title: Translation.tr("Power saving")

                    IdleTimeoutRow {
                        title: Translation.tr("Automatic Screen Blank")
                        tooltip: Translation.tr("Turns the screens off after a period of inactivity")
                        what: "screen"
                        switchIcon: "brightness_low"
                        switchText: Translation.tr("Blank the screen")
                        fallbackMinutes: 15
                    }

                    IdleTimeoutRow {
                        title: Translation.tr("Suspend when idle")
                        tooltip: Translation.tr("Turning automatic suspend off means the machine keeps drawing power while nobody is at it")
                        what: "suspend"
                        switchIcon: "pause"
                        switchText: Translation.tr("Suspend")
                        fallbackMinutes: 45
                    }
                }

                ContentSection {
                    icon: "info"
                    title: Translation.tr("Info")

                    Flow {
                        Layout.fillWidth: true
                        spacing: 5

                        RippleButtonWithIcon {
                            materialIcon: "keyboard_alt"
                            onClicked: {
                                Hyprland.dispatch('hl.dsp.global("quickshell:cheatsheetToggle")');
                            }
                            mainContentComponent: Component {
                                RowLayout {
                                    spacing: 10
                                    StyledText {
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        text: Translation.tr("Keybinds")
                                        color: Appearance.colors.colOnSecondaryContainer
                                    }
                                    RowLayout {
                                        spacing: 3
                                        KeyboardKey {
                                            key: "󰖳"
                                        }
                                        StyledText {
                                            Layout.alignment: Qt.AlignVCenter
                                            text: "+"
                                        }
                                        KeyboardKey {
                                            key: "/"
                                        }
                                    }
                                }
                            }
                        }

                        RippleButtonWithIcon {
                            materialIcon: "help"
                            mainText: Translation.tr("Usage")
                            onClicked: {
                                Qt.openUrlExternally("https://end-4.github.io/dots-hyprland-wiki/en/ii-qs/02usage/");
                            }
                        }
                        RippleButtonWithIcon {
                            materialIcon: "construction"
                            mainText: Translation.tr("Configuration")
                            onClicked: {
                                Qt.openUrlExternally("https://end-4.github.io/dots-hyprland-wiki/en/ii-qs/03config/");
                            }
                        }
                    }
                }

                ContentSection {
                    icon: "monitoring"
                    title: Translation.tr("Useless buttons")

                    Flow {
                        Layout.fillWidth: true
                        spacing: 5

                        RippleButtonWithIcon {
                            nerdIcon: "󰊤"
                            mainText: Translation.tr("GitHub")
                            onClicked: {
                                Qt.openUrlExternally("https://github.com/end-4/dots-hyprland");
                            }
                        }
                        RippleButtonWithIcon {
                            materialIcon: "favorite"
                            mainText: "Funny number"
                            onClicked: {
                                Qt.openUrlExternally("https://github.com/sponsors/end-4");
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
    }
}
