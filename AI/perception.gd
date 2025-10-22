# perception.gd
extends Node

@export var detection_area: Area2D
@onready var owner_ai = get_parent()

var detected_bodies: Array = []


func _ready():
	pass

# Returns array of dictionaries for all detected hostile entities
func scan(area: Area2D, hostile_groups: Array = []) -> Array:
	var detected_entities: Array = []
	if area == null:
		return detected_entities
	
	for body in area.get_overlapping_bodies():
		var entity = body
		if body is Area2D and body.get_parent():
			entity = body.get_parent()

		if not is_instance_valid(entity):
			continue

		# Skip self
		if entity == area.get_parent():
			continue

		var _entity_groups = entity.get_groups()

		# If hostile groups are specified, skip non-matching entities
		if hostile_groups.size() > 0:
			var hostile_found := false
			for g in hostile_groups:
				if entity.is_in_group(g):
					hostile_found = true
					break
			if not hostile_found:
				continue

		var info = {
			"entity": entity,
			"position": entity.global_position,
			"health": (entity.health if "health" in entity else null)
		}
		
		detected_entities.append(info)
	
	return detected_entities


func _on_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		detected_bodies.append(body)
		owner_ai.fsm.transition_to("attack") 
		print("[Perception] Player detected!")


func _on_detection_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		detected_bodies.erase(body)
		print("[Perception] Player lost!")
