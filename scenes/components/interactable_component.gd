class_name InteractableComponent
extends StaticBody2D

signal interacted(collider)

@export var collidable: bool = true

func interact(collider):
	interacted.emit(collider)
