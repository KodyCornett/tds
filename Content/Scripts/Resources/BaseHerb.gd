# BaseHerb.gd #
extends Area2D
class_name BaseHerb

@export var herb_name: String = "herb"
@export var harvest_amount: int = 1
@export var item_id: String

@onready var herb_sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var player_in_range: bool = false
var harvested: bool = false

func _ready():
	add_to_group("harvestable_herbs")

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false

func collect() -> void:
	if harvested: 
		return
	harvest()

func harvest() -> void:
	print("[BaseHerb] Collected:", herb_name, "| Amount:", harvest_amount)
	if item_id != "":
		Inventory.add_item(item_id, harvest_amount)
	else:
		push_warning("Item missing item_id for " + herb_name)

	queue_free()
	harvested = true

	# Object disappears
	queue_free()
	harvested = true
