# ItemDatabase.gd
extends Node 

# Master list of all item definitions
# Key = internal name used by Inventory.add_item()
# Value = dictionary of properties
var ITEMS := {
	"wood": {
		"display_name": "Wood",
		"max_stack": 99
	},
	"herb_green": {
		"display_name": "Herb",
		"max_stack": 20
	},
	"flint": {
		"display_name": "Flint",
		"max_stack": 10
	},
	"stone": {
		"display_name": "Stone",
		"max_stack": 10
	}
	
}

func _ready() -> void:
	# Example: give the player starting items for testing
	Inventory.add_item("wood", 5)
	Inventory.add_item("herb_green", 1)
	Inventory.add_item("stone", 1)
	print(Inventory.items)
