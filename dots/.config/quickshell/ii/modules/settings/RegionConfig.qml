import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: root

    forceWidth: true

    ContentSection {
        icon: "language"
        title: Translation.tr("Region & Language")

        ContentSubsection {
            title: Translation.tr("Interface Language")
            tooltip: Translation.tr("Select the language for the user interface.\n\"Auto\" will use your system's locale.")

            StyledComboBox {
                id: languageSelector
                buttonIcon: "language"
                textRole: "displayName"

                model: [
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

                currentIndex: {
                    const index = model.findIndex(item => item.value === Config.options.language.ui);
                    return index !== -1 ? index : 0;
                }

                onActivated: index => {
                    Config.options.language.ui = model[index].value;
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Calendar locale")
            tooltip: Translation.tr("Determines the first day of week")

            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("e.g. en-GB")
                text: Config.options.calendar.locale
                onEditingFinished: {
                    Config.options.calendar.locale = text.trim();
                }
            }
        }
    }
}
