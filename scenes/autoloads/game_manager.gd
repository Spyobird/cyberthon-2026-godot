extends Node

signal battle_ended(won: bool)

var _message_manager: MessageManager
var scene_controller: SceneController # Initialised in node
var transition_controller: TransitionController
var bgm_controller: BGMController
var player_data: CharacterData
var enemy_data: CharacterData
var enemy_node: Node
var is_menu_allowed: bool = true

var _movement_locks: Array[StringName] = []

# Movement related

# Mesasge-box related
const default_mb_pos = Vector2i(6, 4.25)

var is_player_movement_disabled: bool:
	get: return _movement_locks.size() > 0

func lock_movement(id: StringName) -> void:
	if not _movement_locks.has(id):
		_movement_locks.append(id)

func unlock_movement(id: StringName) -> void:
	_movement_locks.erase(id)

# Moves related
func load_move(move: String) -> MoveData:
	var file_name = move.to_lower().replace(" ", "_")
	var path = "res://resources/data/moves/" + file_name + ".tres"
	if ResourceLoader.exists(path):
		print("Loading move from path: %s" % path)
		return load(path)
	print("Error loading move")
	return null

func load_moves(moves: Array[String]) -> Array[MoveData]:
	var output: Array[MoveData] = []
	for move in moves:
		var loaded_move = load_move(move)
		if loaded_move:
			output.append(loaded_move)
	return output

# Message manager related

func register_message_manager(message_manager: MessageManager):
	_message_manager = message_manager
	_message_manager.message_box_opened.connect(func(): lock_movement(&"message_box"); is_menu_allowed = false)
	_message_manager.message_box_closed.connect(func(): unlock_movement(&"message_box"); is_menu_allowed = true)

func create_message_popup(messages, ...args):
	if _message_manager:
		if messages is String:
			args.push_front(messages)
			_message_manager.play_text.callv(args)
		elif messages is Array:
			_message_manager.play_text.callv(messages)
	return _message_manager.message_box_closed

func _process(delta: float) -> void:
	# handle scrolling of text
	if _message_manager:
		if Input.is_action_just_pressed("ui_accept"):
			_message_manager.scroll_text()
