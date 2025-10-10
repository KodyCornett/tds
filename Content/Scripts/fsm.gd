extends Node

var current_state = "idle"
var state_timer = 0.0
var target_position: Vector2 = Vector2.ZERO
var wander_direction = Vector2.ZERO

func update(delta, perception, _memory) -> Vector2:
	state_timer -= delta
	var move_vec =Vector2.ZERO
	
	match current_state:
		"idle":
			if state_timer <= 0:
				if randf() < 0.6:
					transition_to("wander")
				elif randf() < 0.2:
					transition_to("investigate")
				else:
					transition_to("rest")
		
		"wander":
			if state_timer <= 0:
				transition_to("idle")
			else:
				if wander_direction == Vector2.ZERO or randf() < 0.01:
					wander_direction = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
				move_vec = wander_direction
		
		"investigate":
			if target_position == Vector2.ZERO:
				# pick a random interesting object or fake one for now
				var perceived = perception.scan(get_parent().detection_area)
				if perceived.size() > 0:
					target_position = perceived[0]["entity"].global_position
				else:
					target_position = get_parent().global_position + Vector2(randf_range(-100,100), randf_range(-100,100))
			if state_timer <= 0 or get_parent().global_position.distance_to(target_position) < 10:
				target_position = Vector2.ZERO
				transition_to("idle")

		"rest":
			if state_timer <= 0:
				transition_to("idle")
				move_vec = Vector2.ZERO
	return move_vec


func transition_to(new_state: String):
	current_state = new_state
	
	match new_state:
		"idle":
			state_timer = randf_range(1.0, 2.0)
		
		"wander":
			state_timer = randf_range(1.0, 2.0)
		
		"investigate":
			state_timer = randf_range(3.0, 6.0)
		
		"rest":
			state_timer = randf_range(2.0, 5.0)
			
func get_state_action() -> String:
	match current_state:
		"idle":
			return "idle"
		"wander":
			return "idle"
		"investigate":
			return "idle"
		"rest":
			return "idle"
	return "idle"
