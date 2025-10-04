extends Control

@export var stat_name: String = "health"
@onready var bar_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	PlayerStats.connect("stats_changed", Callable(self, "_update_bar"))
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

	var frames = bar_sprite.get_sprite_frames()
	var total_frames = frames.get_frame_count(bar_sprite.animation)
	bar_sprite.frame = total_frames - 1 - int((value / 100.0) * (total_frames - 1))
