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

@onready var _enemy_pos = $EnemyPos
@onready var _player_pos = $PlayerPos
@onready var _ui = $BattleUI

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
	# initialize player and enemy
	pass

func _start_player_turn():
	# handle inputs
	
	# on action -> action
	pass

func _run():
	_end_battle()

func _start_enemy_turn():
	
	# calculate stuff
	
	_execute_action("some params")

func _end_battle():
	# handle scene change + updates
	pass

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
