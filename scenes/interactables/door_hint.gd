class_name DoorHint
extends Node2D

const HINT_MESSAGES = [
	"HOW TO USE P.A.W.S.",
	"Initialize the Arcane Terminal by typing [color=web_green][code]pm3[/code][/color] to bridge the connection.",
	"To read the data, run the following commands in order:[ul][color=web_green][code]hf mf chk --1k --dump\nhf mf dump[/code][/color][/ul]",
	"The sector map is loading... Look there. Sector 1, Block 4. My [color=medium_blue]magic wand[/color] is currently stored there in ASCII format. That’s my active inventory slot.",
	"For synthesis, 1st convert the string [color=medium_blue]door key[/color] into hexadecimal. Then write the hex data to the next available inventory block.",
	"Run [color=web_green][code]hf mf wrbl --blk 5 -k FFFFFFFFFFFF -d <HEX_DATA>[/code][/color] to etch the key into the vault's memory.",
	"Remember to sync the data from the card."
]

@onready var _interactable_component = $InteractableComponent

func _ready() -> void:
	_interactable_component.interacted.connect(_on_interacted)

func _on_interacted(collider):
	GameManager.create_message_popup(HINT_MESSAGES)
