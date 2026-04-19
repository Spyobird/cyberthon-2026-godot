class_name TransitionController
extends CanvasLayer

enum TransitionEffect {
	# Basic (rectangular / gradient wipes)
	FADE,
	DIRECTIONAL_WIPE,
	CORNER_WIPE,
	DIAGONAL_WIPE,
	BLINDER_WIPE,
	STAGGERED_GRID_REVEAL,
	GRID_REVEAL,
	MIXED_STAGGER_REVEAL,
	CROSS_SHAPED,
	DIAGONAL_POPPING_SQUARES,
	STEP_WIPE,
	# Shape (polygon boundary)
	IRIS,
	CENTER_WIPE,
	SPIKE,
	SCRATCH_LINES,
	OVERLAPPING_DIAMONDS,
	SPIKE_TRAP,
	# Clock (radial sweep)
	CORNER_CLOCK,
	CENTER_CLOCK,
	FAN,
	SEAMLESS_STRIPED_FLOWER,
	HOURGLASS_WIPE,
	DOUBLE_DIAMOND,
}

const TRANSITION_DURATION := 5.0

signal scene_transition_request_started(new_scene: String, effect: TransitionEffect)

@onready var _transition_screen: TextureRect = $TransitionScreen

var _shader_material: ShaderMaterial

func _ready() -> void:
	layer = 10
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	_transition_screen.size = viewport_size
	_transition_screen.position = Vector2.ZERO

	var img: Image = Image.create(1, 1, false, Image.FORMAT_RGB8)
	img.fill(Color.BLACK)
	_transition_screen.texture = ImageTexture.create_from_image(img)
	_transition_screen.stretch_mode = TextureRect.STRETCH_SCALE

	_shader_material = $TransitionScreen.material

	#_shader_material = ShaderMaterial.new()
	#_shader_material.shader = preload("res://assets/shaders/transition.gdshader")

	_set_invisible()
	
	GameManager.transition_controller = self
	scene_transition_request_started.connect(_on_scene_transition_request_started)

# ---------------------------------------------------------------------------
# Signal handler
# ---------------------------------------------------------------------------

func _on_scene_transition_request_started(new_scene: String, effect: TransitionEffect) -> void:
	await _play_transition(new_scene, effect)

# ---------------------------------------------------------------------------
# Transition dispatch
# ---------------------------------------------------------------------------

