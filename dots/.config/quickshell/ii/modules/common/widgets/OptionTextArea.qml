import qs.modules.common.widgets
import QtQuick

/**
 * A text area for one setting: it shows `current` and emits `committed` once a person
 * has finished typing and moved on. Writing on every keystroke instead would have the
 * setting travel back into the field mid-word and scramble what is being typed.
 */
MaterialTextArea {
    id: root

    required property string current

    signal committed(string value)

    function showCurrent(): void {
        if (!root.activeFocus && root.text !== root.current)
            root.text = root.current;
    }

    Component.onCompleted: root.text = root.current
    onCurrentChanged: root.showCurrent()

    onActiveFocusChanged: {
        if (root.activeFocus)
            return;
        if (root.text !== root.current)
            root.committed(root.text);
        root.showCurrent();
    }
}
