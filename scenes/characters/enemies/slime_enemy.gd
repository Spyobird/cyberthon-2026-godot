class_name SlimeEnemy
extends Node2D

const MESSAGES = [
	"[i]*Squish*[/i]",
	"[i]*Gloop*[/i]",
	"[i]*Squelch*[/i]"
]

@onready var _interactable_component = $InteractableComponent

func _ready() -> void:
	_interactable_component.interacted.connect(_on_interacted)

func _on_interacted(collider):
	print("Slime interacted with ", collider)
	var message = MESSAGES.pick_random()
	await GameManager.create_message_popup(message)
	_open_app()
	await GameManager.create_message_popup("[Tap ENTER to close]")
	
func _open_app():
	OS.shell_open("http://localhost:8000")
	print("Browser opened")
