extends Node2D

@onready var select_arrow = $Control/MenuBanner/TextureRect
@onready var menu = $Control

var _camera: Camera2D
var _movement_component: TileBasedMovementComponent
var _player: Player
var _stats_sub_menu: Node = null

enum MenuState { NOTHING, MENU, ITEM_SCREEN, STATUS_SCREEN }
var menu_state: MenuState = MenuState.NOTHING

enum MenuOptions {STATUS = 0, ITEM = 1, SYNC = 2, EXIT = 3}

@onready var selected_option: int = MenuOptions.STATUS
@onready var number_menu_options: int = ($Control/MenuBanner/TextContainer).get_child_count()

const menu_start_offset_y = 7
const menu_next_item_offset_y = 14

func calculate_arrow_position() -> void:
	var new_arrow_position: int = menu_start_offset_y + (selected_option % number_menu_options) * menu_next_item_offset_y
	select_arrow.set_position(Vector2(6.0, new_arrow_position))

func _ready() -> void:
	menu.visible = false
	calculate_arrow_position()
	_camera = get_viewport().get_camera_2d()
	_player = get_tree().get_first_node_in_group("player_group")
	if _player:
		_movement_component = _player.get_node("TileBasedMovementComponent")

func _process(_delta: float) -> void:
	if _camera:
		global_position = _camera.global_position

func _fade_to_black_then(callback: Callable) -> void:
	var canvas = CanvasLayer.new()
	var rect = ColorRect.new()
	rect.color = Color.BLACK
	rect.modulate = Color(1, 1, 1, 0)
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(rect)
	add_child(canvas)
	var tween = create_tween()
	tween.tween_property(rect, "modulate:a", 1.0, 0.5)
	tween.tween_callback(callback)

func _open_status_screen() -> void:
	menu.visible = false
	_stats_sub_menu = load("res://scenes/ui/stats_sub_menu.tscn").instantiate()
	add_child(_stats_sub_menu)
	menu_state = MenuState.STATUS_SCREEN

func _open_item_screen() -> void:
	_fade_to_black_then(func():
		GameManager.scene_controller.overlay_2d_scene("res://scenes/ui/item_screen_menu.tscn")
		menu.visible = false
		menu_state = MenuState.ITEM_SCREEN
	)

func _sync_player_state() -> void:
	if _player:
		await _player.sync_player_state()
		
func _exit_menu() -> void:
	menu.visible = false
	menu_state = MenuState.NOTHING
	GameManager.unlock_movement(&"menu")	

func _handle_menu_select() -> void:
	match selected_option:
		MenuOptions.STATUS:
			_open_status_screen()
		MenuOptions.ITEM:
			_open_item_screen()
		MenuOptions.SYNC:
			_sync_player_state()
			print("Sync successful!")
			_exit_menu()
		MenuOptions.EXIT:
			_exit_menu()
			
func _unhandled_input(event: InputEvent) -> void:
	match menu_state:
		MenuState.NOTHING:
			if event.is_action_pressed("toggle_menu"):
				if not GameManager.is_menu_allowed:
					return
				if _movement_component and _movement_component.is_moving:
					return
				menu.visible = true
				menu_state = MenuState.MENU
				GameManager.lock_movement(&"menu")

		MenuState.MENU:
			if event.is_action_pressed("toggle_menu"):
				menu.visible = false
				menu_state = MenuState.NOTHING
				GameManager.unlock_movement(&"menu")
			elif event.is_action_pressed("ui_down"):
				selected_option = (selected_option + 1) % number_menu_options
				calculate_arrow_position()
			elif event.is_action_pressed("ui_up"):
				selected_option = (selected_option - 1 + number_menu_options) % number_menu_options
				calculate_arrow_position()
			elif event.is_action_pressed("ui_accept"):
				_handle_menu_select()

		MenuState.STATUS_SCREEN:
			if event.is_action_pressed("toggle_menu"):
				if _stats_sub_menu:
					_stats_sub_menu.queue_free()
					_stats_sub_menu = null
				menu.visible = true
				menu_state = MenuState.MENU

		MenuState.ITEM_SCREEN:
			pass
