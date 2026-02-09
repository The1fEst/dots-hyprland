pragma Singleton
pragma ComponentBehavior: Bound

// Uses playerctl for player detection, metadata, and control.
// Does NOT use Quickshell.Services.Mpris players — all data comes from playerctl/D-Bus.

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris // for MprisPlaybackState, MprisLoopState enums only
import qs.modules.common

/**
 * A service that provides easy access to the active MPRIS player.
 * Player listing, metadata, and control are handled via playerctl.
 * Player objects are QtObject proxies, not Quickshell MprisPlayer instances.
 */
Singleton {
	id: root;

	// ---- Public API ----
	property var players: [];
	property var trackedPlayer: null;
	property var activePlayer: trackedPlayer ?? (players.length > 0 ? players[0] : null);
	signal trackChanged(reverse: bool);

	property bool __reverse: false;
	property var activeTrack;

	function isRealPlayer(player) { return true; }

	// ---- Player Proxy Component ----
	// Creates QtObject instances that mirror MprisPlayer's interface.
	Component {
		id: playerProxyComponent
		QtObject {
			property string scriptName: ""
			property string dbusName: ""
			property string desktopEntry: ""
			property string identity: ""

			property string trackTitle: ""
			property string trackArtist: ""
			property string trackAlbum: ""
			property string trackArtUrl: ""

			property int playbackState: MprisPlaybackState.Stopped
			property bool isPlaying: playbackState === MprisPlaybackState.Playing

			property real position: 0
			property real length: 0

			property int uniqueId: 0

			property bool canControl: true
			property bool canPlay: true
			property bool canPause: true
			property bool canTogglePlaying: true
			property bool canGoNext: true
			property bool canGoPrevious: true
			property bool canSeek: true

			property bool volumeSupported: false
			property real volume: 1.0
			property bool loopSupported: false
			property int loopState: MprisLoopState.None
			property bool shuffleSupported: false
			property bool shuffle: false

			signal postTrackChanged()

			// Controller reference for control actions
			property var _ctrl: null

			function togglePlaying() { _ctrl._runPlayerctl(scriptName, "play-pause"); }
			function previous() { _ctrl._runPlayerctl(scriptName, "previous"); }
			function next() { _ctrl._runPlayerctl(scriptName, "next"); }
			function pause() { _ctrl._runPlayerctl(scriptName, "pause"); }
			function seek(positionSeconds) { _ctrl._seekPlayer(scriptName, Math.max(0, positionSeconds)); }
		}
	}

	// ---- Internal state ----
	property var _playerMap: ({})
	property var _desktopEntryQueue: []

	// ---- Live streaming: playerctl --follow ----
	readonly property string _playerctlFormat: "{{playerInstance}}|||{{title}}|||{{artist}}|||{{album}}|||{{mpris:artUrl}}|||{{mpris:length}}|||{{status}}|||{{position}}"

	Process {
		id: followProc
		command: ["playerctl", "-a", "metadata", "--format", root._playerctlFormat, "--follow"]
		running: true
		stdout: SplitParser {
			onRead: data => {
				const line = data.trim();
				if (line.length > 0) root._processLine(line);
			}
		}
		onExited: (exitCode, _) => {
			// Restart if it dies unexpectedly
			restartTimer.running = true;
		}
	}

	Timer {
		id: restartTimer
		interval: 2000
		running: false
		repeat: false
		onTriggered: {
			followProc.running = true;
		}
	}

	// ---- Periodic position poll (follow doesn't update position continuously) ----
	Timer {
		id: pollTimer
		interval: 1000
		running: true
		repeat: true
		onTriggered: {
			if (!pollProc.running) pollProc.running = true;
		}
	}

	Process {
		id: pollProc
		command: ["playerctl", "-a", "metadata", "--format", root._playerctlFormat]
		running: false
		stdout: SplitParser {
			onRead: data => {
				const line = data.trim();
				if (line.length > 0) root._processLine(line);
			}
		}
	}

	function _processLine(line) {
		const parts = line.split("|||");
		if (parts.length < 8) return;

		const name = parts[0];
		if (!name) return;

		const title = parts[1] || "";
		const artist = parts[2] || "";
		const album = parts[3] || "";
		const artUrl = parts[4] || "";
		const lengthUs = parseInt(parts[5]) || 0;
		const statusStr = parts[6] || "";
		const posUs = parseInt(parts[7]) || 0;

		let proxy = _playerMap[name];
		let isNew = false;
		if (!proxy) {
			const baseName = name.split(".")[0];
			proxy = playerProxyComponent.createObject(root, {
				scriptName: name,
				dbusName: "org.mpris.MediaPlayer2." + name,
				desktopEntry: baseName,
				identity: baseName,
				uniqueId: Date.now() % 100000 + Math.floor(Math.random() * 1000),
				_ctrl: root,
			});
			_playerMap[name] = proxy;
			isNew = true;
			_desktopEntryQueue.push(name);
			if (_desktopEntryQueue.length === 1) _fetchNextDesktopEntry();
		}

		const oldTitle = proxy.trackTitle;

		proxy.trackTitle = title;
		proxy.trackArtist = artist;
		proxy.trackAlbum = album;
		proxy.trackArtUrl = artUrl;
		proxy.length = lengthUs / 1000000.0;
		proxy.position = posUs / 1000000.0;

		let newState;
		if (statusStr === "Playing") newState = MprisPlaybackState.Playing;
		else if (statusStr === "Paused") newState = MprisPlaybackState.Paused;
		else newState = MprisPlaybackState.Stopped;
		proxy.playbackState = newState;

		if (oldTitle !== title) proxy.postTrackChanged();

		if (isNew) {
			players = Object.values(_playerMap);
		}

		// Auto-select tracked player
		if (!trackedPlayer || (proxy.isPlaying && !trackedPlayer.isPlaying)) {
			trackedPlayer = proxy;
		}
	}

	// ---- Detect player disappearance ----
	Timer {
		id: cleanupTimer
		interval: 5000
		running: true
		repeat: true
		onTriggered: {
			if (!cleanupProc.running) cleanupProc.running = true;
		}
	}

	Process {
		id: cleanupProc
		command: ["playerctl", "-l"]
		running: false
		property var _names: []
		stdout: SplitParser {
			onRead: data => {
				const line = data.trim();
				if (line.length > 0) cleanupProc._names.push(line);
			}
		}
		onExited: (exitCode, _) => {
			const activeNames = new Set(cleanupProc._names);
			cleanupProc._names = [];
			let changed = false;
			for (const name in root._playerMap) {
				if (!activeNames.has(name)) {
					const p = root._playerMap[name];
					delete root._playerMap[name];
					p.destroy();
					changed = true;
				}
			}
			if (changed) {
				root.players = Object.values(root._playerMap);
				if (root.trackedPlayer && !root.players.includes(root.trackedPlayer)) {
					root.trackedPlayer = root.players.length > 0 ? root.players[0] : null;
				}
			}
			// Handle case where playerctl -l returns nothing (no players)
			if (exitCode !== 0 && Object.keys(root._playerMap).length > 0) {
				for (const name in root._playerMap) {
					root._playerMap[name].destroy();
					delete root._playerMap[name];
				}
				root.players = [];
				root.trackedPlayer = null;
			}
		}
	}

	// ---- Desktop entry fetch (via D-Bus, queued) ----
	function _fetchNextDesktopEntry() {
		while (_desktopEntryQueue.length > 0) {
			const name = _desktopEntryQueue[0];
			if (_playerMap[name]) break;
			_desktopEntryQueue.shift();
		}
		if (_desktopEntryQueue.length === 0) return;
		const name = _desktopEntryQueue[0];
		deFetchProc.command = ["bash", "-c",
			"dbus-send --session --print-reply --dest='org.mpris.MediaPlayer2." + name + "' " +
			"/org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get " +
			"string:org.mpris.MediaPlayer2 string:DesktopEntry 2>/dev/null | " +
			"grep 'string \"' | tail -1 | sed 's/.*string \"//;s/\"$//'"];
		deFetchProc._targetName = name;
		deFetchProc.running = true;
	}

	Process {
		id: deFetchProc
		property string _targetName: ""
		running: false
		stdout: SplitParser {
			onRead: data => {
				const entry = data.trim();
				if (entry && root._playerMap[deFetchProc._targetName]) {
					root._playerMap[deFetchProc._targetName].desktopEntry = entry;
				}
			}
		}
		onExited: (exitCode, _) => {
			root._desktopEntryQueue.shift();
			root._fetchNextDesktopEntry();
		}
	}

	// ---- Control via playerctl ----
	function _runPlayerctl(name, action) {
		console.log("[MprisController] Control: playerctl -p " + name + " " + action);
		controlProc.command = ["playerctl", "-p", name, action];
		controlProc.running = true;
	}

	function _seekPlayer(name, positionSeconds) {
		console.log("[MprisController] Seek: playerctl -p " + name + " position " + positionSeconds);
		controlProc.command = ["playerctl", "-p", name, "position", positionSeconds.toString()];
		controlProc.running = true;
	}

	Process {
		id: controlProc
		running: false
		onExited: (exitCode, _) => {
			// Re-poll immediately after control action for snappy UI
			if (!pollProc.running) pollProc.running = true;
		}
	}

	// ---- Track playing state via Instantiator ----
	Instantiator {
		model: root.players;

		Connections {
			required property var modelData;
			target: modelData;

			Component.onCompleted: {
				if (root.trackedPlayer == null || modelData.isPlaying) {
					root.trackedPlayer = modelData;
				}
			}

			Component.onDestruction: {
				if (root.trackedPlayer == null || !root.trackedPlayer.isPlaying) {
					for (const player of root.players) {
						if (player.isPlaying) {
							root.trackedPlayer = player;
							break;
						}
					}
					if (root.trackedPlayer == null && root.players.length != 0) {
						root.trackedPlayer = root.players[0];
					}
				}
			}

			function onPlaybackStateChanged() {
				if (root.trackedPlayer !== modelData) root.trackedPlayer = modelData;
			}
		}
	}

	// ---- Track metadata updates ----
	Connections {
		target: activePlayer

		function onPostTrackChanged() {
			root.updateTrack();
		}

		function onTrackArtUrlChanged() {
			if (root.activePlayer && root.activeTrack
				&& root.activePlayer.uniqueId == root.activeTrack.uniqueId
				&& root.activePlayer.trackArtUrl != root.activeTrack.artUrl) {
				const r = root.__reverse;
				root.updateTrack();
				root.__reverse = r;
			}
		}
	}

	onActivePlayerChanged: this.updateTrack();

	function updateTrack() {
		this.activeTrack = {
			uniqueId: this.activePlayer?.uniqueId ?? 0,
			artUrl: this.activePlayer?.trackArtUrl ?? "",
			title: this.activePlayer?.trackTitle || Translation.tr("Unknown Title"),
			artist: this.activePlayer?.trackArtist || Translation.tr("Unknown Artist"),
			album: this.activePlayer?.trackAlbum || Translation.tr("Unknown Album"),
		};
		this.trackChanged(__reverse);
		this.__reverse = false;
	}

	// ---- Public control API ----
	property bool isPlaying: this.activePlayer?.isPlaying ?? false;

	property bool canTogglePlaying: this.activePlayer?.canTogglePlaying ?? false;
	function togglePlaying() {
		if (this.activePlayer) this.activePlayer.togglePlaying();
	}

	property bool canGoPrevious: this.activePlayer?.canGoPrevious ?? false;
	function previous() {
		if (this.activePlayer) {
			this.__reverse = true;
			this.activePlayer.previous();
		}
	}

	property bool canGoNext: this.activePlayer?.canGoNext ?? false;
	function next() {
		if (this.activePlayer) {
			this.__reverse = false;
			this.activePlayer.next();
		}
	}

	property bool canChangeVolume: false;

	property bool loopSupported: this.activePlayer?.loopSupported ?? false;
	property var loopState: this.activePlayer?.loopState ?? MprisLoopState.None;
	function setLoopState(loopState) {}

	property bool shuffleSupported: this.activePlayer?.shuffleSupported ?? false;
	property bool hasShuffle: this.activePlayer?.shuffle ?? false;
	function setShuffle(shuffle) {}

	function setActivePlayer(player) {
		const targetPlayer = player ?? root.players[0];
		if (targetPlayer && this.activePlayer) {
			this.__reverse = root.players.indexOf(targetPlayer) < root.players.indexOf(this.activePlayer);
		} else {
			this.__reverse = false;
		}
		this.trackedPlayer = targetPlayer;
	}

	// ---- IPC ----
	IpcHandler {
		target: "mpris"

		function pauseAll(): void {
			controlProc.command = ["playerctl", "-a", "pause"];
			controlProc.running = true;
		}

		function playPause(): void { root.togglePlaying(); }
		function previous(): void { root.previous(); }
		function next(): void { root.next(); }
	}
}
