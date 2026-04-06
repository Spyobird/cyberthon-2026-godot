class_name Player
extends Node2D

signal sync_player_started
signal sync_player_completed
signal sync_player_failed

@onready var _movement_component = $TileBasedMovementComponent

var _player_state_loader: PlayerStateLoader
var _current_player_state: PlayerState
var _last_direction: Vector2

func _ready() -> void:
	_player_state_loader = MockPlayerStateLoader.new()
	add_child(_player_state_loader)
	
	_movement_component.init(self)
	
	update_player_state(PlayerState.new(["magic wand"], Vector3i(100, 20, 20), ["fireball", "lightning"]))
	print("Loaded default player state!")

func _physics_process(delta) -> void:
	_movement_component.process_movement(delta)

func get_player_state() -> PlayerState:
	return _current_player_state

func has_item(item: String) -> bool:
	return _current_player_state.inventory.has_item(item)

func update_player_state(new_player_state: PlayerState) -> void:
	_current_player_state = new_player_state

func sync_player_state() -> void:
	sync_player_started.emit()
	var result = await _player_state_loader.load_player_state()
	if result == null:
		sync_player_failed.emit()
		return
	update_player_state(result)
	sync_player_completed.emit()
	
