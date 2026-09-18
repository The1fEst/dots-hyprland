pragma Singleton
import Quickshell

/**
 * Starts applications in a systemd scope of their own rather than in the shell's.
 * What the shell spawns itself lives in the shell's unit: its memory counts as the
 * shell's, and stopping the shell takes it down with it.
 */
Singleton {
    id: root

    readonly property list<string> scopePrefix: ["systemd-run", "--user", "--scope", "--quiet", "--collect", "--"]

    function entry(desktopEntry: var): void {
        if (!desktopEntry)
            return;
        if (desktopEntry.runInTerminal || (desktopEntry.command?.length ?? 0) === 0) {
            desktopEntry.execute();
            return;
        }
        const argv = root.scopePrefix.concat(desktopEntry.command);
        if ((desktopEntry.workingDirectory?.length ?? 0) === 0) {
            Quickshell.execDetached(argv);
            return;
        }
        Quickshell.execDetached({
            command: argv,
            workingDirectory: desktopEntry.workingDirectory
        });
    }

    function action(desktopAction: var): void {
        if (!desktopAction)
            return;
        if ((desktopAction.command?.length ?? 0) === 0) {
            desktopAction.execute();
            return;
        }
        root.command(desktopAction.command);
    }

    function command(argv: list<string>): void {
        Quickshell.execDetached(root.scopePrefix.concat(argv));
    }

    function shell(line: string): void {
        if (line.length === 0)
            return;
        root.command(["bash", "-c", line]);
    }
}
