class_name TileBasedMovementComponent
extends CharacterBody2D

@export var tile_size: int = 16
@export var walk_speed: float = 4.0
@onready var _ray: RayCast2D = $RayCast2D
var _percent_moved_to_next_tile: float = 0.0
var _input_direction: Vector2 = Vector2.ZERO
var _position: Vector2 = Vector2.ZERO
var _is_moving: bool = false
var _parent: Node2D

func init(parent: Node) -> void:
	_parent = parent

func process_movement(delta: float):
	if not _is_moving:
		_process_player_input()
	elif _input_direction != Vector2.ZERO:
		_move(delta)
	else:
		_is_moving = false

func _process_player_input():
	if _input_direction.y == 0:
		_input_direction.x = int(Input.is_action_just_pressed("ui_right")) - int(Input.is_action_just_pressed("ui_left"))
	if _input_direction.x == 0:
		_input_direction.y = int(Input.is_action_just_pressed("ui_down")) - int(Input.is_action_just_pressed("ui_up"))
		
	if _input_direction != Vector2.ZERO:
		_position = _parent.global_position
		_is_moving = true

func _is_next_tile_blocked() -> bool:
	var target_tile = _input_direction * (tile_size / 2)
	_ray.target_position = target_tile
	_ray.force_raycast_update()
	var collider = _ray.get_collider()
	return _check_collider(collider)

func _check_collider(collider) -> bool:
	if collider is TileMapLayer:
		return true
	if collider is InteractableComponent:
		# collision callback happens in check, consider changing
		collider.interact(_parent)
		if collider.collidable:
			return true
	return false

func _move(delta: float) -> void:
	if _is_next_tile_blocked():
		_is_moving = false
		return
	_percent_moved_to_next_tile += walk_speed * delta
	if _percent_moved_to_next_tile >= 1.0:
		_parent.global_position = _position + tile_size * _input_direction
		_percent_moved_to_next_tile = 0.0
		_is_moving = false
	else:
		_parent.global_position = _position + tile_size * _input_direction * _percent_moved_to_next_tile
