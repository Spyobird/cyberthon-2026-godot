extends Node2D

@onready var hp_text: RichTextLabel = $Control/StatsMenu/TextContainer/HPText
@onready var atk_text: RichTextLabel = $Control/StatsMenu/TextContainer/ATKText
@onready var def_text: RichTextLabel = $Control/StatsMenu/TextContainer/DEFText

var _player: Player

func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player_group")
	if _player:
		_player.sync_player_completed.connect(_on_sync_success)
		_update_stats(_player.get_player_state())

func _update_stats(state: PlayerState) -> void:
	hp_text.text = "HP: %d" % state.stats.x
	atk_text.text = "ATK: %d" % state.stats.y
	def_text.text = "DEF: %d" % state.stats.z

func _on_sync_success() -> void:
	_update_stats(_player.get_player_state())
