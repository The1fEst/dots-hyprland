pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var layouts: []
    property var optionGroups: []

    readonly property string tool: Quickshell.shellPath("scripts/system/xkb-layouts.py")

    readonly property list<string> codes: root.split(HyprlandOptions.text("input:kb_layout"))
    readonly property list<string> variants: root.split(HyprlandOptions.text("input:kb_variant"))
    readonly property list<string> options: root.split(HyprlandOptions.text("input:kb_options"))

    function split(value: string): list<string> {
        return value.length === 0 ? [] : value.split(",").map(part => part.trim());
    }

    function layoutOf(code: string): var {
        return root.layouts.find(layout => layout.code === code) ?? null;
    }

    function variantsOf(code: string): var {
        return root.layoutOf(code)?.variants ?? [];
    }

    function nameOf(code: string, variant: string): string {
        const layout = root.layoutOf(code);
        if (!layout)
            return code;
        if (variant.length === 0)
            return layout.name;
        return layout.variants.find(entry => entry.code === variant)?.name ?? `${layout.name} (${variant})`;
    }

    function variantAt(index: int): string {
        return root.variants[index] ?? "";
    }

    function apply(codes: list<string>, variants: list<string>): void {
        HyprlandOptions.set("input:kb_layout", codes.join(","));
        HyprlandOptions.set("input:kb_variant", variants.join(","));
    }

    function optionsWithout(group: string): list<string> {
        const prefix = `${group}:`;
        return root.options.filter(option => !option.startsWith(prefix));
    }

    function optionOf(group: string): string {
        const prefix = `${group}:`;
        return root.options.find(option => option.startsWith(prefix)) ?? "";
    }

    function setOption(group: string, option: string): void {
        const kept = root.optionsWithout(group);
        if (option.length > 0)
            kept.push(option);
        HyprlandOptions.set("input:kb_options", kept.join(","));
    }

    Process {
        running: true
        command: ["python3", root.tool]

        stdout: StdioCollector {
            onStreamFinished: {
                const catalogue = JSON.parse(this.text.length > 0 ? this.text : "{}");
                root.layouts = catalogue.layouts ?? [];
                root.optionGroups = catalogue.optionGroups ?? [];
            }
        }
    }
}
