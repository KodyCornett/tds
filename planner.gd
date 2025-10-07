extends Node

func plan(emotion_state, _memory):
	if emotion_state == "fear":
		return "flee"
	elif emotion_state == "aggressive":
		return "attack"
	else:
		return "idle"
