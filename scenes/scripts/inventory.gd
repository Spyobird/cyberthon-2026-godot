class_name Inventory
extends RefCounted

const _VALID_ITEMS = ["magic wand", "door key"]
const _MAX_SIZE = 4

var _items: Array = []

func _init(items: Array[String] = []):
	for item in items:
		if len(_items) >= _MAX_SIZE:
			break
		var valid_item = _validate_item(item)
		if valid_item == null:
			continue
		_items.append(valid_item)
	
func load_items(items: Array[String]):
	_items.clear()
	for item in items:
		if len(_items) >= _MAX_SIZE:
			break
		var valid_item = _validate_item(item)
		if valid_item == null:
			continue
		_items.append(valid_item)


func read_items():
	return _items

func has_item(item) -> bool:
	return item in _items

func _validate_item(item: String):
	# For now items are strings and handle validation here
	if item.to_lower() in _VALID_ITEMS:
		return item
	print("%s is not a valid item name" % item)
	return null
