class_name CharacterData
extends Resource

@export var name: String = "Character"

@export_group("Sprites")
@export var sprite_front: Texture2D
@export var sprite_back: Texture2D

@export_group("Stats")
@export var max_hp: int = 20
@export var attack: int = 10
@export var defense: int = 10
@export var type: Constants.Element = Constants.Element.NORMAL

@export_group("Moves")
@export var moves: Array[MoveData] = []
