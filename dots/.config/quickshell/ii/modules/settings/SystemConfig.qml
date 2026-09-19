import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: root

    forceWidth: true

    ContentSection {
        ContentLinkRow {
            buttonIcon: "language"
            title: Translation.tr("Region & Language")
            subtitle: Translation.tr("Interface language and the calendar's locale")
            onClicked: root.subpageRequested(title, "modules/settings/RegionConfig.qml")
        }

        ContentLinkRow {
            buttonIcon: "nest_clock_farsight_analog"
            title: Translation.tr("Date & Time")
            subtitle: Translation.tr("Clock format, date formats and the pomodoro timer")
            onClicked: root.subpageRequested(title, "modules/settings/DateTimeConfig.qml")
        }

        ContentLinkRow {
            buttonIcon: "person"
            title: Translation.tr("Users")
            subtitle: UserAccount.displayName
            onClicked: root.subpageRequested(title, "modules/settings/GeneralConfig.qml")
        }

        ContentLinkRow {
            buttonIcon: "info"
            title: Translation.tr("About")
            subtitle: Translation.tr("What this machine is and what it runs")
            onClicked: root.subpageRequested(title, "modules/settings/About.qml")
        }
    }

    ContentSection {
        icon: "tune"
        title: Translation.tr("The shell itself")

        ContentLinkRow {
            buttonIcon: "settings"
            title: Translation.tr("Services")
            subtitle: Translation.tr("Weather, updates, resources and the conflict killer")
            onClicked: root.subpageRequested(title, "modules/settings/ServicesConfig.qml")
        }

        ContentLinkRow {
            buttonIcon: "construction"
            title: Translation.tr("Advanced")
            subtitle: Translation.tr("Workarounds and settings that can break things")
            onClicked: root.subpageRequested(title, "modules/settings/AdvancedConfig.qml")
        }
    }
}
