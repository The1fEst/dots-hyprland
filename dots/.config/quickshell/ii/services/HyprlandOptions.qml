pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root

    readonly property list<string> generalNames: ["general:gaps_in", "general:gaps_out", "general:gaps_workspaces", "general:border_size", "general:resize_on_border", "general:extend_border_grab_area", "general:hover_icon_on_border", "general:allow_tearing", "general:layout", "general:no_focus_fallback", "general:snap:enabled", "general:snap:window_gap", "general:snap:monitor_gap", "general:snap:border_overlap"]
    readonly property list<string> decorationNames: ["decoration:rounding", "decoration:rounding_power", "decoration:active_opacity", "decoration:inactive_opacity", "decoration:fullscreen_opacity", "decoration:dim_inactive", "decoration:dim_strength", "decoration:dim_special", "decoration:dim_around", "decoration:border_part_of_window", "decoration:blur:enabled", "decoration:blur:size", "decoration:blur:passes", "decoration:blur:xray", "decoration:blur:noise", "decoration:blur:contrast", "decoration:blur:brightness", "decoration:blur:vibrancy", "decoration:blur:vibrancy_darkness", "decoration:blur:special", "decoration:blur:popups", "decoration:blur:ignore_opacity", "decoration:shadow:enabled", "decoration:shadow:range", "decoration:shadow:render_power", "decoration:shadow:sharp", "decoration:shadow:scale", "animations:enabled", "animations:workspace_wraparound"]
    readonly property list<string> keyboardNames: ["input:kb_layout", "input:kb_variant", "input:kb_model", "input:kb_options", "input:kb_rules", "input:numlock_by_default", "input:resolve_binds_by_sym", "input:repeat_rate", "input:repeat_delay"]
    readonly property list<string> pointerNames: ["input:sensitivity", "input:accel_profile", "input:force_no_accel", "input:left_handed", "input:scroll_points", "input:scroll_method", "input:scroll_button", "input:scroll_button_lock", "input:scroll_factor", "input:natural_scroll", "input:follow_mouse", "input:follow_mouse_threshold", "input:focus_on_close", "input:mouse_refocus", "input:float_switch_override_focus", "input:special_fallthrough", "input:off_window_axis_events", "input:emulate_discrete_scroll", "input:touchpad:disable_while_typing", "input:touchpad:natural_scroll", "input:touchpad:scroll_factor", "input:touchpad:middle_button_emulation", "input:touchpad:tap_button_map", "input:touchpad:clickfinger_behavior", "input:touchpad:tap-to-click", "input:touchpad:drag_lock", "input:touchpad:tap-and-drag", "input:touchpad:flip_x", "input:touchpad:flip_y"]
    readonly property list<string> cursorNames: ["cursor:sync_gsettings_theme", "cursor:no_hardware_cursors", "cursor:no_break_fs_vrr", "cursor:min_refresh_rate", "cursor:hotspot_padding", "cursor:inactive_timeout", "cursor:no_warps", "cursor:persistent_warps", "cursor:warp_on_change_workspace", "cursor:default_monitor", "cursor:zoom_factor", "cursor:zoom_rigid", "cursor:enable_hyprcursor", "cursor:hide_on_key_press", "cursor:hide_on_touch", "cursor:use_cpu_buffer", "cursor:warp_back_after_non_mouse_input"]
    readonly property list<string> gestureNames: ["gestures:workspace_swipe_distance", "gestures:workspace_swipe_min_speed_to_force", "gestures:workspace_swipe_cancel_ratio", "gestures:workspace_swipe_create_new", "gestures:workspace_swipe_direction_lock", "gestures:workspace_swipe_direction_lock_threshold", "gestures:workspace_swipe_forever"]
    readonly property list<string> layoutNames: ["dwindle:force_split", "dwindle:preserve_split", "dwindle:smart_split", "dwindle:smart_resizing", "dwindle:permanent_direction_override", "dwindle:special_scale_factor", "dwindle:split_width_multiplier", "dwindle:use_active_for_splits", "dwindle:default_split_ratio", "dwindle:split_bias", "master:allow_small_split", "master:special_scale_factor", "master:mfact", "master:new_status", "master:new_on_top", "master:new_on_active", "master:orientation", "master:slave_count_for_center_master", "master:center_ignores_reserved", "master:smart_resizing", "master:drop_at_cursor"]
    readonly property list<string> behaviourNames: ["misc:disable_hyprland_logo", "misc:disable_splash_rendering", "misc:font_family", "misc:vrr", "misc:mouse_move_enables_dpms", "misc:key_press_enables_dpms", "misc:always_follow_on_dnd", "misc:layers_hog_keyboard_focus", "misc:animate_manual_resizes", "misc:animate_mouse_windowdragging", "misc:disable_autoreload", "misc:enable_swallow", "misc:swallow_regex", "misc:focus_on_activate", "misc:mouse_move_focuses_monitor", "misc:allow_session_lock_restore", "misc:session_lock_xray", "misc:background_color", "misc:close_special_on_empty", "misc:exit_window_retains_fullscreen", "misc:initial_workspace_tracking", "misc:middle_click_paste", "misc:render_unfocused_fps", "misc:on_focus_under_fullscreen", "binds:pass_mouse_when_bound", "binds:scroll_event_delay", "binds:workspace_back_and_forth", "binds:allow_workspace_cycles", "binds:workspace_center_on", "binds:focus_preferred_method", "binds:ignore_group_lock", "binds:movefocus_cycles_fullscreen", "binds:disable_keybind_grabbing", "binds:window_direction_monitor_fallback", "binds:drag_threshold", "binds:hide_special_on_workspace_change"]
    readonly property list<string> renderNames: ["render:direct_scanout", "render:expand_undersized_textures", "render:xp_mode", "render:ctm_animation", "render:cm_enabled", "render:cm_auto_hdr", "render:new_render_scheduling", "xwayland:enabled", "xwayland:use_nearest_neighbor", "xwayland:force_zero_scaling", "opengl:nvidia_anti_flicker"]

    readonly property list<string> names: root.generalNames.concat(root.decorationNames, root.keyboardNames, root.pointerNames, root.cursorNames, root.gestureNames, root.layoutNames, root.behaviourNames, root.renderNames)

    property var options: ({})

    readonly property string tool: Quickshell.shellPath("scripts/system/hypr-config.py")
    readonly property string file: Quickshell.env("HOME") + "/.config/hypr/settings.lua"

    function number(name: string): real {
        const raw = root.options[name];
        return typeof raw === "string" ? parseFloat(raw) : (raw ?? 0);
    }

    function numberOr(name: string, fallback: real): real {
        return root.options[name] === undefined ? fallback : root.number(name);
    }

    function flag(name: string): bool {
        return root.options[name] === true;
    }

    function text(name: string): string {
        const raw = root.options[name];
        if (raw === undefined)
            return "";
        const value = String(raw);
        return value === "[[EMPTY]]" ? "" : value;
    }

    property var pending: ({})

    function set(name: string, value: var): void {
        root.pending[name] = value;
        writeTimer.restart();
    }

    function reload(): void {
        readProc.running = true;
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "configreloaded")
                root.reload();
        }
    }

    Timer {
        id: writeTimer
        interval: 50
        onTriggered: {
            if (writeProc.running) {
                writeTimer.restart();
                return;
            }
            const names = Object.keys(root.pending);
            if (names.length === 0)
                return;
            const pairs = names.map(name => `${name}=${root.pending[name]}`);
            root.pending = ({});
            writeProc.exec(["python3", root.tool, root.file].concat(pairs));
        }
    }

    Process {
        id: readProc
        running: true
        command: ["python3", root.tool, "--read"].concat([...root.names])

        stdout: StdioCollector {
            onStreamFinished: root.options = JSON.parse(this.text.length > 0 ? this.text : "{}")
        }
    }

    Process {
        id: writeProc
        onExited: applyProc.running = true
    }

    Process {
        id: applyProc
        command: ["hyprctl", "reload"]
        onExited: root.reload()
    }
}
