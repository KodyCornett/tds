extends Panel

@onready var name_label = $ItemName
@onready var description_label = $ItemDescription
@onready var icon_texture = $Icon  

func show_item(item_data: ItemData) -> void:
	if item_data:
		name_label.text = item_data.display_name
		description_label.text = item_data.description
		icon_texture.texture = item_data.icon
		visible = true
	else:
		name_label.text = ""
		description_label.text = ""
		icon_texture.texture = null
		visible = false
