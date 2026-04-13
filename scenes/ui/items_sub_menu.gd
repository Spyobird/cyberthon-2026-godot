extends CanvasLayer

@onready var item1_text: RichTextLabel = $ItemsMenu/TextContainer/Item1Text
@onready var item2_text: RichTextLabel = $ItemsMenu/TextContainer/Item2Text
@onready var item3_text: RichTextLabel = $ItemsMenu/TextContainer/Item3Text
func _ready() -> void:
	visible = false

func get_longest_text_string(s_array: Array) -> int:
	return s_array.map(func(s): return len(s)).max()
	
func _on_item_menu_selected(item1: Variant, item2: Variant, item3: Variant) -> void:
	visible = true
	var item_array: Array[Variant] = [item1, item2, item3]
	var longest_string_length: int = get_longest_text_string(item_array.filter(func(v): return v != null))
	_update_items(item_array.map((func(v): return v.to_upper() if v != null else "-".repeat(longest_string_length))))

func _on_item_menu_closed() -> void:
	visible = false

func _update_items(item_array: Array) -> void:
	item1_text.text = item_array[0]
	item2_text.text = item_array[1]
	item3_text.text = item_array[2]
