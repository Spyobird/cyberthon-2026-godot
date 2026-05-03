class_name DoorBoss
extends Node2D

#const _DOOR_SPRITES = [
	#preload("res://assets/door/door_closed.tres"),
	#preload("res://assets/door/door_open.tres")
#]

@onready var _interactable_component = $InteractableComponent
@onready var _door_sprite = $Sprites/Door
@onready var _animation_player = $Sprites/AnimationPlayer

var _is_open: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_interactable_component.is_collidable = true
	_interactable_component.interacted.connect(_on_interact)

	#_door_sprite.texture = _DOOR_SPRITES[0]


func _on_interact(player):
	if not player is Player:
		return
	var closed = GameManager.create_message_popup(
		["You sense an [color=red]intimidating presence[/color] up ahead.",
		"Proceed with caution."]
	)
	await closed

	# open the door
	_animation_player.play("door_opening")
	_is_open = true
	_interactable_component.interacted.disconnect(_on_interact)
	#_interactable_component.is_collidable = false
	#_door_sprite.texture = _DOOR_SPRITES[1]
