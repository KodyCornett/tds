extends Node

var attack_damage = 10
var attack_cooldown = 1.0
var last_attack_time = 0.0

func execute(action, target):
	if action == "attack" and target != null and Time.get_ticks_msec() - last_attack_time > attack_cooldown * 1000:
		target.apply_damage(attack_damage)
		last_attack_time = Time.get_ticks_msec()
