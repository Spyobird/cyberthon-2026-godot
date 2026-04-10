class_name Enemy
extends Node2D

@onready var _interactable_component = $InteractableComponent
var _enemy_data = preload("res://resources/data/characters/enemy.tres")

func _ready() -> void:
	_interactable_component.interacted.connect(_on_interacted)

func _on_interacted(collider):
	print("Interacted with ", collider)
	await GameManager.create_message_popup("This is an interactive popup!")
	
	GameManager.player_data = collider.player_data
	GameManager.enemy_data = _enemy_data
	GameManager.enemy_node = self
	
	GameManager.scene_controller.overlay_2d_scene("res://scenes/battle.tscn")
