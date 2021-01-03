extends Node

# warning-ignore:unused_signal
signal change_state
signal entered
signal exited
# warning-ignore:unused_signal
signal finished

func enter() -> void:
	get_parent().EquipPositionSpring.target = Vector3.ZERO
	get_parent().EquipRotationSpring.target = Vector3.ZERO
	
	emit_signal("entered")
#	yield()

func exit() -> void:
	emit_signal("exited")
#	yield()

# warning-ignore:unused_argument
func process(delta : float) -> void:
	pass

# warning-ignore:unused_argument
func unhandled_input(event : InputEvent) -> void:
	pass
