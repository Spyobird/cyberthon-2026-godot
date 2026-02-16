class_name PlayerState
extends Resource

var inventory: Array[String]
var stats: Vector3i
var moves: Array[String]

func _init(inventory: Array[String], stats: Vector3i, moves: Array[String]):
	self.inventory = inventory
	self.stats = stats
	self.moves = moves
