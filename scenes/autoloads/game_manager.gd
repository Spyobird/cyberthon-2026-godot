extends Node

var _message_manager: MessageManager
var scene_controller: SceneController
var is_player_movement_disabled: bool = false
var is_menu_allowed: bool = true

func register_message_manager(message_manager: MessageManager):
	_message_manager = message_manager
	_message_manager.message_box_opened.connect(func(): is_player_movement_disabled = true; is_menu_allowed = false)
	_message_manager.message_box_closed.connect(func(): is_player_movement_disabled = false; is_menu_allowed = true)

func _process(delta: float) -> void:
	# handle scrolling of text
	if _message_manager:
		if Input.is_action_just_pressed("use"):
			_message_manager.scroll_text()
		if Input.is_action_just_pressed("test_message"):
			create_message_popup("Hello world", "Hope you have a great day!") # temp string

func create_message_popup(...messages):
	if _message_manager:
		_message_manager.play_text.callv(messages)
	return _message_manager.message_box_closed
