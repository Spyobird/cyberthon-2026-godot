class_name Enemy
extends Node2D

@onready var _interactable_component = $InteractableComponent
var _enemy_data = preload("res://resources/data/characters/enemy.tres")


func _ready() -> void:
	_interactable_component.interacted.connect(_on_interacted)

func _on_interacted(collider):
	print("Interacted with ", collider)
	await GameManager.create_message_popup(["Encountered %s!" % _enemy_data.name])
	
	GameManager.player_data = collider.player_data
	GameManager.enemy_data = _enemy_data
	GameManager.enemy_node = self
	
	GameManager.battle_ended.connect(_on_battle_ended, CONNECT_ONE_SHOT)
	# Lock player movement 
	GameManager.lock_movement(&"battle")
	
	# Pause BG music, play battle music
	GameManager.bgm_controller.battle_track = _enemy_data.battle_music
	GameManager.bgm_controller.pause_track()
	GameManager.bgm_controller.set_track(BGMController.TrackType.BATTLE)
	GameManager.bgm_controller.play_track(_enemy_data.battle_music_pos_offset)
	
	# Play scene transition effect
	GameManager.transition_controller.scene_transition_request_started.emit("res://scenes/battle.tscn", TransitionController.TransitionEffect.DIAGONAL_POPPING_SQUARES, 2.0)

func _on_battle_ended(defeated: bool):
	
	GameManager.bgm_controller.set_track(BGMController.TrackType.OVERWORLD)
	GameManager.bgm_controller.resume_track()
	
	GameManager.unlock_movement(&"battle")
	if defeated:
		print("Enemy defeated")
		queue_free()
	
