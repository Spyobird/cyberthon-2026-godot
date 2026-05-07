class_name Magician
extends Node2D

const DIALOGUES = [
	"Alakazam!",
	"Look who we have here! Your fate was sealed on arrival.",
	"You amuse me!",
	"Magic is not for the weak-minded. The arcane bends only to me.",
	"Magic favors the master."
]

@onready var _interactable_component = $InteractableComponent
var _enemy_data = preload("res://resources/data/characters/magician.tres")
const KEY_SCENE = preload("res://scenes/interactables/key.tscn")


func _ready() -> void:
	_interactable_component.interacted.connect(_on_interacted)

func _on_interacted(collider):
	var message = DIALOGUES.pick_random()
	await GameManager.create_message_popup(message)
	
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
	
	GameManager.transition_controller.scene_transition_request_started.emit("res://scenes/battle.tscn", TransitionController.TransitionEffect.DIAGONAL_POPPING_SQUARES, 2.0)

func _on_battle_ended(defeated: bool):
	GameManager.bgm_controller.set_track(BGMController.TrackType.OVERWORLD)
	GameManager.bgm_controller.resume_track()
	GameManager.unlock_movement(&"battle")
	if defeated:	
		print("Magician defeated")
		var instance = KEY_SCENE.instantiate()
		get_parent().add_child(instance)
		instance.position = position
		GameManager.create_message_popup("Look! The magician dropped something...")
		queue_free()
