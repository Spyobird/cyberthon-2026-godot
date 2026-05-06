class_name SceneController
extends Node

@onready var world_2d = $World2D

var _current_2d_scenes = []
enum GAME_STAGE_TYPE { EMPEROR, RFID, RE }
@export var game_stage = GAME_STAGE_TYPE.EMPEROR

func _ready() -> void:
	GameManager.scene_controller = self

	# Must be added before any scene load so GameManager.transition_controller
	# is populated before a transition can be requested.
	var transition_controller: TransitionController = load("res://scenes/transition_controller.tscn").instantiate()
	add_child(transition_controller)

	var bgm_controller: BGMController = load("res://scenes/bgm_controller.tscn").instantiate()
	add_child(bgm_controller)
	
	var bgm_track: AudioStream
	var main_game_scene: String
	
	match game_stage:
		GAME_STAGE_TYPE.RFID:
			bgm_track = load("res://assets/audio/bg/normal.mp3")
			main_game_scene = "res://scenes/levels/game_rfid.tscn"
		GAME_STAGE_TYPE.EMPEROR:
			bgm_track = load("res://assets/audio/bg/emperor.mp3")
			main_game_scene = "res://scenes/levels/emperor_stage.tscn"
		GAME_STAGE_TYPE.RE:
			bgm_track = load("res://assets/audio/bg/normal.mp3")
			main_game_scene = "res://scenes/levels/game_re.tscn"
	
	# Add track based on level
	bgm_controller.overworld_track = bgm_track
	bgm_controller.set_track(BGMController.TrackType.OVERWORLD)
	bgm_controller.set_volume(0.6)
	bgm_controller.play_track()

	overlay_2d_scene(main_game_scene)
	
	
func overlay_2d_scene(new_scene: String) -> Error:
	if len(_current_2d_scenes) > 0:
		var current_scene = _current_2d_scenes.back()
		current_scene.process_mode = PROCESS_MODE_DISABLED
		current_scene.visible = false
	
	var new = load(new_scene).instantiate()
	world_2d.add_child(new)
	_current_2d_scenes.append(new)
	return OK

func pop_2d_scene() -> Error:
	if len(_current_2d_scenes) <= 0: # cannot pop if there is only 1 scene
		return FAILED
	var current_scene = _current_2d_scenes.pop_back()
	current_scene.queue_free()
	
	var next_scene = _current_2d_scenes.back()
	next_scene.process_mode = PROCESS_MODE_INHERIT
	next_scene.visible = true
	return OK
