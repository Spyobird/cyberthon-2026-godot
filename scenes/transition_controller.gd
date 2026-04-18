class_name TransitionController
extends CanvasLayer

enum TransitionEffect {
	FADE,
	DIRECTIONAL_WIPE,
	CENTER_WIPE,
	GRID_REVEAL
}

signal scene_transition_request_started(new_scene: String, effect: TransitionEffect)

@onready var _transition_screen: TextureRect = $TransitionScreen

func _ready() -> void:
	layer = 10
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	_transition_screen.size = viewport_size
	_transition_screen.position = Vector2.ZERO
	_transition_screen.modulate.a = 0.0

	var img: Image = Image.create(1, 1, false, Image.FORMAT_RGB8)
	img.fill(Color.BLACK)
	_transition_screen.texture = ImageTexture.create_from_image(img)
	_transition_screen.stretch_mode = TextureRect.STRETCH_SCALE

	GameManager.transition_controller = self

	scene_transition_request_started.connect(_on_scene_transition_request_started)

func _on_scene_transition_request_started(new_scene: String, effect: TransitionEffect) -> void:
	match effect:
		TransitionEffect.FADE:
			print("Playing FADE effect")
			await _play_transition(new_scene)
		TransitionEffect.DIRECTIONAL_WIPE:
			print("Playing DIRECTIONAL WIPE effect")
			await _play_transition(new_scene)
		TransitionEffect.CENTER_WIPE:
			print("Playing CENTER WIPE effect")
			await _play_transition(new_scene)
		TransitionEffect.GRID_REVEAL:
			print("Playing GRID REVEAL effect")
			await _play_transition(new_scene)

func _swap_scene(new_scene: String) -> void:
	GameManager.scene_controller.overlay_2d_scene(new_scene)

func _play_transition(new_scene: String) -> void:
	# TODO: drive via Universal Transition Shader
	_swap_scene(new_scene)
