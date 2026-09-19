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

    property bool changingPassword: false
    property string passwordError: ""
    signal passwordAccepted()

    property string passwordAnswers: ""
    property string passwordOutput: ""

    function changePassword(current: string, next: string): void {
        if (passwdProc.running)
            return;
        root.passwordError = "";
        root.passwordOutput = "";
        root.passwordAnswers = `${current}\n${next}\n${next}\n`;
        root.changingPassword = true;
        passwdProc.running = true;
    }

    Process {
        id: passwdProc
        command: ["passwd"]
        stdinEnabled: true
        environment: ({
            LC_ALL: "C",
            LANG: "C"
        })

        onStarted: {
            passwdProc.write(root.passwordAnswers);
            root.passwordAnswers = "";
        }

        stdout: StdioCollector {
            onStreamFinished: root.passwordOutput += this.text
        }

        stderr: StdioCollector {
            onStreamFinished: root.passwordOutput += this.text
        }

        onExited: {
            const output = root.passwordOutput;
            root.passwordAnswers = "";
            root.passwordOutput = "";
            root.changingPassword = false;
            if (output.includes("updated successfully")) {
                root.passwordAccepted();
                return;
            }
            const complaints = output.split("passwd:").slice(1).map(part => part.split("\n")[0].trim()).filter(line => line.length > 0 && line !== "password unchanged");
            root.passwordError = complaints.pop() ?? "Could not change the password";
        }
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
                root.accountType = record.AccountType?.data ?? 0;
                const icon = record.IconFile?.data ?? "";
                iconProc.candidate = icon;
                if (icon.length === 0)
                    root.iconFile = "";
                else
                    iconProc.exec(["test", "-f", icon]);
            }
        }
    }

    Process {
        id: iconProc
        property string candidate: ""
        onExited: exitCode => root.iconFile = exitCode === 0 ? iconProc.candidate : ""
    }

    Process {
        id: writeProc
        onExited: root.reload()
    }
}
