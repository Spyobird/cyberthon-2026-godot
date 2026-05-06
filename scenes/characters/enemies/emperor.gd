class_name Emperor
extends Node2D

@onready var _interactable_component: InteractableComponent = $InteractableComponent
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
var _enemy_data = preload("res://resources/data/characters/emperor.tres")

var dialogue_spoken = false

func _ready() -> void:
	_interactable_component.interacted.connect(_on_interacted)

func _on_interacted(collider):
	print("Interacted with ", collider)
	if not dialogue_spoken:
		await GameManager.create_message_popup(
			[
				"...",
				"You’ve carved a path through legends to stand before me",
				"My generals. My champions. All fallen.",
				"You've earned your right to stand before the throne.",
				"Now prove that you're worthy of it."
			]
		)
		dialogue_spoken = true
	
	GameManager.player_data = collider.player_data
	GameManager.enemy_data = _enemy_data
	GameManager.enemy_node = self
	
	GameManager.battle_ended.connect(_on_battle_ended, CONNECT_ONE_SHOT)
	# Lock player movement
	GameManager.lock_movement(&"battle")
	
	# Pause BG music, play battle music
	GameManager.bgm_controller.battle_track = _enemy_data.battle_music
	GameManager.bgm_controller.set_volume(_enemy_data.battle_music_volume)
	GameManager.bgm_controller.pause_track()
	GameManager.bgm_controller.set_track(BGMController.TrackType.BATTLE)
	GameManager.bgm_controller.play_track(_enemy_data.battle_music_pos_offset)

	# Play scene transition effect
	GameManager.transition_controller.scene_transition_request_started.emit("res://scenes/battle.tscn", TransitionController.TransitionEffect.DIAGONAL_POPPING_SQUARES, 2.5)


func _on_battle_ended(defeated: bool):
	
	GameManager.bgm_controller.set_track(BGMController.TrackType.OVERWORLD)
	GameManager.bgm_controller.resume_track()
	
	GameManager.unlock_movement(&"battle")
	if defeated:
		_sprite.visible = false
		_interactable_component.is_collidable = false
		await GameManager.create_message_popup([
			"[color=midnight_blue]CONGRATULATIONS![/color]",
			"[color=midnight_blue]YOU HAVE BEATEN THE GAME, PROCEED TO COLLECT YOUR PRIZE![/color]"
		])
		queue_free()
