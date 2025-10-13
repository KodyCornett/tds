extends Node

signal inventory_changed
var items: Dictionary = {}

func add_item(id: String, amount: int) -> void:
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
