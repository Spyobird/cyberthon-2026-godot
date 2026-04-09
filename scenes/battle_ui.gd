class_name BattleUI
extends CanvasLayer

signal message_box_opened
signal message_box_closed

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

@export_group("Message Box")
@export var delay_ms: float = 15
@export var message_label: RichTextLabel

var is_message_box_scrolling: bool = false
var _battle: Battle
var _messages: Array[String] = []

func initialize(battle: Battle, player: CharacterData, enemy: CharacterData):
	print("Initializing Battle UI...")
	_battle = battle
	battle.data_updated.connect(update_ui)
	
	update_ui(player, enemy)
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
			if btn.pressed.is_connected(battle.use_move):
				btn.pressed.disconnect(battle.use_move)
				
			# LINKING: Bind the move resource directly to the button signal
			btn.pressed.connect(battle.use_move.bind(move_res))
		else:
			btn.hide()
	print("Initialized move buttons")

func update_ui(player: CharacterData, enemy: CharacterData):
	player_name.text = player.name
	enemy_name.text = enemy.name
	player_hp.text = "%d / %d" % [player.current_hp, player.max_hp]
	player_bar.max_value = player.max_hp
	player_bar.value = player.current_hp
	enemy_bar.max_value = enemy.max_hp
	enemy_bar.value = enemy.current_hp

func show_moves_menu():
	options_menu.hide()
	moves_menu.show()
	move_buttons[0].grab_focus()

func show_options_menu():
	options_menu.show()
	moves_menu.hide()
	moves_button.grab_focus()

func hide_all_menus():
	options_menu.hide()
	moves_menu.hide()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if moves_menu.is_visible_in_tree():
			show_options_menu()
			get_viewport().set_input_as_handled()
	if is_message_reading():
		if event.is_action_pressed("ui_accept"):
			scroll_text()
			get_viewport().set_input_as_handled()

# Message box methods (from MessageManager)

func display_message(... messages):
	if is_message_reading():
		return
	if len(messages) == 0:
		return
	
	hide_all_menus()
	message_box_opened.emit()
	_messages.assign(messages.filter(func(x): return x is String))
	scroll_text()
	return message_box_closed

func is_message_reading() -> bool:
	return message_label.visible

func scroll_text():
	if is_message_box_scrolling:
		return
	if not is_message_reading():
		message_label.visible = true
	if len(_messages) == 0:
		message_label.visible = false
		message_box_closed.emit()
		return
	
	is_message_box_scrolling = true
	message_label.text = _messages[0]
	message_label.visible_characters = 0 # Hide everything initially
	
	var total_chars = message_label.get_total_character_count()
	for i in range(total_chars):
		message_label.visible_characters += 1
		await get_tree().create_timer(delay_ms/1000).timeout
	
	_messages.pop_front()
	is_message_box_scrolling = false
