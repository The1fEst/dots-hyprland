pragma Singleton
pragma ComponentBehavior: Bound

// From https://git.outfoxxed.me/outfoxxed/nixnew
// It does not have a license, but the author is okay with redistribution.

import QtQml.Models
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import qs.modules.common

/**
 * A service that provides easy access to the active Mpris player.
 */
Singleton {
	id: root;
	property list<MprisPlayer> players: Mpris.players.values;
	property MprisPlayer trackedPlayer: null;
	property MprisPlayer activePlayer: trackedPlayer ?? Mpris.players.values[0] ?? null;
	// playerctld mirrors whichever player is active, so it always duplicates another entry.
	readonly property list<MprisPlayer> visiblePlayers: {
		const result = [];
		for (const player of Mpris.players.values) {
			if (!player.dbusName.includes("playerctld")) result.push(player);
		}
		return result;
	}
	// trackedPlayer follows the last playback state change, including pauses, so it can
	// point at a silent player while another one plays.
	readonly property MprisPlayer currentPlayer: {
		for (const player of root.visiblePlayers) {
			if (player.isPlaying) return player;
		}
		if (root.visiblePlayers.indexOf(root.activePlayer) !== -1) return root.activePlayer;
		return root.visiblePlayers[0] ?? null;
	}
	signal trackChanged(reverse: bool);

	property bool __reverse: false;
	property var activeTrack;

	property var knownLengths: ({});

	function trackKey(player: MprisPlayer): string {
		return `${player.metadata?.["xesam:url"] ?? ""}|${player.trackTitle ?? ""}`;
	}

	function trackLength(player: MprisPlayer): real {
		if (!player) return 0;
		if (player.lengthSupported) return player.length;
		const known = root.knownLengths[player.dbusName];
		return (known && known.key === root.trackKey(player)) ? known.length : 0;
	}

	function hasTrackLength(player: MprisPlayer): bool {
		return root.trackLength(player) > 0;
	}

	function rememberLength(player: MprisPlayer): void {
		if (!player?.lengthSupported || player.length <= 0) return;
		const key = root.trackKey(player);
		const known = root.knownLengths[player.dbusName];
		if (known && known.key === key && known.length === player.length) return;

		const lengths = Object.assign({}, root.knownLengths);
		lengths[player.dbusName] = { key: key, length: player.length };
		root.knownLengths = lengths;
	}

	Timer {
		running: {
			for (const player of Mpris.players.values) {
				if (player.isPlaying) return true;
			}
			return false;
		}
		interval: Config.options.resources.updateInterval
		repeat: true
		onTriggered: {
			for (const player of Mpris.players.values) {
				if (player.isPlaying) player.positionChanged();
			}
		}
	}

	Instantiator {
		model: Mpris.players
		delegate: QtObject {
			id: lengthMemory
			required property MprisPlayer modelData

			property Connections playerConnections: Connections {
				target: lengthMemory.modelData

				function onLengthChanged() { root.rememberLength(lengthMemory.modelData); }
				function onLengthSupportedChanged() { root.rememberLength(lengthMemory.modelData); }
				function onPostTrackChanged() { root.rememberLength(lengthMemory.modelData); }
			}

			Component.onCompleted: root.rememberLength(lengthMemory.modelData)
		}
	}

	// Original stuff from fox below
	Instantiator {
		model: Mpris.players;

		Connections {
			required property MprisPlayer modelData;
			target: modelData;

			Component.onCompleted: {
				if (root.trackedPlayer == null || modelData.isPlaying) {
					root.trackedPlayer = modelData;
				}
			}

			Component.onDestruction: {
				if (root.trackedPlayer == null || !root.trackedPlayer.isPlaying) {
					for (const player of Mpris.players.values) {
						if (player.isPlaying) {
							root.trackedPlayer = player;
							break;
						}
					}

					if (trackedPlayer == null && Mpris.players.values.length != 0) {
						trackedPlayer = Mpris.players.values[0];
					}
				}
			}

			function onPlaybackStateChanged() {
				if (root.trackedPlayer !== modelData) root.trackedPlayer = modelData;
			}
		}
	}

	Connections {
		target: activePlayer

		function onPostTrackChanged() {
			root.updateTrack();
		}

		function onTrackArtUrlChanged() {
			// console.log("arturl:", activePlayer.trackArtUrl)
			// root.updateTrack();
			if (root.activePlayer.uniqueId == root.activeTrack.uniqueId && root.activePlayer.trackArtUrl != root.activeTrack.artUrl) {
				// cantata likes to send cover updates *BEFORE* updating the track info.
				// as such, art url changes shouldn't be able to break the reverse animation
				const r = root.__reverse;
				root.updateTrack();
				root.__reverse = r;

			}
		}
	}

	onActivePlayerChanged: this.updateTrack();

	function updateTrack() {
		//console.log(`update: ${this.activePlayer?.trackTitle ?? ""} : ${this.activePlayer?.trackArtists}`)
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

	property bool isPlaying: this.activePlayer && this.activePlayer.isPlaying;
	property bool canTogglePlaying: this.activePlayer?.canTogglePlaying ?? false;
	function togglePlaying() {
		if (this.canTogglePlaying) this.activePlayer.togglePlaying();
	}

	property bool canGoPrevious: this.activePlayer?.canGoPrevious ?? false;
	function previous() {
		if (this.canGoPrevious) {
			this.__reverse = true;
			this.activePlayer.previous();
		}
	}

	property bool canGoNext: this.activePlayer?.canGoNext ?? false;
	function next() {
		if (this.canGoNext) {
			this.__reverse = false;
			this.activePlayer.next();
		}
	}

	property bool canChangeVolume: this.activePlayer && this.activePlayer.volumeSupported && this.activePlayer.canControl;

	property bool loopSupported: this.activePlayer && this.activePlayer.loopSupported && this.activePlayer.canControl;
	property var loopState: this.activePlayer?.loopState ?? MprisLoopState.None;
	function setLoopState(loopState: var) {
		if (this.loopSupported) {
			this.activePlayer.loopState = loopState;
		}
	}

	property bool shuffleSupported: this.activePlayer && this.activePlayer.shuffleSupported && this.activePlayer.canControl;
	property bool hasShuffle: this.activePlayer?.shuffle ?? false;
	function setShuffle(shuffle: bool) {
		if (this.shuffleSupported) {
			this.activePlayer.shuffle = shuffle;
		}
	}

	function setActivePlayer(player: MprisPlayer) {
		const targetPlayer = player ?? Mpris.players[0];
		console.log(`[Mpris] Active player ${targetPlayer} << ${activePlayer}`)

		if (targetPlayer && this.activePlayer) {
			this.__reverse = Mpris.players.indexOf(targetPlayer) < Mpris.players.indexOf(this.activePlayer);
		} else {
			// always animate forward if going to null
			this.__reverse = false;
		}

		this.trackedPlayer = targetPlayer;
	}

	IpcHandler {
		target: "mpris"

		function pauseAll(): void {
			for (const player of Mpris.players.values) {
				if (player.canPause) {
					player.pause();
				}
			}
		}

		function playPause(): void { root.togglePlaying(); }
		function previous(): void { root.previous(); }

		function next(): void {
			if (root.canGoNext) {
				root.next();
				return;
			}
			const player = root.activePlayer;
			if (player?.canSeek && player.lengthSupported) player.position = player.length;
		}
	}
}
