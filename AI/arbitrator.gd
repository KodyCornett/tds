extends Node

@export var use_fsm_default := true
@onready var fsm = get_parent().get_node("FSM")

func select(planned_action, emotion_state):
	# --- Hybrid arbitration logic ---
	if not use_fsm_default:
		return planned_action

	# If the FSM has control (simple/low-stress situations)
	if emotion_state == "idle":
		return fsm.get_state_action()
	
	# Otherwise, let Planner take over (adaptive mode)
	return planned_action
