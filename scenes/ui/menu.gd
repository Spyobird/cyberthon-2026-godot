extends CanvasLayer

signal status_menu_selected(hp: int, atk: int, def: int)
signal status_menu_closed
signal item_menu_selected(item1: String, item2: String, item3: String)
signal item_menu_closed

@onready var select_arrow = $MainMenu/MenuBanner/TextureRect
@onready var menu = $MainMenu
@onready var _stats_sub_menu = $StatsSubMenu
@onready var _items_sub_menu = $ItemsSubMenu

var _movement_component: TileBasedMovementComponent
var _player: Player

enum MenuState { NOTHING, MENU, ITEM_SCREEN, STATUS_SCREEN }
var menu_state: MenuState = MenuState.NOTHING

enum MenuOptions {STATUS = 0, ITEM = 1, SYNC = 2, EXIT = 3}

@onready var selected_option: int = MenuOptions.STATUS
@onready var number_menu_options: int = ($MainMenu/MenuBanner/TextContainer).get_child_count()

const menu_start_offset_y = 7
const menu_next_item_offset_y = 14

func calculate_arrow_position() -> void:
	var new_arrow_position: int = menu_start_offset_y + (selected_option % number_menu_options) * menu_next_item_offset_y
	select_arrow.set_position(Vector2(8.0, new_arrow_position))

func _ready() -> void:
	menu.visible = false
	calculate_arrow_position()
	_player = get_tree().get_first_node_in_group("player_group")
	if _player:
		_movement_component = _player.get_node("TileBasedMovementComponent")
	status_menu_selected.connect(_stats_sub_menu._on_status_menu_selected)
	status_menu_closed.connect(_stats_sub_menu._on_status_menu_closed)
	item_menu_selected.connect(_items_sub_menu._on_item_menu_selected)
	item_menu_closed.connect(_items_sub_menu._on_item_menu_closed)

func _open_status_screen() -> void:
	menu.visible = false
	menu_state = MenuState.STATUS_SCREEN
	if _player:
		var state = _player.get_player_state()
		status_menu_selected.emit(int(state.stats.x), int(state.stats.y), int(state.stats.z))

func _open_item_screen() -> void:
	menu.visible = false
	menu_state = MenuState.ITEM_SCREEN
	if _player:
		var items = _player.get_player_state().inventory.read_items()
		item_menu_selected.emit(
			items.get(0),
			items.get(1),
			items.get(2),
			#items[0] if items.size() > 0 else "",
			#items[1] if items.size() > 1 else "",
			#items[2] if items.size() > 2 else ""
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
				status_menu_closed.emit()
				menu.visible = true
				menu_state = MenuState.MENU

		MenuState.ITEM_SCREEN:
			if event.is_action_pressed("toggle_menu"):
				item_menu_closed.emit()
				menu.visible = true
				menu_state = MenuState.MENU
