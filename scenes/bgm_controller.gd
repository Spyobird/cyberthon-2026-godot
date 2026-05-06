class_name BGMController
extends Node

enum TrackType {
	NONE,
	OVERWORLD,
	BATTLE,
}

@export_group("Tracks")
@export var overworld_track: AudioStream
@export var battle_track: AudioStream

@onready var _player: AudioStreamPlayer = $AudioStreamPlayer
var previous_playback_pos: float = 0.0

func _ready() -> void:
	GameManager.bgm_controller = self

func set_track(track: TrackType) -> void:
	var stream := _get_stream(track)
	_enable_loop(stream)
	_player.stream = stream

func play_track(offset: float = 0.0) -> void:
	_player.stream_paused = false
	if not _player.playing:
		_player.play(offset)

func resume_track() -> void:
	play_track(previous_playback_pos)
	
func pause_track() -> void:
	_player.stream_paused = true
	previous_playback_pos = _player.get_playback_position()

func set_volume(percent: float) -> void:
	_player.volume_db = linear_to_db(clampf(percent, 0.0, 1.0))

func _enable_loop(stream: AudioStream) -> void:
	(stream as AudioStreamMP3).loop = true

func _get_stream(track: TrackType) -> AudioStream:
	match track:
		TrackType.OVERWORLD:
			return overworld_track
		TrackType.BATTLE:
			return battle_track
		_:
			return null
