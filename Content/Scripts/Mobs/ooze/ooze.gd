extends "res://AI/BaseAI.gd"

func handle_action(final_action: String, perceived: Array, delta: float) -> void:
	var move_vec := Vector2.ZERO
	var is_moving := false

	match final_action:
		"attack":
			var target = perceived[0]["entity"] if perceived.size() > 0 else null
			if target:
				combat.execute(final_action, target)
				var dir = target.global_position - global_position
				if dir.length() > 0:
					move_vec = dir.normalized() * speed
					is_moving = true

		"flee":
			var flee_dir = flee_from_player(memory.remember("player_last_seen"))
			if flee_dir.length() > 0:
				move_vec = flee_dir * speed
				is_moving = true

		"idle":
			move_vec = fsm.update(delta, perception, memory) * wander_speed
			is_moving = move_vec.length() > 0

	if is_moving:
		if sprite.animation != "move":
			sprite.play("move")
	else:
		if sprite.animation != "idle":
			sprite.play("idle")

	velocity = move_vec
