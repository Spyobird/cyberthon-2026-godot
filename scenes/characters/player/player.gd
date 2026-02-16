class_name Player
extends Node2D

@onready var _movement_component = $TileBasedMovementComponent
var _player_state_loader: PlayerStateLoader

func _ready() -> void:
	_player_state_loader = MockPlayerStateLoader.new()
	add_child(_player_state_loader)
	
	_movement_component.init(self)

func _physics_process(delta: float) -> void:
	_movement_component.process_movement(delta)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("test_api"):
		var result = await _player_state_loader.load_player_state()
		print(result)
