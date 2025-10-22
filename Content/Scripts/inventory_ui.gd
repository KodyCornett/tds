## inventory_ui.gd
extends Control

@onready var description_panel = $ItemDescriptionPanel

func _ready():
	Inventory.connect("inventory_changed", Callable(self, "_on_inventory_changed"))

func _on_inventory_changed():
	var grid = $GridContainer
	var item_ids = Inventory.items.keys()
	var slot_count = grid.get_child_count()

	for i in range(slot_count):
		var slot = grid.get_child(i)
		var item_display = slot.get_node("CenterContainer/Panel/item_display") as Sprite2D
		var item_count_label = slot.get_node("item_count") as Label

		if i < item_ids.size():
			var id = item_ids[i]
			var item_data = ItemDatabase.ITEMS[id]

			# Update slot visuals
			item_display.texture = item_data.icon
			slot.set_item(item_data)

			# Connect slot signals once
			if not slot.is_connected("item_hovered", Callable(self, "_on_item_hovered")):
				slot.connect("item_hovered", Callable(self, "_on_item_hovered"))
				slot.connect("item_unhovered", Callable(self, "_on_item_unhovered"))
				slot.connect("item_clicked", Callable(self, "_on_item_clicked"))

			# Stack count
			var quantity = Inventory.items[id]
			item_count_label.text = "x" + str(quantity) if quantity > 1 else ""
		else:
			item_display.texture = null
			item_count_label.text = ""
			slot.set_item(null)
			
func _on_item_hovered(item_data: ItemData):
	description_panel.show_item(item_data)

func _on_item_unhovered():
	description_panel.show_item(null)

func _on_item_clicked(item_data: ItemData):
	description_panel.show_item(item_data)
