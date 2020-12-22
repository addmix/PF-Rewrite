extends Node

export(String) var stateName = "State"

# warning-ignore:unused_signal
signal changeState
signal reset

# warning-ignore:unused_argument
func enter(prev : String) -> void:
	call_deferred("emit_signal", "reset")

func exit() -> void:
	pass

func stop() -> void:
	pass

# warning-ignore:unused_argument
func process(delta : float) -> void:
	pass

# warning-ignore:unused_argument
func unhandled_input(event : InputEvent) -> void:
	pass


func fire() -> void:
	
	pass # Replace with function body.


func _on_FiremodeMachine_fire() -> void:
	if get_parent().currentState == stateName:
		emit_signal("changeState", "Fire")
