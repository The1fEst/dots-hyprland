import qs
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Scope {
    id: root

    IpcHandler {
        target: "calendar"

        function toggle(): void {
            GlobalStates.calendarOpen = !GlobalStates.calendarOpen;
        }

        function close(): void {
            GlobalStates.calendarOpen = false;
        }

        function open(): void {
            GlobalStates.calendarOpen = true;
        }
    }

    GlobalShortcut {
        name: "calendarToggle"
        description: "Toggles the calendar on press"

        onPressed: {
            GlobalStates.calendarOpen = !GlobalStates.calendarOpen;
        }
    }
}
