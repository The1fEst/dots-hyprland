import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: root

    forceWidth: true

    function languageName(code: string): string {
        const native = Qt.locale(code).nativeLanguageName;
        if (native.length === 0)
            return code;
        return `${native.charAt(0).toUpperCase()}${native.slice(1)} (${code})`;
    }

    ContentSection {
        ContentSubsection {
            title: Translation.tr("Language")
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
                            displayName: root.languageName(lang),
                            value: lang
                        };
                    })]

                boundIndex: {
                    const index = model.findIndex(item => item.value === Config.options.language.ui);
                    return index !== -1 ? index : 0;
                }

                onActivated: index => {
                    Config.options.language.ui = model[index].value;
                }
            }
        }
    }
}
