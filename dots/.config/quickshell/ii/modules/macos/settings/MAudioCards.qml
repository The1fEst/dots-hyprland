pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property list<var> cards: []

    function reload(): void {
        readProc.running = true;
    }

    function setProfile(card: string, profile: string): void {
        writeProc.exec(["pactl", "set-card-profile", card, profile]);
    }

    Process {
        id: readProc
        running: true
        command: ["pactl", "-f", "json", "list", "cards"]

        stdout: StdioCollector {
            onStreamFinished: {
                const listed = JSON.parse(this.text.length > 0 ? this.text : "[]");
                root.cards = listed.map(card => ({
                            name: card.name,
                            description: card.properties["device.description"] ?? card.name,
                            active: Object.keys(card.profiles).find(key => key === card.active_profile) ?? "off",
                            profiles: Object.entries(card.profiles).filter(entry => entry[1].available).map(entry => ({
                                        label: entry[1].description,
                                        value: entry[0]
                                    }))
                        }));
            }
        }
    }

    Process {
        id: writeProc
        onExited: root.reload()
    }
}
