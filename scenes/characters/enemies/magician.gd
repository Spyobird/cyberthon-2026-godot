class_name Magician
extends Node2D

@onready var _interactable_component = $InteractableComponent
var _enemy_data = preload("res://resources/data/characters/magician.tres")

func _ready() -> void:
	_interactable_component.interacted.connect(_on_interacted)

func _on_interacted(collider):
	await GameManager.create_message_popup("Alakazam!")
	
	GameManager.player_data = collider.player_data
	GameManager.enemy_data = _enemy_data
	GameManager.enemy_node = self
	
	GameManager.battle_ended.connect(_on_battle_ended, CONNECT_ONE_SHOT)
	GameManager.scene_controller.overlay_2d_scene("res://scenes/battle.tscn")

func _on_battle_ended(defeated: bool):
	if defeated:
		print("Magician defeated")
		queue_free()
