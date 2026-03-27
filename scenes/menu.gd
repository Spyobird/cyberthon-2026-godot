extends Node2D

@onready var select_arrow = $Control/MenuBanner/TextureRect
@onready var menu = $Control

var _camera: Camera2D
var _movement_component: TileBasedMovementComponent

enum MenuState { NOTHING, MENU, ITEM_SCREEN }
var menu_state: MenuState = MenuState.NOTHING

@onready var selected_option: int = 0
@onready var number_menu_options: int = ($Control/MenuBanner/TextContainer).get_child_count()

# y position value of the cursor for the first
const menu_start_offset_y = 7
# increment to y, to select the next item
const menu_next_item_offset_y = 14

func calculate_arrow_position() -> void:
	var new_arrow_position: int = menu_start_offset_y + (selected_option % number_menu_options) * menu_next_item_offset_y
	select_arrow.set_position(Vector2(6.0, new_arrow_position))
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu.visible = false
	calculate_arrow_position()
	_camera = get_viewport().get_camera_2d()
	var player = get_tree().get_first_node_in_group("player_group")
	if player:
		_movement_component = player.get_node("TileBasedMovementComponent")

func _process(_delta: float) -> void:
	if _camera:
		global_position = _camera.global_position

	
func _unhandled_input(event: InputEvent) -> void:
	match menu_state:
		MenuState.NOTHING:
			if event.is_action_pressed("toggle_menu"):
				if not GameManager.is_menu_allowed:
					return
				if _movement_component and _movement_component.is_moving:
					return
				print("Menu is now visible!")
				menu.visible = true
				menu_state = MenuState.MENU
				GameManager.is_player_movement_disabled = true
		
		MenuState.MENU:
			if event.is_action_pressed("toggle_menu"):
				menu.visible = false
				print("Menu is now hidden!")
				menu_state = MenuState.NOTHING
				GameManager.is_player_movement_disabled = false
			elif event.is_action_pressed("ui_down"):
				print("UI Down pressed")
				selected_option += 1
				calculate_arrow_position()
			elif event.is_action_pressed("ui_up"):
				print("UI up pressed")
				if selected_option == 0:
					selected_option = 5
				else:
					selected_option -= 1
				calculate_arrow_position()
			

				
				
				
		MenuState.ITEM_SCREEN:
			pass
			

		
			
