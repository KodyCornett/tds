extends StaticBody2D
class_name Ore

@export var health: float = 5.0
@export var harvest_amount: int = 1
@export var item_id: String  # connects to ItemDatabase key, like "copper" or "stone"

@onready var ore_sprite: Sprite2D = $OreSprite2D

func _ready() -> void:
	add_to_group("rocks")
	print("[Ore] Ready:", name, "| Health:", health, "| Item:", item_id)

func take_damage(amount: float) -> void:
	health -= amount
	print("[Ore] Hit! Damage:", amount, "| Health:", health)

	# Flash effect
	if ore_sprite:
		ore_sprite.modulate = Color(0.7, 0.7, 0.7)
		await get_tree().create_timer(0.1).timeout
		ore_sprite.modulate = Color(1, 1, 1)

	if health <= 0:
		harvest()

func harvest() -> void:
	if not item_id in ItemDatabase.ITEMS:
		push_warning("[Ore] Invalid item_id:", item_id)
		queue_free()
		return

	var item_data = ItemDatabase.ITEMS[item_id]
	print("[Ore] Harvested:", item_data.display_name, "| Amount:", harvest_amount)
	Inventory.add_item(item_id, harvest_amount)
	queue_free()
