class_name MoveData
extends Resource

@export var name: String = "Move"
@export var power: int = 40
@export var accuracy: int = 100
@export var type: Constants.Element = Constants.Element.NORMAL

@export_group("Animation")
@export var anim_effect: SpriteFrames
@export var anim_effect_scale: Vector2 = Vector2(1, 1)
@export var anim_effect_pos_offset: Vector2 = Vector2.ZERO
