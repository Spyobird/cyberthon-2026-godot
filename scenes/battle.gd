class_name Battle
extends Node2D

enum State {
	START,
	PLAYER_TURN,
	ENEMY_TURN,
	ACTION,
	WIN,
	LOSE
}

@onready var _enemy_pos = $CharacterSprites/EnemyPos
@onready var _player_pos = $CharacterSprites/PlayerPos
@onready var _enemy_sprite = $CharacterSprites/EnemyPos/EnemySprite
@onready var _player_sprite = $CharacterSprites/PlayerPos/PlayerSprite
@onready var _ui = $BattleUI

var _player_data: CharacterData
var _enemy_data: CharacterData
var current_state: State

func _ready() -> void:
	_change_state(State.START)

# TODO: consider changing to node based state machine -> moves logic out
func _change_state(new_state: State):
	current_state = new_state
	match current_state:
		State.START:
			_setup_battle()
		State.PLAYER_TURN:
			_start_player_turn()
		State.ENEMY_TURN:
			_start_player_turn()
		State.WIN, State.LOSE:
			_end_battle()

func _setup_battle():
	# load character data
	_player_data = GameManager.player_data.duplicate(true)
	_enemy_data = GameManager.enemy_data.duplicate(true)
	print("Fetched player and enemy data from GameManager")
	
	# setup sprites
	_player_sprite.texture = _player_data.sprite_back
	_enemy_sprite.texture = _enemy_data.sprite_front
	_player_sprite.position = Vector2.ZERO
	_enemy_sprite.position = Vector2.ZERO
	_player_sprite.apply_scale(Vector2(3, 3))
	_enemy_sprite.apply_scale(Vector2(3, 3))
	print("Loaded player and enemy sprites")
	
	# setup UI
	_ui.initialize(_player_data, _enemy_data)
	_ui.run_button.pressed.connect(_run)
	print("Loaded Battle UI")
	
	# possibly play something with a message
	var result = _ui.display_message("Battle with %s" % _enemy_data.name)
	if result:
		await result
	
	print("Battle setup complete")
	_change_state(State.PLAYER_TURN)

func _start_player_turn():
	# handle inputs
	
	# on action -> action
	pass

func _run():
	print("Running...")
	_end_battle()

func _start_enemy_turn():
	
	# calculate stuff
	
	_execute_action("some params")

func _end_battle():
	# handle scene change + updates
	GameManager.scene_controller.pop_2d_scene()

func _execute_action(some_parameters):
	_change_state(State.ACTION)
	
	# show text
	
	# play animations
	
	# calculate dmg
	
	_check_for_faint()

func _check_for_faint():
	# player hp zero -> change to lose
	# enemy hp zero -> change to win
	pass

func _input(event: InputEvent) -> void:
	if _ui.is_message_reading():
		if event.is_action_pressed("ui_accept"):
			_ui.scroll_text()
			get_viewport().set_input_as_handled()
