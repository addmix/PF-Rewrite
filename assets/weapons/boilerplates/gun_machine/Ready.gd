extends Node

# warning-ignore:unused_signal
signal change_state
# warning-ignore:unused_signal
signal reset

# warning-ignore:unused_argument
func enter(prev : String) -> void:
	print("enter")
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
	if get_parent().current_state == name:
		call_deferred("emit_signal", "change_state", "Fire")
