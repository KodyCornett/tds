# res://AI/BaseAI.gd
extends CharacterBody2D
class_name BaseAI

@export var speed: float = 80.0
@export var wander_speed: float = 10.0
@export var hostile_groups: Array[String] = ["player"]

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $Detection
@onready var fsm: Node = $FSM 
@onready var perception: Node = $Perception
@onready var memory: Node = $Memory
@onready var emotion: Node = $Emotion
@onready var planner: Node = $Planner
@onready var arbitrator: Node = $Arbitrator
@onready var combat: Node = $Combat
@onready var parent = get_parent()

var health: float = 100.0

# --- Remove after testing --- 
func _enter_tree():
	print("[BaseAI] Entered tree:", self.name)


# --- Module wiring helper (robust) ---
func _get_or_create_module(child_name: String, script_path: String):
	# 1) If a child node exists with the requested name, prefer it
	if has_node(child_name):
		var node = get_node(child_name)
		if node:
			# If a script is attached to that node, use it (editor-friendly)
			if node.get_script() != null:
				return node
			# no script attached but node exists — return node anyway (user might have a bare Node)
			return node

	# 2) Otherwise try to load the script resource from disk
	var script_res: Script = null
	# Ensure path is correct & case-matching in your project (adjust if your AI folder uses different capitalization)
	if FileAccess.file_exists(script_path):
		script_res = load(script_path)
	else:
		# try alternative common paths (helpful during refactors)
		if FileAccess.file_exists("res://AI/" + child_name.to_lower() + ".gd"):
			script_res = load("res://AI/" + child_name.to_lower() + ".gd")
		elif FileAccess.file_exists("res://ai/" + child_name.to_lower() + ".gd"):
			script_res = load("res://ai/" + child_name.to_lower() + ".gd")

	if script_res == null:
		push_warning("BaseAI: couldn't find script for '%s' at '%s' (check file/case)." % [child_name, script_path])
		return null

	# 3) Instantiate the script and add as a child node so it becomes visible in the scene tree
	var inst = null
	var _ok = true
	# try to create instance
	inst = script_res.new()
	if inst == null:
		push_warning("BaseAI: failed to instantiate script for '%s' (maybe not a Node). Returning null." % child_name)
		return null

	# If inst is a Node, add to tree, else just return object
	if inst is Node:
		add_child(inst)
		inst.name = child_name
		return inst

	# fallback: return the object (non-node)
	return inst


func _ready():
	fsm.parent = self
	fsm.combat = combat
		
	print("\n[DEBUG] BaseAI READY for:", name)
	print("Path:", get_path())

	print("Children of BaseAI:")
	for child in get_children():
		print(" -", child.name, "(", child, ")")

	fsm = get_node_or_null("FSM")
	perception = get_node_or_null("Perception")
	memory = get_node_or_null("Memory")
	emotion = get_node_or_null("Emotion")
	planner = get_node_or_null("Planner")
	arbitrator = get_node_or_null("Arbitrator")
	combat = get_node_or_null("Combat")

	print("FSM:", fsm)
	print("Perception:", perception)
	print("Memory:", memory)
	print("Emotion:", emotion)
	print("Planner:", planner)
	print("Arbitrator:", arbitrator)
	print("Combat:", combat)

	if fsm:
		fsm.state_timer = randf_range(0.0, 2.0)
	
	fsm.perception = perception
	fsm.combat = combat
	fsm.memory = memory
	fsm.emotion = emotion
	fsm.planner = planner
	fsm.arbitrator = arbitrator
	
	print("=== [BaseAI READY] ===")
	print("Perception:", perception)
	print("Perception has scan:", perception and perception.has_method("scan"))
	print("BaseAI children:", get_children())

	var forest_scene = get_tree().get_current_scene()
	if forest_scene and forest_scene.has_node("Ooze"):
		print("Ooze node children in scene:", forest_scene.get_node("Ooze").get_children())
	else:
		print("[WARN] Could not find Ooze node in current scene.")



func _physics_process(delta: float) -> void:
	var perceived: Array = []
	if typeof(perception) == TYPE_OBJECT and perception.has_method("scan"):
		perceived = perception.scan(detection_area, hostile_groups)

	if memory and memory.has_method("update"):
		memory.update(perceived)

	var emotion_state := "idle"
	if emotion and emotion.has_method("evaluate"):
		emotion_state = emotion.evaluate(memory, health)

	var planned_action := "idle"
	if planner and planner.has_method("plan"):
		planned_action = planner.plan(emotion_state, memory)

	var final_action := planned_action
	if arbitrator and arbitrator.has_method("select"):
		final_action = arbitrator.select(planned_action, emotion_state, fsm)

	handle_action(final_action, perceived, delta)

	# Use FSM for idle movement
	if final_action == "idle" and fsm and fsm.has_method("update"):
		var move_vec = fsm.update(delta, perception, memory, detection_area)
		if typeof(move_vec) == TYPE_VECTOR2 and move_vec != Vector2.ZERO:
			velocity = move_vec.normalized() * speed
		else:
			velocity = Vector2.ZERO

	move_and_slide()


# Default handler (child classes override this)
func handle_action(final_action: String, _perceived: Array, delta: float) -> void:
	# default behavior: use FSM movement when idle, otherwise stand still
	var move_vec := Vector2.ZERO

	if final_action == "idle" and fsm and fsm.has_method("update"):
		var fsm_out = fsm.update(delta, perception, memory, detection_area)
		if typeof(fsm_out) == TYPE_DICTIONARY:
			move_vec = fsm_out.get("move_vec", Vector2.ZERO)
		elif typeof(fsm_out) == TYPE_VECTOR2:
			move_vec = fsm_out
	# else: move_vec stays zero

	velocity = move_vec * wander_speed

	# animation
	if sprite:
		if velocity.length() > 0:
			if sprite.animation != "move":
				sprite.play("move")
		else:
			if sprite.animation != "idle":
				sprite.play("idle")

# Shared helpers
func flee_from_player(player_pos) -> Vector2:
	if player_pos == null:
		return Vector2.ZERO
	var dir = global_position - player_pos
	return dir.normalized() if dir.length() > 0 else Vector2.ZERO
