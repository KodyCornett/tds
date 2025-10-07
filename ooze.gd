extends CharacterBody2D

@export var speed: float = 80.0
@export var wander_speed = 10.0

@onready var sprite = $AnimatedSprite2D
@onready var perception = $Perception
@onready var memory = $Memory
@onready var emotion = $Emotion
@onready var planner = $Planner
@onready var arbitrator = $Arbitrator
@onready var combat = $Combat
@onready var detection_area = $Detection

var health: float = 100.0
var wander_direction = Vector2.ZERO
var wander_timer = 0.0
var pause_timer = 0.0

func _ready():
	sprite.play("idle")

func _physics_process(_delta):
	var perceived = perception.scan(detection_area)
	memory.update(perceived)
	var emotion_state = emotion.evaluate(memory, health)
	var planned_action = planner.plan(emotion_state, memory)
	var final_action = arbitrator.select(planned_action, emotion_state)
	
	var move_vec := Vector2.ZERO

	match final_action:
		"attack":
			var target = perceived[0]["entity"] if perceived.size() > 0 else null
			if target:
				sprite.play("move")
				combat.execute(final_action, target)
				var dir = target.global_position - global_position
				if dir.length() > 0:
					move_vec = dir.normalized() * speed
			else:
				sprite.play("idle")

		"flee":
			var flee_dir = flee_from_player(memory.get("player_last_seen"))
			if flee_dir.length() > 0 and sprite.animation != "move":
				sprite.play("move")
			move_vec = flee_dir * speed

		"idle":
			var wander_dir = wander(_delta)
			if wander_dir.length() > 0 and sprite.animation != "move":
				sprite.play("move")
				move_vec = wander_dir * wander_speed
			
			else:
				if sprite.animation != "idle":
					sprite.play("idle")
				move_vec = Vector2.ZERO

	velocity = move_vec
	move_and_slide()  

# --- Helper functions ---

func flee_from_player(player_pos) -> Vector2:
	if player_pos == null:
		return Vector2.ZERO
	var dir = global_position - player_pos
	return dir.normalized() if dir.length() > 0 else Vector2.ZERO

func wander(delta):
	if pause_timer > 0:
		pause_timer -= delta
		return Vector2.ZERO
	
	wander_timer -= delta
	if wander_timer <= 0 or wander_direction == Vector2.ZERO:
		# Pick a new direction every 1–3 seconds
		wander_timer = randf_range(1.0, 3.0)
		pause_timer = randf_range(0.5, 3.0)
		wander_direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	
	return wander_direction
