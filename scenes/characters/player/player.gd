class_name Player
extends Node2D

signal SYNC_PLAYER_START
signal SYNC_PLAYER_SUCCESS
signal SYNC_PLAYER_FAILED

@onready var _movement_component = $TileBasedMovementComponent

var _player_state_loader: PlayerStateLoader
#var _inventory: Inventory
var _current_player_state: PlayerState
var _last_direction: Vector2

func _ready() -> void:
	_player_state_loader = MockPlayerStateLoader.new()
	add_child(_player_state_loader)
	
	_movement_component.init(self)
	
	update_player_state(PlayerState.new(["magic wand"], Vector3i(100, 20, 20), ["fireball", "lightning"]))
	print("Bootstrapped player!")
	
	#_inventory = Inventory.new()
	#_inventory.load_items(["magic wand"])

func _physics_process(delta) -> void:
	_movement_component.process_movement(delta)

#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("test_api"):
		#var result = await _player_state_loader.load_player_state()
		#update_player_state(result)
		#_inventory.load_items(result.inventory) # load player inventory

func get_player_state() -> PlayerState:
	return _current_player_state

func has_item(item: String) -> bool:
	return _current_player_state.inventory.has_item(item)
	#return _inventory.has_item(item)/


func update_player_state(new_player_state: PlayerState) -> void:
	_current_player_state = new_player_state

func sync_player_state() -> void:
	SYNC_PLAYER_START.emit()
	var result = await _player_state_loader.load_player_state()
	if result == null:
		SYNC_PLAYER_FAILED.emit()
		return
	update_player_state(result)
	SYNC_PLAYER_SUCCESS.emit()
	
