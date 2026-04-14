class_name Door
extends Node2D

const _DOOR_SPRITES = [
	preload("res://assets/door/door_closed.tres"),
	preload("res://assets/door/door_open.tres")
]
const UNLOCKED_MESSAGES = [
	"Let's try using the [color=medium_blue]door key[/color].",
	"The door is now unlocked!"
	]
const LOCKED_MESSAGES = [
	"Hmm... This door seems to be locked.",
	"If I had a [color=medium_blue]door key[/color], maybe I could unlock it..."
	]

@onready var _interactable_component = $InteractableComponent
@onready var _door_sprite = $Sprites/DoorSprite
var _is_open: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_interactable_component.is_collidable = true
	_interactable_component.interacted.connect(_on_interact)
	
	_door_sprite.texture = _DOOR_SPRITES[0]

func _on_interact(player):
	if not player is Player:
		return
	if player.has_item("door key"):
		var closed = GameManager.create_message_popup(UNLOCKED_MESSAGES)
		await closed # just await the signal first
		# open the door
		_is_open = true
		_interactable_component.is_collidable = false
		_interactable_component.interacted.disconnect(_on_interact)
		_door_sprite.texture = _DOOR_SPRITES[1]
		
	else:
		GameManager.create_message_popup(LOCKED_MESSAGES)
