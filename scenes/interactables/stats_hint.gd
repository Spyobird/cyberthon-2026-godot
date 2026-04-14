class_name StatsHint
extends Node2D

signal _hint_closed

@onready var _interactable_component = $InteractableComponent
@onready var _canvas = $CanvasLayer

func _ready() -> void:
	_interactable_component.interacted.connect(_on_interacted)
	
	_canvas.visible = false

func _on_interacted(collider):
	await GameManager.create_message_popup("What does this read?")
	
	_canvas.visible = true
	await _hint_closed
	_canvas.visible = false

func _input(event):
	if _canvas.visible:
		if event.is_action_pressed("ui_accept"):
			_hint_closed.emit()
