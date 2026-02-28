extends Node

var _message_manager: MessageManager

func register_message_manager(message_manager: MessageManager):
	_message_manager = message_manager

func _process(delta: float) -> void:
	# handle scrolling of text
	if _message_manager:
		if Input.is_action_just_pressed("use"):
			_message_manager.scroll_text()
		if Input.is_action_just_pressed("test_message"):
			_message_manager.play_text("Hello world", "Hope you have a great day!") # temp string
