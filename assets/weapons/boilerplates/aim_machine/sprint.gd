extends Node

signal change_state

var gun : Spatial
onready var nodes : Array = get_children()

var index := 0

func enter() -> void:
	pass

func exit() -> void:
	pass

func get_aim() -> Transform:
	return nodes[index].transform

func unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("change_sight"):
		index += 1
		index = index % nodes.size()
		get_tree().set_input_as_handled()

# warning-ignore:unused_argument
func process(delta : float) -> void:
	if gun.WeaponController.character.MovementMachine.current_state != "Sprint":
		emit_signal("change_state", "Aim")
