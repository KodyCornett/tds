extends Node

@export var attack_damage := 10
@export var attack_cooldown := 1.0
@export var attack_area: Area2D

@onready var owner_ai: Node = get_parent()
@onready var sprite: AnimatedSprite2D = owner_ai.get_node_or_null("AnimatedSprite2D")

var can_attack := true
var current_target: Node2D = null

func _ready() -> void:
	if owner_ai == null:
		push_error("[Combat] No parent found!")
		return

	if not sprite:
		print("[Combat] Warning: No AnimatedSprite2D found under", owner_ai.name)
	else:
		print("[Combat] Found AnimatedSprite2D:", sprite.name)

	attack_area = owner_ai.get_node_or_null("AttackRange")
	if attack_area:
		if not attack_area.body_entered.is_connected(_on_attack_range_body_entered):
			attack_area.body_entered.connect(_on_attack_range_body_entered)
		if not attack_area.body_exited.is_connected(_on_attack_range_body_exited):
			attack_area.body_exited.connect(_on_attack_range_body_exited)
	else:
		print("[Combat] Warning: No AttackRange found on", owner_ai.name)


func execute(action: String, tgt: Node2D) -> void:
	if action != "attack" or tgt == null:
		return
	if not can_attack:
		return

	print("[Combat] Attacking target:", tgt.name)
	can_attack = false

	# Play attack animation if available
	if sprite and sprite.sprite_frames.has_animation("attack"):
		print("[Combat] Playing 'attack' animation...")
		sprite.play("attack")
	else:
		print("[Combat] No 'attack' animation found for", owner_ai.name)

	# Deal damage immediately
	if tgt.has_method("apply_damage"):
		print("[Combat] Target has taken damage")
		tgt.apply_damage(attack_damage)
	else:
		print("[Combat] Warning: target", tgt.name, "has no apply_damage() method.")

	# Start cooldown timer
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true


func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		current_target = body
		print("[Combat] Player entered attack range!")


func _on_attack_range_body_exited(body: Node2D) -> void:
	if body == current_target:
		current_target = null
		print("[Combat] Player left attack range!")
