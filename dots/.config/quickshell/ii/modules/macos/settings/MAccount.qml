pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string userName: ""
    property string realName: ""
    property string email: ""
    property string iconFile: ""
    property int accountType: 0

    readonly property bool administrator: root.accountType === 1
    readonly property string displayName: root.realName.length > 0 ? root.realName : root.userName

    readonly property string object: `/org/freedesktop/Accounts/User${root.uid}`
    property int uid: -1

    function reload(): void {
        if (root.uid >= 0)
            readProc.running = true;
    }

    function set(property: string, signature: string, value: string): void {
        writeProc.exec(["busctl", "call", "org.freedesktop.Accounts", root.object, "org.freedesktop.Accounts.User", `Set${property}`, signature, value]);
    }

    Process {
        running: true
        command: ["id", "-u"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.uid = parseInt(this.text.trim());
                root.reload();
            }
        }
    }

    Process {
        id: readProc
        command: ["busctl", "--json=short", "call", "org.freedesktop.Accounts", root.object, "org.freedesktop.DBus.Properties", "GetAll", "s", "org.freedesktop.Accounts.User"]

        stdout: StdioCollector {
            onStreamFinished: {
                const record = JSON.parse(this.text).data?.[0] ?? {};
                root.userName = record.UserName?.data ?? "";
                root.realName = record.RealName?.data ?? "";
                root.email = record.Email?.data ?? "";
                root.iconFile = record.IconFile?.data ?? "";
                root.accountType = record.AccountType?.data ?? 0;
            }
        }
    }

    Process {
        id: writeProc
        onExited: root.reload()
    }
}
