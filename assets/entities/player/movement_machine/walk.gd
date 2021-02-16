extends Node

signal change_state
var character : KinematicBody

func enter() -> void:
	character.Sprint.target = 0

func exit() -> void:
	pass

func unhandled_input(event : InputEvent) -> void:
	if character.movement_spring.target.length() > 0 and event.is_action_pressed("sprint"):
		call_deferred("emit_signal", "change_state", "Sprint")
		get_tree().set_input_as_handled()
	elif character.movement_spring.target.length() > 0 and event.is_action_pressed("toggle_sprint"):
		call_deferred("emit_signal", "change_state", "Sprint")
		get_tree().set_input_as_handled()

# warning-ignore:unused_argument
func process(delta : float) -> void:
	if character.movement_spring.target.length() < 0.05:
		emit_signal("change_state", "Idle")
	if Input.is_action_pressed("sprint"):
		call_deferred("emit_signal", "change_state", "Sprint")

