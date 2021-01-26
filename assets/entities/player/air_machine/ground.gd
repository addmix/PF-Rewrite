extends Node

signal change_state
var character : KinematicBody

func enter() -> void:
	pass

func exit() -> void:
	pass

func unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("jump") and character.StanceMachine.current_state == "Stand":
		#emit jump signal
		get_parent().emit_signal("jump")
		#change to jumping state
		emit_signal("change_state", "Up")
		#set input as handled
		get_tree().set_input_as_handled()

func process(delta : float) -> void:
	pass
