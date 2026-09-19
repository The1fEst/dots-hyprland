pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import qs.modules.common.functions
import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Clipboard history, kept by stash. An entry is one line of its TSV listing:
 * an id, a tab, and a preview of what was copied.
 */
Singleton {
    id: root

    property string binary: "stash"
    property real pasteDelay: 0.05
    property string pressPasteCommand: "ydotool key -d 1 29:1 47:1 47:0 29:0"
    property bool sloppySearch: Config.options?.search.sloppy ?? false
    property real scoreThreshold: 0.2
    property list<string> entries: []
    readonly property var preparedEntries: entries.map(a => ({
                name: Fuzzy.prepare(`${a.replace(/^\s*\S+\s+/, "")}`),
                entry: a
            }))

    function idOf(entry: string): string {
        return entry.split("\t")[0];
    }

    function fuzzyQuery(search: string): var {
        if (search.trim() === "") {
            return entries;
        }
        if (root.sloppySearch) {
            const results = entries.slice(0, 100).map(str => ({
                        entry: str,
                        score: Levendist.computeTextMatchScore(str.toLowerCase(), search.toLowerCase())
                    })).filter(item => item.score > root.scoreThreshold).sort((a, b) => b.score - a.score);
            return results.map(item => item.entry);
        }

        return Fuzzy.go(search, preparedEntries, {
            all: true,
            key: "name"
        }).map(r => {
            return r.obj.entry;
        });
    }

    function entryIsImage(entry) {
        return !!(/^\d+\t\[\[ binary data .* image\/[^ ]+ \]\]$/.test(entry));
    }

    function refresh() {
        readProc.buffer = [];
        readProc.running = true;
    }

    function copy(entry) {
        Quickshell.execDetached(["bash", "-c", `${root.binary} decode ${root.idOf(entry)} | wl-copy`]);
    }

    function paste(entry) {
        Quickshell.execDetached(["bash", "-c", `${root.binary} decode ${root.idOf(entry)} | wl-copy; ${root.pressPasteCommand}`]);
    }

    function superpaste(count, isImage = false) {
        const targetEntries = entries.filter(entry => {
            if (!isImage)
                return true;
            return entryIsImage(entry);
        }).slice(0, count);
        const pasteCommands = [...targetEntries].reverse().map(entry => `${root.binary} decode ${root.idOf(entry)} | wl-copy && sleep ${root.pasteDelay} && ${root.pressPasteCommand}`);
        Quickshell.execDetached(["bash", "-c", pasteCommands.join(` && sleep ${root.pasteDelay} && `)]);
    }

    Process {
        id: deleteProc
        property string entryId: ""
        command: [root.binary, "delete", "--type", "id", deleteProc.entryId]
        onExited: (exitCode, exitStatus) => {
            root.refresh();
        }
    }

    function deleteEntry(entry) {
        deleteProc.entryId = root.idOf(entry);
        deleteProc.running = true;
    }

    Process {
        id: wipeProc
        command: [root.binary, "db", "wipe"]
        onExited: (exitCode, exitStatus) => {
            root.refresh();
        }
    }

    function wipe() {
        wipeProc.running = true;
    }

    Connections {
        target: Quickshell
        function onClipboardTextChanged() {
            delayedUpdateTimer.restart();
        }
    }

    Timer {
        id: delayedUpdateTimer
        interval: Config.options.hacks.arbitraryRaceConditionDelay
        repeat: false
        onTriggered: {
            root.refresh();
        }
    }

    Process {
        id: readProc
        property list<string> buffer: []

        command: [root.binary, "list", "--format", "tsv"]

        stdout: SplitParser {
            onRead: line => {
                readProc.buffer.push(line);
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                root.entries = readProc.buffer;
            } else {
                console.error("[Clipboard] Failed to refresh with code", exitCode, "and status", exitStatus);
            }
        }
    }

    IpcHandler {
        target: "clipboard"

        function update(): void {
            root.refresh();
        }
    }
}
