# Health.gd
extends Node
@export var max_health := 50.0
var health := max_health

signal died

func apply_damage(amount: float) -> void:
	health -= amount
	print(name, " took ", amount, " damage. HP=", health)
	if health <= 0:
		die()

func die() -> void:
	print(name, " died.")
	emit_signal("died")
	# optional visual: try parent's AnimatedSprite2D or AnimationPlayer
	var parent = get_parent()
	if parent:
		var animp = parent.get_node_or_null("AnimationPlayer")
		if animp:
			animp.play("death")
			await animp.animation_finished
		else:
			var spr = parent.get_node_or_null("AnimatedSprite2D")
			if spr:
				spr.play("death")
				await spr.animation_finished
	parent.queue_free()
