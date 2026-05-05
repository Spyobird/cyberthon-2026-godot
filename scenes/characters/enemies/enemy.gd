class_name Enemy
extends Node2D

const KEY_SCENE = preload("res://scenes/interactables/key.tscn")

@onready var _interactable_component = $InteractableComponent
var _enemy_data = preload("res://resources/data/characters/enemy.tres")


func _ready() -> void:
	_interactable_component.interacted.connect(_on_interacted)

func _on_interacted(collider):
	print("Interacted with ", collider)
	await GameManager.create_message_popup(["This is an interactive popup!"])
	
	GameManager.player_data = collider.player_data
	GameManager.enemy_data = _enemy_data
	GameManager.enemy_node = self
	
	GameManager.battle_ended.connect(_on_battle_ended, CONNECT_ONE_SHOT)
	# Lock player movement 
	GameManager.lock_movement(&"battle")
	# Play scene transition effect
	GameManager.transition_controller.scene_transition_request_started.emit("res://scenes/battle.tscn", TransitionController.TransitionEffect.CROSS_SHAPED, 1.5)

func _on_battle_ended(defeated: bool):
	GameManager.unlock_movement(&"battle")
	if defeated:
		print("Enemy defeated")
		var instance = KEY_SCENE.instantiate()
		get_parent().add_child(instance)
		instance.position = position
		queue_free()
	
