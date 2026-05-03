class_name SceneController
extends Node

@onready var world_2d = $World2D

var _current_2d_scenes = []

func _ready() -> void:
	GameManager.scene_controller = self
	overlay_2d_scene("res://scenes/levels/game.tscn")
	
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
