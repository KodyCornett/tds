extends StaticBody2D
class_name Ore

@export var health: float = 5.0
@export var loot_table: Dictionary
@export var item_id: String


@onready var ore_sprite: Sprite2D = $OreSprite2D

func _ready() -> void:
	add_to_group("rocks")  # keep using the rocks group
	print("[Ore] Ready:", name, "| Health:", health)

func take_damage(amount: float) -> void:
	health -= amount
	print("[Ore] Hit! Damage:", amount, "| Health:", health)

	# Flash effect for feedback
	if ore_sprite:
		ore_sprite.modulate = Color(0.7, 0.7, 0.7)
		await get_tree().create_timer(0.1).timeout
		ore_sprite.modulate = Color(1, 1, 1)

	if health <= 0:
		harvest()

func harvest() -> void:
	print("[Ore] Harvested! Loot:", loot_table)
	# TODO: Add loot to inventory system
	queue_free()
