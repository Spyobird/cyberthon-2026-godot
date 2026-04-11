class_name Slime
extends Node2D

@onready var _interactable_component = $InteractableComponent

func _ready() -> void:
	_interactable_component.interacted.connect(_on_interacted)

func _on_interacted(collider):
	print("Interacted with ", collider)
	GameManager.create_message_popup("I am slime")
