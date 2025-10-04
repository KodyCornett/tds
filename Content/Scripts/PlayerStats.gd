extends Node
signal stats_changed

var health: float = 100
var stamina: float = 100
var hunger: float = 100
var thirst: float = 100
var temperature: float = 37.0

@export var stamina_recover_rate: float = 5.0
@export var stamina_sprint_drain: float = 10.0   # stamina/sec when sprinting

# New tuning values
@export var base_hunger_drain: float = 0.02       # per second
@export var base_thirst_drain: float = 0.05
@export var hunger_per_stamina: float = 0.02     # hunger lost per 1 stamina spent
@export var thirst_per_stamina: float = 0.05     # thirst lost per 1 stamina spent

var is_sprinting: bool = false
var stamina_spent_this_frame: float = 0.0

func modify_stamina(amount: float) -> void:
	stamina = clamp(stamina + amount, 0, 100)
	if amount < 0:
		stamina_spent_this_frame += -amount
	emit_signal("stats_changed")

func _process(delta: float) -> void:
	stamina_spent_this_frame = 0.0   # reset before frame
	# Stamina drain or recovery
	if is_sprinting and stamina > 0:
		modify_stamina(-stamina_sprint_drain * delta)
	else:
		if stamina < 100:
			modify_stamina(stamina_recover_rate * delta)

	# Base needs drain
	hunger = clamp(hunger - base_hunger_drain * delta, 0, 100)
	thirst = clamp(thirst - base_thirst_drain * delta, 0, 100)

	# Extra drain from actual stamina spent
	if stamina_spent_this_frame > 0:
		hunger = clamp(hunger - hunger_per_stamina * stamina_spent_this_frame, 0, 100)
		thirst = clamp(thirst - thirst_per_stamina * stamina_spent_this_frame, 0, 100)

	emit_signal("stats_changed")
