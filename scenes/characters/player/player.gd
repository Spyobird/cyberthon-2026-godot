class_name Player
extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -400.0

@onready var _movement_component = $TileBasedMovementComponent
@onready var animated_sprite = $TileBasedMovementComponent/AnimatedSprite2D

var _player_state_loader: PlayerStateLoader
var _inventory: Inventory
var last_direction := Vector2.RIGHT

func _ready() -> void:
	_player_state_loader = MockPlayerStateLoader.new()
	add_child(_player_state_loader)
	
	_movement_component.init(self)
	
	_inventory = Inventory.new()
	_inventory.load_items(["magic wand"])

func _physics_process(delta) -> void:
	_movement_component.process_movement(delta)
	
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Read 2D input
	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# Horizontal movement
	velocity.x = input_vector.x * SPEED

	# Choose animation
	if input_vector != Vector2.ZERO:
		last_direction = input_vector

		if abs(input_vector.y) > abs(input_vector.x):
			if input_vector.y < 0:
				if animated_sprite.animation != "up":
					animated_sprite.play("up")
			else:
				if animated_sprite.animation != "down":
					animated_sprite.play("down")
		else:
			if animated_sprite.animation != "walk":
				animated_sprite.play("walk")
			animated_sprite.flip_h = input_vector.x < 0
	else:
		if abs(last_direction.y) > abs(last_direction.x):
			if last_direction.y < 0:
				if animated_sprite.animation != "up":
					animated_sprite.play("up")
			else:
				if animated_sprite.animation != "down":
					animated_sprite.play("down")
		else:
			if animated_sprite.animation != "idle":
				animated_sprite.play("idle")
			animated_sprite.flip_h = last_direction.x < 0
		
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("test_api"):
		var result = await _player_state_loader.load_player_state()
		_inventory.load_items(result.inventory) # load player inventory

func has_item(item: String) -> bool:
	return _inventory.has_item(item)
