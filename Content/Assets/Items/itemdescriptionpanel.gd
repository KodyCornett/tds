extends Panel

@onready var name_label = $ItemName
@onready var description_label = $ItemDescription
@onready var icon_texture = $ItemIcon

func show_item(item_data):
	if item_data:
		name_label.text = item_data.item_name
		description_label.text = item_data.description
		if icon_texture:
			icon_texture.texture = item_data.icon
	else:
		name_label.text = ""
		description_label.text = ""
		if icon_texture:
			icon_texture.texture = null