func _play_transition(new_scene: String, effect: TransitionEffect) -> void:
	match effect:

		# ---- Basic type ----

		TransitionEffect.FADE:
			# grid_size=(0,0) collapses every pixel to uv=(0,0), so the whole screen
			# fades uniformly. The feather zone is centred at progress=0, so we sweep
			# from +1.0 (transparent) through 0 to -1.0 (opaque).
			await _play_shader_transition(new_scene, {
				"transition_type": 0,
				"grid_size": Vector2(0.0, 0.0),
				"basic_feather": 1.0,
				"_p_transparent": 1.0,
				"_p_opaque": -1.0,
			})

		TransitionEffect.DIRECTIONAL_WIPE:
			await _play_shader_transition(new_scene, {
				"transition_type": 0,
				"grid_size": Vector2(1.0, 0.0),
				"basic_feather": 0.02,
			})

		TransitionEffect.CORNER_WIPE:
			await _play_shader_transition(new_scene, {
				"transition_type": 0,
				"grid_size": Vector2(1.0, 1.0),
			})

		TransitionEffect.DIAGONAL_WIPE:
			await _play_shader_transition(new_scene, {
				"transition_type": 0,
				"grid_size": Vector2(1.0, 1.0),
				"rotation_angle": 45.0,
			})

		TransitionEffect.BLINDER_WIPE:
			# abs(y) > 2 creates horizontal blind strips.
			await _play_shader_transition(new_scene, {
				"transition_type": 0,
				"grid_size": Vector2(0.0, 5.0),
			})

		TransitionEffect.GRID_REVEAL:
			await _play_shader_transition(new_scene, {
				"transition_type": 0,
				"grid_size": Vector2(10.0, 10.0),
				"position": Vector2(0.5, 0.5),
				"basic_feather": 0.05,
			})

		TransitionEffect.STAGGERED_GRID_REVEAL:
			await _play_shader_transition(new_scene, {
				"transition_type": 0,
				"grid_size": Vector2(10.0, 10.0),
				"position": Vector2(0.5, 0.5),
				"stagger": Vector2(1.0, 0.0),
			})

		TransitionEffect.MIXED_STAGGER_REVEAL:
			await _play_shader_transition(new_scene, {
				"transition_type": 0,
				"grid_size": Vector2(5.0, 5.0),
				"position": Vector2(0.5, 0.5),
				"stagger": Vector2(1.0, 1.0),
			})

		TransitionEffect.CROSS_SHAPED:
			await _play_shader_transition(new_scene, {
				"transition_type": 0,
				"position": Vector2(0.5, 0.5),
				"stagger": Vector2(1.0, 1.0),
			})

		TransitionEffect.DIAGONAL_POPPING_SQUARES:
			await _play_shader_transition(new_scene, {
				"transition_type": 0,
				"grid_size": Vector2(5.0, 5.0),
				"position": Vector2(0.5, 0.5),
				"progress_bias": Vector2(10.0, 10.0),
				"_p_transparent": 0.0,
				"_p_opaque": 2.0,
			})

		TransitionEffect.STEP_WIPE:
			await _play_shader_transition(new_scene, {
				"transition_type": 0,
				"grid_size": Vector2(5.0, 0.0),
				"position": Vector2(0.5, 0.5),
				"progress_bias": Vector2(5.0, 0.0),
			})

		# ---- Shape type ----

		TransitionEffect.IRIS:
			# Iris opens/closes as a smooth circle (64-sided polygon ≈ circle).
			# invert=false: progress=0 → opaque, progress=2 → transparent.
			await _play_shader_transition(new_scene, {
				"transition_type": 2,
				"position": Vector2(0.5, 0.5),
				"edges": 64,
				"shape_feather": 0.1,
			})

		TransitionEffect.CENTER_WIPE:
			# invert=true flips the roles: progress=0 → transparent, progress=2 → opaque.
			# Black circle expands from centre on cover, contracts on reveal.
			await _play_shader_transition(new_scene, {
				"transition_type": 2,
				"position": Vector2(0.5, 0.5),
				"edges": 64,
				"shape_feather": 0.05,
				"invert": true,
			})

		TransitionEffect.SPIKE:
			await _play_shader_transition(new_scene, {
				"transition_type": 2,
				"position": Vector2(0.5, 0.5),
				"edges": 3,
				"grid_size": Vector2(0.5, 1.0),
				"rotation_angle": 0.0,
			})

		TransitionEffect.SCRATCH_LINES:
			await _play_shader_transition(new_scene, {
				"transition_type": 2,
				"position": Vector2(0.5, 0.5),
				"grid_size": Vector2(50.0, 5.0),
				"edges": 3,
				"flip_frequency": Vector2i(2, 1),
			})

		TransitionEffect.OVERLAPPING_DIAMONDS:
			await _play_shader_transition(new_scene, {
				"transition_type": 2,
				"position": Vector2(0.5, 0.5),
				"grid_size": Vector2(0.5, 50.0),
				"edges": 3,
				"shape_feather": 0.0,
			})

		TransitionEffect.SPIKE_TRAP:
			await _play_shader_transition(new_scene, {
				"transition_type": 2,
				"position": Vector2(0.0, 1.0),
				"grid_size": Vector2(1.0, 3.0),
				"rotation_angle": 30.0,
				"global_x_mirror": true,
				"local_y_mirror": true,
				"edges": 3,
			})

		# ---- Clock type ----
		# Clock sweeps complete one full rotation at progress=1, so progress range
		# is 0→1 rather than 0→2. All invert=true recipes use _p_transparent=1.0,
		# _p_opaque=0.0; invert=false recipes use _p_transparent=0.0, _p_opaque=1.0.

		TransitionEffect.CORNER_CLOCK:
			await _play_shader_transition(new_scene, {
				"transition_type": 3,
				"grid_size": Vector2(1.0, 1.0),
				"invert": true,
				"_p_transparent": 1.0,
				"_p_opaque": 0.0,
			})

		TransitionEffect.CENTER_CLOCK:
			await _play_shader_transition(new_scene, {
				"transition_type": 3,
				"position": Vector2(0.5, 0.5),
				"grid_size": Vector2(1.0, 1.0),
				"invert": true,
				"_p_transparent": 1.0,
				"_p_opaque": 0.0,
			})

		TransitionEffect.FAN:
			await _play_shader_transition(new_scene, {
				"transition_type": 3,
				"grid_size": Vector2(1.0, 1.0),
				"invert": true,
				"sectors": 4,
				"_p_transparent": 1.0,
				"_p_opaque": 0.0,
			})

		TransitionEffect.SEAMLESS_STRIPED_FLOWER:
			await _play_shader_transition(new_scene, {
				"transition_type": 3,
				"grid_size": Vector2(5.0, 5.0),
				"invert": true,
				"flip_frequency": Vector2i(2, 2),
				"sectors": 16,
				"_p_transparent": 1.0,
				"_p_opaque": 0.0,
			})

		TransitionEffect.HOURGLASS_WIPE:
			await _play_shader_transition(new_scene, {
				"transition_type": 3,
				"position": Vector2(0.5, 0.5),
				"stagger": Vector2(1.0, 1.0),
				"flip_frequency": Vector2i(2, 2),
				"sectors": 2,
				"_p_transparent": 0.0,
				"_p_opaque": 1.0,
			})

		TransitionEffect.DOUBLE_DIAMOND:
			await _play_shader_transition(new_scene, {
				"transition_type": 3,
				"position": Vector2(0.5, 0.5),
				"grid_size": Vector2(2.0, 2.0),
				"local_x_mirror": true,
				"local_y_mirror": true,
				"sectors": 4,
				"_p_transparent": 0.0,
				"_p_opaque": 1.0,
			})

