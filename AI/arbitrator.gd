extends Node

@export var use_fsm_default := true
@onready var fsm = get_parent().get_node("FSM")

func select(planned_action, emotion_state, fsm_node):
	# --- Hybrid arbitration logic ---
	if not use_fsm_default or fsm_node == null:
		return planned_action

	# If the FSM has control (simple/low-stress situations)
	if emotion_state == "idle":
		return fsm_node.get_state_action()  # use fsm_node, not fsm
	
	# Otherwise, let Planner take over (adaptive mode)
	return planned_action
