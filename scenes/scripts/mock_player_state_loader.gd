class_name MockPlayerStateLoader
extends PlayerStateLoader

func load_player_state():
	return PlayerState.new(
		["magic wand", "item2"],
		Vector3i(100, 20, 20),
		["fireball", "lightning"]
	)
