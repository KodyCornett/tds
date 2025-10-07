extends Node

var memory_data = {}

func update(perceived):
	if perceived.size() > 0:
		for p in perceived:
			if "entity" in p and p["entity"] != null:
				memory_data["player_last_seen"] = p["entity"].global_position
	else:
		# Optionally forget after a while or decay memory
		memory_data["player_last_seen"] = null

func remember(key: String):
	return memory_data.get(key, null)

func has(key: String) -> bool:
	return key in memory_data
