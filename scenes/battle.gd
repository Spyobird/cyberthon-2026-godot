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
@onready var _enemy_sprite: AnimatedSprite2D = $CharacterSprites/EnemyPos/EnemySprite
@onready var _player_sprite: AnimatedSprite2D = $CharacterSprites/PlayerPos/PlayerSprite
@onready var _ui = $BattleUI
@onready var _effect_sprite: AnimatedSprite2D = $CharacterSprites/EffectSprite
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _sfx_player: AudioStreamPlayer = $SoundFxPlayer
@onready var _bg_player: AudioStreamPlayer = $BgPlayer

const _HURT_SFX = preload("res://assets/audio/sfx/moves/Hit Normal Damage.mp3")

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
	_player_sprite.sprite_frames = _player_data.sprite_back
	_enemy_sprite.sprite_frames = _enemy_data.sprite_front
	_player_sprite.position = _player_data.sprite_pos_offset
	_enemy_sprite.position = _enemy_data.sprite_pos_offset
	_player_sprite.apply_scale(_player_data.sprite_scale)
	_enemy_sprite.apply_scale(_enemy_data.sprite_scale)
	print("Loaded player and enemy sprites")
	
	# Play battle_start animation
	_animation_player.play("battle_start")
	await _animation_player.animation_finished
	
	# Play sprite idle animation (enemy)
	_enemy_sprite.play(&"idle")
	await _enemy_sprite.animation_finished
	
	# setup UI
	_ui.initialize(self, _player_data, _enemy_data)
	_ui.run_button.pressed.connect(_run)
	print("Loaded Battle UI")
	
	# possibly play something with a message
	await _ui.display_message("Battle with %s" % _enemy_data.name)
	
	print("Battle setup complete")
	_change_state(State.PLAYER_TURN)

func _play_hurt_animation(defender: CharacterData) -> void:
	var sprite: AnimatedSprite2D = _player_sprite if defender == _player_data else _enemy_sprite
	var original_pos := sprite.position

	_sfx_player.stream = _HURT_SFX
	_sfx_player.play()
	var jerk_dir := Vector2(5, 0) if defender == _enemy_data else Vector2(-5, 0)

	var jerk := create_tween()
	jerk.tween_property(sprite, "position", original_pos + jerk_dir, 0.05)
	jerk.tween_property(sprite, "position", original_pos - jerk_dir * 0.6, 0.05)
	jerk.tween_property(sprite, "position", original_pos, 0.1)

	var blink := create_tween()
	for i in 5:
		blink.tween_property(sprite, "modulate:a", 0.0, 0.05)
		blink.tween_property(sprite, "modulate:a", 1.0, 0.05)

	await blink.finished

func _play_move_animation(move: MoveData, defender: CharacterData) -> void:
	if move.anim_name.is_empty():
		return
	var defender_pos: Marker2D = _player_pos if defender == _player_data else _enemy_pos
	_effect_sprite.position = defender_pos.position + move.anim_effect_pos_offset
	_effect_sprite.sprite_frames = move.anim_effect
	_effect_sprite.scale = move.anim_effect_scale
	_animation_player.play(move.anim_name)
	await _animation_player.animation_finished

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

func _end_battle(won: bool = false):
	# handle scene change + updates
	GameManager.battle_ended.emit(won)
	GameManager.scene_controller.pop_2d_scene()

# Called from BattleUI buttons
func use_move(move: MoveData):
	print("Used move %s" % move.name)
	_execute_action(_player_data, _enemy_data, move)

func _execute_action(attacker: CharacterData, defender: CharacterData, move: MoveData):
	_change_state(State.ACTION)

	await _ui.display_message("%s used %s!" % [attacker.name, move.name])

	await _play_move_animation(move, defender)
	var damage = _calculate_damage(attacker, defender, move)
	print("Damage: %d" % damage)
	if (damage != 0): 
		await _play_hurt_animation(defender)

	_apply_damage(damage, defender)

	data_updated.emit(_player_data, _enemy_data)
	
	if (damage == 0):
		await _ui.display_message("%s had no effect against %s..." % [move.name, defender.name])
	
	if _check_for_faint():
		return
	
	action_completed.emit()

func _start_enemy_turn():
	_ui.hide_all_menus()
	
	# choose move (requires at least 1 move)
	var chosen_move = _enemy_data.moves.pick_random()
	
	# wait a bit
	await get_tree().create_timer(2.0).timeout
	
	_execute_action(_enemy_data, _player_data, chosen_move)
	# on action -> action
	await action_completed
	_change_state(State.PLAYER_TURN)

func _calculate_damage(attacker: CharacterData, defender: CharacterData, move: MoveData):
	if defender.type == Constants.Element.DARK && move.type != Constants.Element.ANCIENT:
		return 0
	if attacker.type == Constants.Element.DARK:
		return max(int(move.power / 2 * randf_range(0.85, 1)), 1)
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
