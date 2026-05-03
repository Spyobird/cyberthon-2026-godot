class_name SlimeEnemy
extends Node2D

@onready var _interactable_component = $InteractableComponent

func _ready() -> void:
	_interactable_component.interacted.connect(_on_interacted)

func _on_interacted(collider):
	print("Slime interacted with ", collider)
	await GameManager.create_message_popup("Squish...")
	_open_app()
	await GameManager.create_message_popup("[Tap to close]")
	
func _open_app():
	OS.shell_open("http://localhost:3000")
	print("Browser opened")
