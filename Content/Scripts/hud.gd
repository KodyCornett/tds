extends CanvasLayer

@onready var inventory_ui = $InventoryUI

func _ready():
	inventory_ui.visible = false

func _input(event):
	if event.is_action_pressed("toggle_inventory"):
		inventory_ui.visible = !inventory_ui.visible
