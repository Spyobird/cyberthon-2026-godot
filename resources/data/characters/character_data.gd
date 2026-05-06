class_name CharacterData
extends Resource

@export var name: String = "Character"

@export_group("Sprites")
#@export var sprite_front: Texture2D
#@export var sprite_back: Texture2D
@export var sprite_front: SpriteFrames
@export var sprite_back: SpriteFrames
@export var sprite_scale: Vector2 = Vector2(1.0, 1.0)
@export var sprite_pos_offset: Vector2 = Vector2.ZERO

@export_group("Stats")
@export var max_hp: int = 20
@export var current_hp: int = 20
@export var attack: int = 10
@export var defense: int = 10
@export var type: Constants.Element = Constants.Element.NORMAL

@export_group("Moves")
@export var moves: Array[MoveData] = []

@export_group("Audio")
@export var battle_music: AudioStream = null
@export var battle_music_volume: float = 1.0
@export var battle_music_pos_offset = 0.0
