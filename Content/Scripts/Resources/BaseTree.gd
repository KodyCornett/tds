extends StaticBody2D
class_name BaseTree

@export var health: float = 25
@export var wood_drop: int = 3
@export var item_id: String


@onready var tree_sprite: Sprite2D = $TreeSprite2D
@onready var stump_sprite: Sprite2D = $StumpSprite2D
@onready var area: Area2D = $Area2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready():
	add_to_group("trees")
	stump_sprite.visible = false  # ensure stump is hidden at start

func take_damage(amount: float) -> void:
	health -= amount
	print("[BaseTree] Hit! -TreeDamage:", amount, "| Health:", health)
	
	# Optional: visual feedback
	tree_sprite.modulate = Color(1, 0.5, 0.5)
	await get_tree().create_timer(0.1).timeout
	tree_sprite.modulate = Color(1, 1, 1)
	
	if health <= 0:
		harvest()

func harvest() -> void:
	print("[BaseTree] Harvested:", name, "| Wood gained:", wood_drop)

	# Swap sprites
	tree_sprite.visible = false
	stump_sprite.visible = true

	# Disable interaction
	collision.disabled = true            # disable collision
	area.monitorable = false             # stop detecting bodies

	# Add resources
	Inventory.add_item("wood", wood_drop)

# Optional: reset for respawn
func respawn() -> void:
	health = 25
	tree_sprite.visible = true
	stump_sprite.visible = false
	collision.disabled = false
	area.monitorable = true
