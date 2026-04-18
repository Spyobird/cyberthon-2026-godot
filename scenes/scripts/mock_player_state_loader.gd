class_name MockPlayerStateLoader
extends PlayerStateLoader

func load_player_state():
	return PlayerState.new(
		["magic wand", "door key"],
		Vector3i(100, 45, 45),
		["fireball", "zap_bolt"]
	)
