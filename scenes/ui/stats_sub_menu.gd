extends CanvasLayer

@onready var hp_text: RichTextLabel = $StatsMenu/TextContainer/HPText
@onready var atk_text: RichTextLabel = $StatsMenu/TextContainer/ATKText
@onready var def_text: RichTextLabel = $StatsMenu/TextContainer/DEFText

func _ready() -> void:
	visible = false

func _on_status_menu_selected(hp: int, atk: int, def: int) -> void:
	visible = true
	_update_stats(hp, atk, def)

func _on_status_menu_closed() -> void:
	visible = false

func _update_stats(hp: int, atk: int, def: int) -> void:
	hp_text.text = "HP: %d" % hp
	atk_text.text = "ATK: %d" % atk
	def_text.text = "DEF: %d" % def
