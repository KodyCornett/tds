extends Control

@export var stat_name: String = "health"  # Set which stat this bar represents
@onready var bar: ProgressBar = $ProgressBar

func _ready():
	# Set the ProgressBar min and max values
	bar.min_value = 0
	bar.max_value = 100

	# Connect to PlayerStats signal
	PlayerStats.connect("stats_changed", Callable(self, "_update_bar"))

	# Initial update
	_update_bar()

func _update_bar():
	var value: float = 0

	match stat_name:
		"health":
			value = PlayerStats.health
		"stamina":
			value = PlayerStats.stamina
		"hunger":
			value = PlayerStats.hunger
		"thirst":
			value = PlayerStats.thirst
		"temp":
			value = PlayerStats.temperature
		_:
			value = 0

	# Smoothly animate the ProgressBar value
	var tween = get_tree().create_tween()  # Create tween inside the function
	tween.tween_property(bar, "value", value, 0.2)  # 0.2 seconds duration