# ---------------------------------------------------------------------------
# Core shader transition
#
# params may contain shader parameter names AND two optional private keys:
#   "_p_transparent" — progress value where the overlay is fully transparent
#   "_p_opaque"      — progress value where the overlay is fully opaque
#
# Defaults (when keys are absent):
#   invert=false  →  transparent=2.0, opaque=0.0
#   invert=true   →  transparent=0.0, opaque=2.0
#
# Clock transitions complete at progress=1, so always pass explicit overrides.
# ---------------------------------------------------------------------------

func _play_shader_transition(new_scene: String, params: Dictionary) -> void:
	var inverted: bool = params.get("invert", false)

	var p_transparent: float = params.get(
		"_p_transparent", 0.0 if inverted else 2.0
	)
	var p_opaque: float = params.get(
		"_p_opaque", 2.0 if inverted else 0.0
	)

	_apply_shader_params(params)

	# Cover: sweep from transparent → opaque
	_shader_material.set_shader_parameter("progress", p_transparent)
	var tween := create_tween().set_ease(Tween.EASE_IN)
	
	tween.tween_method(
		func(v: float) -> void: _shader_material.set_shader_parameter("progress", v),
		p_transparent, p_opaque, TRANSITION_DURATION
	)
	await tween.finished

	GameManager.scene_controller.overlay_2d_scene(new_scene)

	# Reveal: sweep from opaque → transparent
	tween = create_tween().set_ease(Tween.EASE_OUT)
	
	tween.tween_method(
		func(v: float) -> void: _shader_material.set_shader_parameter("progress", v),
		p_opaque, p_transparent, TRANSITION_DURATION
	)
	await tween.finished

	_set_invisible()

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

func _apply_shader_params(params: Dictionary) -> void:
	_transition_screen.mouse_filter = Control.MOUSE_FILTER_STOP

	# Reset every shader uniform to a safe default so values never bleed
	# between successive transitions.
	#_shader_material.set_shader_parameter("use_sprite_alpha", false)
	#_shader_material.set_shader_parameter("transition_type", 0)
	#_shader_material.set_shader_parameter("position", Vector2(0.0, 0.0))
	#_shader_material.set_shader_parameter("invert", false)
	#_shader_material.set_shader_parameter("grid_size", Vector2(1.0, 1.0))
	#_shader_material.set_shader_parameter("rotation_angle", 0.0)
	#_shader_material.set_shader_parameter("global_x_mirror", false)
	#_shader_material.set_shader_parameter("global_y_mirror", false)
	#_shader_material.set_shader_parameter("local_x_mirror", false)
	#_shader_material.set_shader_parameter("local_y_mirror", false)
	#_shader_material.set_shader_parameter("stagger", Vector2(0.0, 0.0))
	#_shader_material.set_shader_parameter("cumulative_stagger_flip", false)
	#_shader_material.set_shader_parameter("cumulative_stagger", Vector2(0.0, 0.0))
	#_shader_material.set_shader_parameter("stagger_frequency", Vector2i(2, 2))
	#_shader_material.set_shader_parameter("flip_frequency", Vector2i(1, 1))
	#_shader_material.set_shader_parameter("basic_feather", 0.0)
	#_shader_material.set_shader_parameter("edges", 6)
	#_shader_material.set_shader_parameter("shape_feather", 0.1)
	#_shader_material.set_shader_parameter("sectors", 1)
	#_shader_material.set_shader_parameter("clock_feather", 0.0)
	#_shader_material.set_shader_parameter("progress_bias", Vector2(0.0, 0.0))

	# Apply per-effect overrides, skipping private _p_* keys
	for key: String in params:
		if not key.begins_with("_"):
			_shader_material.set_shader_parameter(key, params[key])

	_transition_screen.modulate.a = 1.0
	_transition_screen.material = _shader_material

func _set_invisible() -> void:
	_transition_screen.material = null
	_transition_screen.modulate.a = 0.0
	_transition_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
