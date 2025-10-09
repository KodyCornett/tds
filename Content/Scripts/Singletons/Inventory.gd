extends Node

signal inventory_changed

# Store items as a dictionary: { "item_id": quantity }
var items: Dictionary = {}

func add_item(id: String, amount: int) -> void:
	# If the item already exists, increase its count
	if items.has(id):
		items[id] += amount
	else:
		items[id] = amount
	emit_signal("inventory_changed")

func remove_item(id: String, amount: int) -> void:
	if not items.has(id):
		return
	items[id] -= amount
	if items[id] <= 0:
		items.erase(id)
	emit_signal("inventory_changed")

func get_quantity(id: String) -> int:
	return items.get(id, 0)

func clear() -> void:
	items.clear()
	emit_signal("inventory_changed")
