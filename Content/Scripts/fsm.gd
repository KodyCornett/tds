# fsm.gd
extends Node

@onready var owner_ai = get_parent()
@onready var combat: Node = get_parent().get_node_or_null("Combat")

var parent: Node = null
var current_state = "idle"
var state_timer = 0.0
var target_position: Vector2 = Vector2.ZERO
var wander_direction = Vector2.ZERO
var current_target: Node2D = null
var detection_area: Area2D = null
var attack_range_area: Area2D = null
var state = "idle"
var attack_timer := 0.0
var out_of_range_timer := 0.0

func ready():
	if parent.has_signal("attack_finished"):
		parent.connect("attack_finished", Callable(self, "_on_attack_finished"))

func update(delta, perception, _memory, _detection_area) -> Vector2:
	if parent == null:
		parent = get_parent()
	
	if detection_area == null and parent.has_node("Detection"):
		detection_area = parent.get_node("Detection")
	if attack_range_area == null and parent.has_node("AttackRange"):
		attack_range_area = parent.get_node("AttackRange")
	
	state_timer -= delta
	var move_vec = Vector2.ZERO
	
	
	match current_state:
		"idle", "wander", "rest":
			# Scan for targets in detection area
			var perceived = perception.scan(detection_area, parent.hostile_groups)
			if perceived.size() > 0:
				current_target = perceived[0]["entity"]
				transition_to("attack")
			else:
				handle_passive_states(delta, move_vec)

		"attack":
			if not is_instance_valid(current_target):
				print("[FSM] attack: lost target (invalid)")
				current_target = null
				transition_to("idle")
				return move_vec

			var in_range := false
			if attack_range_area:
				in_range = attack_range_area.get_overlapping_bodies().has(current_target)

			var distance = parent.global_position.distance_to(current_target.global_position)
			print("[FSM] attack: target:", current_target.name, " distance:", distance, " in_range:", in_range)

			if in_range:
				move_vec = Vector2.ZERO
				out_of_range_timer = 0.0  # reset loss timer
				if not parent.is_attacking:
					parent._attempt_attack(current_target)
			else:
				out_of_range_timer += delta

				# --- MOVEMENT / CHASE BEHAVIOR ---
				move_vec = (current_target.global_position - parent.global_position).normalized()
				# switch to movement animation if not already
				if parent.animated_sprite and parent.animated_sprite.animation != "move":
					parent.animated_sprite.play("move")

				# --- LOSE INTEREST BEHAVIOR ---
				if out_of_range_timer > 3.0:
					print("[FSM] attack: lost interest, returning to wander")
					current_target = null
					transition_to("wander")
					out_of_range_timer = 0.0
					return move_vec

	return move_vec

func handle_passive_states(_delta, move_vec):
	if current_state == "wander":
		if state_timer <= 0:
			transition_to("idle")
		else:
			if wander_direction == Vector2.ZERO or randf() < 0.01:
				wander_direction = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
			move_vec = wander_direction
	elif current_state == "rest":
		if state_timer <= 0:
			transition_to("idle")
	elif current_state == "idle":
		if state_timer <= 0:
			var roll = randf()
			if roll < 0.7:
				transition_to("wander")
			elif roll < 0.9:
				transition_to("rest")
	return move_vec

func transition_to(new_state: String):
	if new_state == current_state:
		return
	print("[FSM] Transition:", current_state, "→", new_state)
	current_state = new_state
	match new_state:
		"idle":
			state_timer = randf_range(1.0, 2.0)
		"wander":
			state_timer = randf_range(1.0, 2.0)
		"rest":
			state_timer = randf_range(2.0, 4.0)
		"attack":
			state_timer = randf_range(3.0, 6.0)
			
func get_state_action() -> String:
	match current_state:
		"idle":
			return "idle"
		"wander":
			return "move"  # or "walk" if that's your name
		"investigate":
			return "move"
		"rest":
			return "idle"
		"attack":
			return "attack"
	return "idle"
	
func _physics_process(delta):
	attack_timer = max(0, attack_timer - delta)
	
func _on_attack_finished():
	attack_timer = 0 
