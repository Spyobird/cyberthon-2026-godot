class_name PlayerState
extends Resource

var inventory: Inventory
var stats: Vector3i
var moves: Array[String]

func _init(inventory_raw: Array[String], stats: Vector3i, moves_raw: Array[String]):
	self.inventory = Inventory.new(inventory_raw)
	self.stats = stats
	self.moves = moves_raw
