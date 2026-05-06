class_name MockPlayerStateLoader
extends PlayerStateLoader

func load_player_state():
	return PlayerState.new(
		["magic wand", "door key"],
		Vector3i(100, 20, 20),
		["fireball", "zap_bolt"]
	)
