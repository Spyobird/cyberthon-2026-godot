class_name TileBasedMovementComponent
extends CharacterBody2D

@export var tile_size: int = 16
@export var walk_speed: float = 4.0
@onready var _ray: RayCast2D = $RayCast2D
var _input_direction: Vector2 = Vector2.ZERO # consider moving input out
var _target_position: Vector2 = Vector2.ZERO
var _parent: Node2D
var is_moving: bool = false

func init(parent: Node) -> void:
	_parent = parent

func process_movement(delta: float):
	if not is_moving and not GameManager.is_player_movement_disabled:
		_process_player_input()
	if _input_direction != Vector2.ZERO:
		_move(delta)

### Input processing ###
func _process_player_input():
	if _input_direction.y == 0:
		_input_direction.x = int(Input.is_action_just_pressed("ui_right")) - int(Input.is_action_just_pressed("ui_left"))
	if _input_direction.x == 0:
		_input_direction.y = int(Input.is_action_just_pressed("ui_down")) - int(Input.is_action_just_pressed("ui_up"))
	
	if _input_direction != Vector2.ZERO:
		_target_position = _input_direction * tile_size
		_start_movement()

### Collision checking ###
func _check_collision() -> bool:
	_ray.target_position = _target_position
	_ray.force_raycast_update()
	if _ray.is_colliding():
		var collider = _ray.get_collider()
		return _check_collider(collider)
	return false

func _check_collider(collider) -> bool:
	if collider is TileMapLayer:
		return true
	if collider is InteractableComponent:
		# collision callback happens in check, consider moving elsewhere if not clean
		collider.interact(_parent)
		if collider.is_collidable:
			return true
	return false

### Movement ###
func _start_movement():
	if not is_moving and not _check_collision():
		_target_position = _parent.position + _input_direction * tile_size
		is_moving = true
	else:
		pass

func _move(delta: float):
	if is_moving:
		_parent.position = _parent.position.move_toward(_target_position, delta * tile_size * walk_speed)
		if _parent.position.distance_squared_to(_target_position) < 1.0:
			_stop_movement()

func _stop_movement():
	is_moving = false
	_snap_position_to_grid()

func _snap_position_to_grid():
	_parent.position = Vector2(
		roundf(_parent.position.x / tile_size) * tile_size,
		roundf(_parent.position.y / tile_size) * tile_size
	)
