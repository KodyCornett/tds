extends Node

func evaluate(memory, current_health):
	var player_pos = memory.get("player_last_seen")
	
	if player_pos != null and current_health < 30:
		return "fear"
	elif player_pos != null:
		return "aggressive"
	else: 
		return "idle"
