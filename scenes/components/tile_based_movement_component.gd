class_name TileBasedMovementComponent
extends CharacterBody2D

@export var tile_size: int = 16
@export var walk_speed: float = 4.0
@onready var _ray: RayCast2D = $RayCast2D
@onready var _animated_sprite = $AnimatedSprite2D
var _input_direction: Vector2 = Vector2.ZERO # consider moving input out
var _target_position: Vector2 = Vector2.ZERO
var _parent: Node2D
var _last_direction: Vector2 = Vector2.RIGHT
var is_moving: bool = false

const SPEED = 150.0

func init(parent: Node) -> void:
	_parent = parent

func process_movement(delta: float):
	if not is_moving and not GameManager.is_player_movement_disabled:
		_process_player_input()
	if _input_direction != Vector2.ZERO:
		_move(delta)
		_animate(delta)

### Input processing ###
func _process_player_input():
	if _input_direction.y == 0:
		_input_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	if _input_direction.x == 0:
		_input_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	
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
		return collider.is_collidable
	if collider is StaticBody2D:
		# catch all generic static bodies
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
	
func _animate(delta):

	# Read 2D input
	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		
	# Choose animation
	if input_vector != Vector2.ZERO:
		_last_direction = input_vector

		if abs(input_vector.y) > abs(input_vector.x):
			if input_vector.y < 0:
				if _animated_sprite.animation != "up":
					_animated_sprite.play("up")
			else:
				if _animated_sprite.animation != "down":
					_animated_sprite.play("down")
		else:
			if _animated_sprite.animation != "walk":
				_animated_sprite.play("walk")
			_animated_sprite.flip_h = input_vector.x < 0
	else:
		if abs(_last_direction.y) > abs(_last_direction.x):
			if _last_direction.y < 0:
				if _animated_sprite.animation != "up":
					_animated_sprite.play("up")
			else:
				if _animated_sprite.animation != "down":
					_animated_sprite.play("down")
		else:
			if _animated_sprite.animation != "idle":
				_animated_sprite.play("idle")
			_animated_sprite.flip_h = _last_direction.x < 0
