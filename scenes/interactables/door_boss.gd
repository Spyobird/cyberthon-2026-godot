class_name DoorBoss
extends Node2D

@onready var _interactable_component = $InteractableComponent
@onready var _door_sprite = $Sprites/Door
@onready var _animation_player = $Sprites/AnimationPlayer

var _is_open: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_interactable_component.is_collidable = true
	_interactable_component.interacted.connect(_on_interact)


func _on_interact(player):
	if not player is Player:
		return
	var closed = GameManager.create_message_popup(
		["You sense an [color=dark_red]intimidating presence[/color] up ahead.",
		"Proceed with caution."]
	)
	await closed

	# open the door
	_animation_player.play("door_opening")
	_interactable_component.interacted.disconnect(_on_interact)
	await _animation_player.animation_finished
	_is_open = true
