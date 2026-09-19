pragma Singleton
pragma ComponentBehavior: Bound
import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

/**
 * Screensharing and mic activity.
 */
Singleton {
    id: root

    readonly property bool screenSharing: Pipewire.linkGroups.values.some(group => group.source?.type === PwNodeType.VideoSource)
    readonly property bool micActive: Pipewire.linkGroups.values.some(group => group.source?.type === PwNodeType.AudioSource && group.target?.type === PwNodeType.AudioInStream)
}
