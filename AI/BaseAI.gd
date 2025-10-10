# res://AI/BaseAI.gd
extends CharacterBody2D
class_name BaseAI

@export var speed: float = 80.0
@export var wander_speed: float = 10.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $Detection
@onready var fsm: Node = $FSM  # keep FSM as a node in the scene

# module references (no strict type hints to avoid "Could not find type" issues)
var perception
var memory
var emotion
var planner
var arbitrator
var combat

var health: float = 100.0

func _ready():
	perception = _get_or_instantiate_module("Perception", "res://AI/Perception.gd")
	memory     = _get_or_instantiate_module("Memory",     "res://AI/Memory.gd")
	emotion    = _get_or_instantiate_module("Emotion",    "res://AI/Emotion.gd")
	planner    = _get_or_instantiate_module("Planner",    "res://AI/Planner.gd")
	arbitrator = _get_or_instantiate_module("Arbitrator", "res://AI/Arbitrator.gd")
	combat     = _get_or_instantiate_module("Combat",     "res://AI/Combat.gd")

	if fsm:
		fsm.state_timer = randf_range(0.0, 2.0)

func _get_or_instantiate_module(child_name: String, script_path: String):
	if has_node(child_name):
		var node = get_node(child_name)
		# if there's a script attached to that node, use it (editor-friendly)
		if node and node.get_script() != null:
			return node
	# otherwise instantiate the script as a plain object
	var s = load(script_path)
	return s.new()

func _physics_process(delta: float) -> void:
	var perceived = []
	if perception:
		# perception.scan expects an Area2D or the detection_area
		if typeof(perception) == TYPE_OBJECT and perception.has_method("scan"):
			perceived = perception.scan(detection_area)
		else:
			# safety: empty
			perceived = []

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

	# Delegate actual execution to child classes (or default below)
	handle_action(final_action, perceived, delta)

	# apply movement and animation - handle_action should have set velocity
	move_and_slide()

# Default handler (child classes override this)
func handle_action(final_action: String, _perceived: Array, delta: float) -> void:
	# default behavior: use FSM movement when idle, otherwise stand still
	var move_vec := Vector2.ZERO

	if final_action == "idle" and fsm and fsm.has_method("update"):
		var fsm_out = fsm.update(delta, perception, detection_area, memory)
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
