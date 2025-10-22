extends Node2D
class_name WaterSource

@export var water_type: String = "clean" # clean, dirty, salt
@export var efficiency: float = 0.2      # thirst restored by hand
@export var contamination_risk: float = 0.0
@export var collectible: bool = true

var player_in_range := false

func _ready() -> void:
	var area = $Area2D
	area.connect("body_entered", Callable(self, "_on_body_entered"))
	area.connect("body_exited", Callable(self, "_on_body_exited"))
	add_to_group("water_sources")

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		print("[DEBUG] Player entered water source area: ", water_type)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		print("[DEBUG] Player exited water source area: ", water_type)

func collect_water(player) -> void:
	var has_cup = Inventory.items.has("cup")

	if has_cup:
		var filled_type = "filled_cup_%s" % water_type
		Inventory.add_item(filled_type, 1)
		print("[WaterSource] Player collected %s water in a cup." % water_type)

		# Fully restore thirst
		if "modify_thirst" in player:
			player.modify_thirst(100 - PlayerStats.thirst)
	else:
		print("[WaterSource] Player drank %s water with hands." % water_type)
		if "modify_thirst" in player:
			player.modify_thirst(efficiency * 100)  # efficiency is 0-1, scale to 0-100
