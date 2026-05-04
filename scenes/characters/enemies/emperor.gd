class_name Emperor
extends Node2D

@onready var _interactable_component = $InteractableComponent
var _enemy_data = preload("res://resources/data/characters/emperor.tres")


func _ready() -> void:
	_interactable_component.interacted.connect(_on_interacted)

func _on_interacted(collider):
	print("Interacted with ", collider)
	await GameManager.create_message_popup(
		[
		"...",
		"You’ve carved a path through legends to stand before me",
		"My generals. My champions. All fallen.",
		"You've earned your right to stand before the throne.",
		"Now prove that you're worthy of it."
		]
	)
	
	GameManager.player_data = collider.player_data
	GameManager.enemy_data = _enemy_data
	GameManager.enemy_node = self
	
	GameManager.scene_controller.overlay_2d_scene("res://scenes/battle.tscn")
