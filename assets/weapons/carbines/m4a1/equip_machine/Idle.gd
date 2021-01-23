extends Node

# warning-ignore:unused_signal
signal change_state
signal entered
signal exited
# warning-ignore:unused_signal
signal finished

func enter() -> void:
	
	
	get_parent().EquipPosSpring.target = Vector3.ZERO
	get_parent().EquipRotSpring.target = Vector3.ZERO
	
	emit_signal("entered")

func exit() -> void:
	emit_signal("exited")

# warning-ignore:unused_argument
func process(delta : float) -> void:
	get_parent().EquipPosSpring.positionvelocity(delta)
	get_parent().EquipRotSpring.positionvelocity(delta)

# warning-ignore:unused_argument
func unhandled_input(event : InputEvent) -> void:
	pass
