class_name Player
extends Node2D

signal sync_player_started
signal sync_player_completed
signal sync_player_failed

const PLAYER_BASE_DATA = preload("res://resources/data/characters/player_base.tres")

@onready var _movement_component = $TileBasedMovementComponent

var _player_state_loader: PlayerStateLoader
var _current_player_state: PlayerState
var _last_direction: Vector2
var player_data: CharacterData

func _ready() -> void:
	_player_state_loader = MockPlayerStateLoader.new()
	add_child(_player_state_loader)
	
	_movement_component.init(self)
	
	update_player_state(PlayerState.new(["magic wand"], Vector3i(100, 45, 45), ["fireball", "zap_bolt"]))
	print("Loaded default player state!")

func _physics_process(delta) -> void:
	_movement_component.process_movement(delta)

func get_player_state() -> PlayerState:
	return _current_player_state

func has_item(item: String) -> bool:
	return _current_player_state.inventory.has_item(item)

func update_player_state(new_player_state: PlayerState) -> void:
	_current_player_state = new_player_state
	player_data = PLAYER_BASE_DATA.duplicate(true)
	player_data.moves = GameManager.load_moves(_current_player_state.moves)
	player_data.attack = _current_player_state.stats.y
	player_data.defense = _current_player_state.stats.z
	player_data.max_hp = _current_player_state.stats.x
	player_data.current_hp = _current_player_state.stats.x

func sync_player_state() -> void:
	sync_player_started.emit()
	var result = await _player_state_loader.load_player_state()
	if result == null:
		sync_player_failed.emit()
		GameManager.create_message_popup(["[color=red]SYNC FAILED...[/color]", "Ensure your card is placed on the reader and try again."])
		return
	update_player_state(result)
	sync_player_completed.emit()
	GameManager.create_message_popup(["[color=web_green]SYNC SUCCESS![/color]"])
	
