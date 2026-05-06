class_name MessageManager
extends CanvasLayer

signal message_box_opened
signal message_box_closed

@export var delay_ms: float = 15
@onready var _box: NinePatchRect = $Control/NinePatchRect
@onready var _label: RichTextLabel = $Control/NinePatchRect/RichTextLabel
var is_scrolling: bool = false
var _messages: Array[String] = []

func _ready() -> void:
	GameManager.register_message_manager(self) # register with game manager
	
	_label.bbcode_enabled = true

func play_text(...messages):
	if is_reading():
		return
	if len(messages) == 0:
		return
	
	message_box_opened.emit()
	
	_messages.assign(messages.filter(func(x): return x is String))
	scroll_text()

func is_reading() -> bool:
	return _box.visible

func scroll_text():
	if is_scrolling:
		is_scrolling = false 
		_label.visible_characters = _label.get_total_character_count()
		return
	if not is_reading():
		_box.visible = true
	if len(_messages) == 0:
		_box.visible = false
		message_box_closed.emit()
		return
	
	is_scrolling = true
	_label.text = _messages[0]
	_label.visible_characters = 0 # Hide everything initially
	
	var total_chars = _label.get_total_character_count()
	for i in range(total_chars):
		# when an interrupt happens
		if not is_scrolling:
			break
		_label.visible_characters += 1
		await get_tree().create_timer(delay_ms/1000).timeout
	
	_messages.pop_front()
	is_scrolling = false
