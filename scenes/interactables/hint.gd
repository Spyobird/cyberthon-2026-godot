class_name Hint
extends Node2D

@onready var _interactable_component = $InteractableComponent

func _ready() -> void:
	_interactable_component.interacted.connect(_on_interacted)

func _on_interacted(collider):
	GameManager.create_message_popup("This is a hint!")
