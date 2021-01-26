extends Node

export(String) var stateName = "State"

# warning-ignore:unused_signal
signal changeState

# warning-ignore:unused_argument
func enter(prev : String) -> void:
	pass

func exit() -> void:
	pass

# warning-ignore:unused_argument
func process(delta : float) -> void:
	pass

func changeFiremode() -> void:
	emit_signal("changeState", "Semi")

var burstCam = 0

#start burst
func unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("shoot") and get_parent().get_parent().GunMachine.current_state == "Ready":
		burstCam += 1
		get_parent().emit_signal("fire")
		get_tree().set_input_as_handled()
	if event.is_action_released("shoot") and burstCam >= 3:
		burstCam = 0
		get_tree().set_input_as_handled()

func onReset() -> void:
	if burstCam < 3 and Input.is_action_pressed("shoot") and is_network_master():
		burstCam += 1
		get_parent().emit_signal("fire")
