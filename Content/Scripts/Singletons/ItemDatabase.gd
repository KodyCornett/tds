extends Node

# Load ItemData resources directly
var ITEMS := {
	"wood": preload("res://Content/Assets/Items/wood.tres") as ItemData,
	"flint": preload("res://Content/Assets/Items/flint.tres") as ItemData, 
	"stick": preload("res://Content/Assets/Items/stick.tres") as ItemData,
	"yarrow": preload("res://Content/Assets/Items/yarrow.tres") as ItemData  
	
}

func _ready():
	print("ItemDatabase ready, items loaded:", ITEMS.keys())
