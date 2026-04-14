class_name SlimeEnemy
extends Node2D

# TODO: change with windows exe
const EXEC_PATH = "calc.exe"

@onready var _interactable_component = $InteractableComponent
var _pid = -1

func _ready() -> void:
	_interactable_component.interacted.connect(_on_interacted)

func _process(_delta):
	# This script must have Process Mode set to "Always" to run this!
	if _pid != -1:
		if not OS.is_process_running(_pid):
			get_tree().paused = false
			_pid = -1
			print("Executable closed, game unpaused.")

func _on_interacted(collider):
	print("Slime interacted with ", collider)
	_open_app()
	
func _open_app():
	get_tree().paused = true
	#OS.execute_with_pipe(EXEC_PATH, [], true)
	_pid = OS.create_process("open", ["-a", "Calculator"])
	print("Executable opened, game paused.")
