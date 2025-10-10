extends Ore

func _ready() -> void:
	name = "Copper"
	add_to_group("rocks")

	# Define custom loot and health
	loot_table = {"copper": 3}
	health = 8.0

	super._ready()
