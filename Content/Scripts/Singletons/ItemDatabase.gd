extends Node

# Load ItemData resources directly 
var ITEMS := {
	"wood": preload("res://Content/Assets/Items/ItemData/wood.tres") as ItemData,
	"flint": preload("res://Content/Assets/Items/ItemData/flint.tres") as ItemData, 
	"stick": preload("res://Content/Assets/Items/ItemData/stick.tres") as ItemData,
	"yarrow": preload("res://Content/Assets/Items/ItemData/yarrow.tres") as ItemData,
	"blue cap": preload("res://Content/Assets/Items/ItemData/bluecap.tres") as ItemData,
	"stone": preload("res://Content/Assets/Items/ItemData/stone.tres") as ItemData,
	"copper": preload("res://Content/Assets/Items/ItemData/copper.tres") as ItemData,
	"iron": preload("res://Content/Assets/Items/ItemData/iron.tres") as ItemData,
	"leaves": preload("res://Content/Assets/Items/ItemData/leaves.tres") as ItemData,
	"porcini": preload("res://Content/Assets/Items/ItemData/porcini.tres") as ItemData,
	"marigold": preload("res://Content/Assets/Items/ItemData/marigold.tres") as ItemData,
	"dandelion": preload("res://Content/Assets/Items/ItemData/dandelion.tres") as ItemData,
	"elderflower": preload("res://Content/Assets/Items/ItemData/elderflower.tres") as ItemData,
	"bluevervain": preload("res://Content/Assets/Items/ItemData/bluevervain.tres") as ItemData,
	"borage": preload("res://Content/Assets/Items/ItemData/borage.tres") as ItemData,
	"wildgarlic": preload("res://Content/Assets/Items/ItemData/wildgarlic.tres") as ItemData,
	"cattail": preload("res://Content/Assets/Items/ItemData/cattail.tres") as ItemData,
	"orangecap": preload("res://Content/Assets/Items/ItemData/orangecap.tres") as ItemData,
	
	
	
}

func _ready():
	print("ItemDatabase ready, items loaded:", ITEMS.keys())
