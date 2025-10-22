extends "res://AI/BaseAI.gd"

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player = get_node_or_null("AnimationPlayer")

@export var approach_speed := 80.0
@export var attack_range_radius := 28.0
@export var attack_duration := 1  # seconds – tweak until it feels good
@export var attack_cooldown := 1.2  # seconds between attacks

var current_target = null
var is_attacking = false

func _ready():
	add_to_group("ooze")
	combat = $Combat
	fsm = $FSM
	perception = $Perception
	

# main AI decision loop from BaseAI
func handle_action(final_action: String, perceived: Array, delta: float) -> void:
	var move_vec := Vector2.ZERO
	var is_moving := false

	match final_action:
		"attack":
			var target = _get_target(perceived)
			if target:
				var dir = target.global_position - global_position
				var dist = dir.length()

				if dist > attack_range_radius:
					# move toward target
					move_vec = dir.normalized() * approach_speed
					is_moving = true
				else:
					# stop and attack
					move_vec = Vector2.ZERO
					is_moving = false
					print("[Ooze] in range, try attack on ", target.name)
					_attempt_attack(target)

		"flee":
			var flee_dir = flee_from_player(memory.remember("player_last_seen"))
			if flee_dir.length() > 0:
				move_vec = flee_dir * speed
				is_moving = true

		"idle":
			move_vec = fsm.update(delta, perception, memory, detection_area) * wander_speed
			is_moving = move_vec.length() > 0

	# apply movement
	velocity = move_vec

	# animation logic
	if is_attacking:
		# attack animation already playing
		pass
	elif is_moving:
		if animated_sprite.animation != "move":
			animated_sprite.play("move")
	else:
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")

# --- INTERNAL HELPERS ---

func _get_target(perceived: Array) -> Node:
	# prefer current_target if still valid
	if current_target and is_instance_valid(current_target):
		return current_target
	# else pick first perceived
	if perceived.size() > 0:
		var new_target = perceived[0]["entity"]
		current_target = new_target
		return new_target
	return null

func _attempt_attack(target: Node2D):
	if is_attacking or not is_instance_valid(target):
		return
	is_attacking = true

	if animated_sprite and animated_sprite.sprite_frames.has_animation("attack"):
		animated_sprite.play("attack")

	await get_tree().create_timer(attack_duration).timeout

	# Only deal damage if still in range
	var distance = global_position.distance_to(target.global_position)
	if distance <= attack_range_radius:
		print("[Ooze] Attacking target within range:", distance)
		if combat:
			combat.execute("attack", target)
	else:
		print("[Ooze] Target out of range:", distance)

	# Return to idle visually
	if animated_sprite and animated_sprite.sprite_frames.has_animation("idle"):
		animated_sprite.play("idle")

	await get_tree().create_timer(attack_cooldown).timeout
	is_attacking = false
