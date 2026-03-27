class_name Player
extends Node2D

@onready var _movement_component = $TileBasedMovementComponent

var _player_state_loader: PlayerStateLoader
var _inventory: Inventory
var _last_direction: Vector2

func _ready() -> void:
	_player_state_loader = MockPlayerStateLoader.new()
	add_child(_player_state_loader)
	
	_movement_component.init(self)
	
	_inventory = Inventory.new()
	_inventory.load_items(["magic wand"])

func _physics_process(delta) -> void:
	_movement_component.process_movement(delta)
		
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("test_api"):
		var result = await _player_state_loader.load_player_state()
		_inventory.load_items(result.inventory) # load player inventory

func has_item(item: String) -> bool:
	return _inventory.has_item(item)
