extends CharacterBody2D

@export var walk_speed: float = 80.0
@export var run_speed: float = 140.0
@export var chop_cooldown: float = 0.3
@export var mine_cooldown: float = 0.5   # seconds between swings

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var facing: String = "down"
var is_running: bool = false
var is_chopping: bool = false
var is_mining: bool = false
var is_collecting: bool = false
var chop_timer: float = 0.0
var mine_timer: float = 0.0
var hit_targets_this_swing: Array = []  # used for both chopping and mining

const AXE_STAMINA_COST := 20.0
const PICKAXE_STAMINA_COST := 20.0

func _ready() -> void:
	add_to_group("player")
	print("[READY] Player ready, starting idle down")
	anim.play("idle_down")
	anim.frame = 0
	
func _physics_process(delta: float) -> void:
	# --- Cooldowns ---
	if chop_timer > 0:
		chop_timer = max(chop_timer - delta, 0)
	if mine_timer > 0:
		mine_timer = max(mine_timer - delta, 0)

	# --- Chop input ---
	if Input.is_action_just_pressed("chop") and not is_chopping and chop_timer <= 0 and PlayerStats.stamina >= AXE_STAMINA_COST:
		start_chop()

	# --- Mine input ---
	if Input.is_action_just_pressed("mine") and not is_mining and mine_timer <= 0 and PlayerStats.stamina >= PICKAXE_STAMINA_COST:
		start_mine()

	# --- Collect input ---
	if Input.is_action_just_pressed("collect") and not is_chopping and not is_collecting and not is_mining:
		print("[Input] collect pressed")
		try_collect()

	# --- Movement input ---
	var input_vector := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()

	# --- Running ---
	is_running = Input.is_action_pressed("run") and input_vector.length() > 0
	if PlayerStats.stamina <= 0:
		is_running = false
	PlayerStats.is_sprinting = is_running

	# --- Facing ---
	if input_vector.length() > 0:
		if abs(input_vector.x) > abs(input_vector.y):
			facing = "side"
			anim.flip_h = input_vector.x < 0
			$AttackArea.scale.x = -1 if anim.flip_h else 1
		elif input_vector.y < 0:
			facing = "up"
			anim.flip_h = false
			$AttackArea.scale.x = 1
		else:
			facing = "down"
			anim.flip_h = false
			$AttackArea.scale.x = 1
		_update_attack_shapes()

	# --- Movement / animation ---
	if not is_chopping and not is_collecting and not is_mining:
		if input_vector.length() > 0:
			play_move()
		else:
			if not anim.is_playing():
				anim.play("idle_%s" % facing)

	velocity = input_vector * (run_speed if is_running else walk_speed)
	move_and_slide()

func _update_attack_shapes() -> void:
	$AttackArea/Collision_Side.disabled = facing != "side"
	$AttackArea/Collision_Up.disabled = facing != "up"
	$AttackArea/Collision_Down.disabled = facing != "down"

func play_move() -> void:
	if is_chopping or is_collecting or is_mining: return
	anim.play("run_%s" % facing) if is_running else anim.play("walk_%s" % facing)

# --- Chop ---
func start_chop() -> void:
	PlayerStats.modify_stamina(-AXE_STAMINA_COST)
	is_chopping = true
	hit_targets_this_swing.clear()
	anim.play("chop_%s" % facing)
	print("Player started chopping, waiting to enable attack area")
	await get_tree().create_timer(0.3).timeout
	$AttackArea.monitoring = true
	print("Attack area enabled after delay")

# --- Mine ---
func start_mine() -> void:
	PlayerStats.modify_stamina(-PICKAXE_STAMINA_COST)
	is_mining = true
	hit_targets_this_swing.clear()
	var mine_anim = "mine_%s" % facing
	if not anim.sprite_frames.has_animation(mine_anim):
		mine_anim = "axe_%s" % facing
	anim.play(mine_anim)
	print("Player is mining")

	await get_tree().create_timer(0.3).timeout
	$AttackArea.monitoring = true
	
func _on_attack_area_body_entered(body: Node) -> void:
	if not (is_chopping or is_mining):
		return

	var node: Node = body
	while node and not (node is Ore or node is BaseTree):
		node = node.get_parent()
	if node == null:
		return

	# --- Tree chopping ---
	if is_chopping and node is BaseTree and node not in hit_targets_this_swing:
		hit_targets_this_swing.append(node)
		node.take_damage(5)
		print("[Tree-Detect] Hit tree:", node.name)

	# --- Ore mining ---
	elif is_mining and node is Ore and node not in hit_targets_this_swing:
		hit_targets_this_swing.append(node)
		node.take_damage(5)
		print("[Ore-Detect] Hit ore:", node.name)


# --- Anim finished ---
func _on_animated_sprite_animation_finished() -> void:
	var anim_name := anim.animation

	if anim_name.begins_with("mine") and is_mining:
		is_mining = false
		hit_targets_this_swing.clear()
		$AttackArea.monitoring = false
		_play_idle_or_run()

	elif anim_name.begins_with("chop") and is_chopping:
		is_chopping = false
		hit_targets_this_swing.clear()
		$AttackArea.monitoring = false
		_play_idle_or_run()

	elif anim_name.begins_with("collect") and is_collecting:
		is_collecting = false
		for herb in get_tree().get_nodes_in_group("harvestable_herbs"):
			if herb.player_in_range:
				herb.collect()
		_play_idle_or_run()

		
func _play_idle_or_run() -> void:
	if velocity.length() > 0.1:
		anim.play("run_%s" % facing if is_running else "walk_%s" % facing)
	else:
		anim.play("idle_%s" % facing)
	anim.frame = 0

# Herb Collection #
func try_collect() -> void:
	if is_chopping or is_collecting or is_mining:
		return

	# --- Herbs ---
	for herb in get_tree().get_nodes_in_group("harvestable_herbs"):
		if herb.player_in_range:
			is_collecting = true
			anim.play("collect_%s" % facing)
			return

	# --- Water Sources ---
	for water in get_tree().get_nodes_in_group("water_sources"):
		if water.player_in_range:
			is_collecting = true
			anim.play("collect_%s" % facing)
			await get_tree().create_timer(0.4).timeout  # optional small delay for realism
			water.collect_water(self)
			is_collecting = false
			return
