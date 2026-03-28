extends Node

var _message_manager: MessageManager
var scene_controller: SceneController
var is_menu_allowed: bool = true

var _movement_locks: Array[StringName] = []

var is_player_movement_disabled: bool:
	get: return _movement_locks.size() > 0

func lock_movement(id: StringName) -> void:
	if not _movement_locks.has(id):
		_movement_locks.append(id)

func unlock_movement(id: StringName) -> void:
	_movement_locks.erase(id)

func register_message_manager(message_manager: MessageManager):
	_message_manager = message_manager
	_message_manager.message_box_opened.connect(func(): lock_movement(&"message_box"); is_menu_allowed = false)
	_message_manager.message_box_closed.connect(func(): unlock_movement(&"message_box"); is_menu_allowed = true)

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
