extends Control

signal item_hovered(item_data)
signal item_unhovered()
signal item_clicked(item_data)

var item_data: ItemData = null

func set_item(new_item_data: ItemData):
	item_data = new_item_data

func _ready():
	mouse_filter = MOUSE_FILTER_STOP
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))

func _on_mouse_entered():
	if item_data:
		emit_signal("item_hovered", item_data)

func _on_mouse_exited():
	emit_signal("item_unhovered")

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if item_data:
			emit_signal("item_clicked", item_data)
