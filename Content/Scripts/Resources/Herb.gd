extends Area2D
class_name Herb

@export var item_name: String = "Herb"
@export var amount: int = 1

var player_in_range: bool = false
var player_ref: Node = null

func _ready() -> void:
	add_to_group("harvestable_herbs")

func _on_body_entered(body: Node) -> void:
	print("[Herb] body_entered:", body.name)
	if body.is_in_group("player"):
		player_in_range = true
		player_ref = body

func _on_body_exited(body: Node) -> void:
	if body == player_ref:
		player_in_range = false
		player_ref = null

# Called from the Player when the Collect button is pressed
func collect() -> void:
	Inventory.add_item(item_name, amount)
	print("You received %d %s" % [amount, item_name])
	queue_free()
