class_name Battle
extends Node2D

signal data_updated(player, enemy)
signal action_completed

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
			_start_enemy_turn()
		State.WIN:
			_win()
		State.LOSE:
			_lose()

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
	_ui.initialize(self, _player_data, _enemy_data)
	_ui.run_button.pressed.connect(_run)
	print("Loaded Battle UI")
	
	# possibly play something with a message
	await _ui.display_message("Battle with %s" % _enemy_data.name)
	
	print("Battle setup complete")
	_change_state(State.PLAYER_TURN)

func _start_player_turn():
	_ui.show_options_menu()
	
	# on action -> action
	await action_completed
	_change_state(State.ENEMY_TURN)

func _run():
	await _ui.display_message("Running...")
	_end_battle()

func _lose():
	await _ui.display_message("You lost the fight...")
	_end_battle()

func _win():
	await _ui.display_message("%s was defeated!" % _enemy_data.name)
	_end_battle(true)

func _end_battle(remove_enemy: bool = false):
	# handle scene change + updates
	if remove_enemy:
		# Deletes enemy
		GameManager.enemy_node.queue_free()
	GameManager.scene_controller.pop_2d_scene()

# Called from BattleUI buttons
func use_move(move: MoveData):
	print("Used move %s" % move.name)
	_execute_action(_player_data, _enemy_data, move)

func _execute_action(attacker: CharacterData, defender: CharacterData, move: MoveData):
	_change_state(State.ACTION)
	
	# show text
	await _ui.display_message("%s used %s!" % [attacker.name, move.name])
	
	# play animations
	
	# calculate + apply dmg
	var damage = _calculate_damage(attacker, defender, move)
	print("Damage: %d" % damage)
	_apply_damage(damage, defender)
	
	# update UI
	data_updated.emit(_player_data, _enemy_data)
	
	if _check_for_faint():
		return
	
	action_completed.emit()

func _start_enemy_turn():
	_ui.hide_all_menus()
	
	# choose move (requires at least 1 move)
	var chosen_move = _enemy_data.moves[0]
	
	# wait a bit
	await get_tree().create_timer(2.0).timeout
	
	_execute_action(_enemy_data, _player_data, chosen_move)
	# on action -> action
	await action_completed
	_change_state(State.PLAYER_TURN)

func _calculate_damage(attacker: CharacterData, defender: CharacterData, move: MoveData):
	if attacker.type == Constants.Element.DARK && move.type != Constants.Element.ANCIENT:
		return 0
	return max(int((6 * attacker.attack / defender.defense * move.power / 50 + 2) * randf_range(0.85, 1)), 1)

func _apply_damage(damage: int, defender: CharacterData):
	defender.current_hp -= damage

func _check_for_faint() -> bool:
	# player hp zero -> change to lose
	if _player_data.current_hp <= 0:
		_change_state(State.LOSE)
		return true
	# enemy hp zero -> change to win
	if _enemy_data.current_hp <= 0:
		_change_state(State.WIN)
		return true
	return false
