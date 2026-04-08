class_name BattleUI
extends CanvasLayer

@export_group("Menus")
@export var options_menu: Container
@export var moves_menu: Container

@export_subgroup("Options Buttons")
@export var moves_button: Button
@export var run_button: Button

@export_group("Character Info")
@export var player_name: Label
@export var player_hp: Label
@export var enemy_name: Label
@export var player_bar: ProgressBar
@export var enemy_bar: ProgressBar
@export var move_buttons: Array[Button]

func initialize(player: CharacterData, enemy: CharacterData):
	print("Initializing Battle UI...")
	
	player_name.text = player.name
	enemy_name.text = enemy.name
	player_hp.text = "%d / %d" % [player.current_hp, player.max_hp]
	player_bar.max_value = player.max_hp
	player_bar.value = player.current_hp
	enemy_bar.max_value = enemy.max_hp
	enemy_bar.value = enemy.current_hp
	print("Initialized character data")
	
	# Moves
	for i in range(move_buttons.size()):
		var btn = move_buttons[i]
		
		# If the pokemon has a move in this slot
		if i < player.moves.size():
			var move_res = player.moves[i]
			btn.text = move_res.name
			btn.show()
			
			# Clean up old connections if they exist
			if btn.pressed.is_connected(_on_move_pressed):
				btn.pressed.disconnect(_on_move_pressed)
				
			# LINKING: Bind the move resource directly to the button signal
			btn.pressed.connect(_on_move_pressed.bind(move_res))
		else:
			btn.hide()
	print("Initialized move buttons")
	
	_show_options_menu()

func _show_moves_menu():
	options_menu.hide()
	moves_menu.show()
	move_buttons[0].grab_focus()

func _show_options_menu():
	options_menu.show()
	moves_menu.hide()
	moves_button.grab_focus()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if moves_menu.is_visible_in_tree():
			_show_options_menu()
			get_viewport().set_input_as_handled()

func _on_move_pressed(move: MoveData):
	print("Used move %s" % move.name)
