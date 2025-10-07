extends Node

func scan(area: Area2D):
	var detected_entities = []
	for body in area.get_overlapping_bodies():
		detected_entities.append({
			"entity": body,
			"position": body.global_position,
			"health": body.health if body.has_method("health") else null
		})
	return detected_entities
