extends CharacterBody2D
class_name BaseAI

@export var speed: float = 80.0
@export var wander_speed: float = 10.0

@onready var sprite = $AnimatedSprite2D
@onready var detection_area = $Detection
@onready var fsm = $FSM

var perception: Perception
var memory: Memory
var emotion: Emotion
var planner: Planner
var arbitrator: Arbitrator
var combat: Combat

var health: float = 100.0

func _ready():
	perception = load("res://AI/perception.gd").new()
	memory = load("res://AI/memory.gd").new()
	emotion = load("res://AI/emotion.gd").new()
	planner = load("res://AI/planner.gd").new()
	arbitrator = load("res://AI/arbitrator.gd").new()
	combat = load("res://AI/combat.gd").new()
	
	sprite.play("idle")
	fsm.state_timer = randf_range(0.0, 2.0)

func _physics_process(delta):
	var perceived = perception.scan(detection_area)
	memory.update(perceived)
	var emotion_state = emotion.evaluate(memory, health)
	var planned_action = planner.plan(emotion_state, memory)
	var final_action = arbitrator.select(planned_action, emotion_state)
	
	handle_action(final_action, perceived, delta)
	move_and_slide()

# Override this in child AI types
func handle_action(_final_action: String, _perceived: Array, _delta: float) -> void:
	pass

# --- Helper functions shared by all AI ---

func flee_from_player(player_pos: Vector2) -> Vector2:
	if player_pos == null:
		return Vector2.ZERO
	var dir = global_position - player_pos
	return dir.normalized() if dir.length() > 0 else Vector2.ZERO

func wander(delta: float) -> Vector2:
	return fsm.get_wander_vector(delta)
