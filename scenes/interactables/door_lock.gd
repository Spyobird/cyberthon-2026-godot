class_name DoorLocked
extends Node2D

const LOCKED_MESSAGES = [
	"Hmm... This door seems to be locked.",
	"Maybe I should avoid this for now..."
]

@onready var _interactable_component = $InteractableComponent
@onready var _animation_player = $Sprites/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_interactable_component.is_collidable = true
	_interactable_component.interacted.connect(_on_interact)
	
func _on_interact(player):
	if not player is Player:
		return		
	else:
		GameManager.create_message_popup(LOCKED_MESSAGES)
