extends Node

# warning-ignore:unused_signal
signal changeState

# warning-ignore:unused_argument
func enter(prev : String) -> void:
	#this fixes infinite ammo bug
	var ammo : int = int(get_parent().get_parent().get_reserve() >= 1)
	get_parent().get_parent().set_magazine(get_parent().get_parent().get_magazine() - ammo)
	get_parent().get_parent().set_chamber(get_parent().get_parent().get_chamber() + ammo)
	call_deferred("emit_signal", "changeState", "Ready")

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
	pass
