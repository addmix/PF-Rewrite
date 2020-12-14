extends Node

export(String) var stateName = "State"

# warning-ignore:unused_signal
signal changeState

# warning-ignore:unused_argument
func enter(prev):
	pass

func exit():
	pass

# warning-ignore:unused_argument
func process(delta):
	pass

func changeFiremode():
	emit_signal("changeState", "Semi")

var burstCam = 0

#start burst
func unhandled_input(event):
	if event.is_action_pressed("Shoot") and get_parent().get_parent().gunMachine.currentState == "Ready":
		burstCam += 1
		get_parent().emit_signal("fire")
		get_tree().set_input_as_handled()
	if event.is_action_released("Shoot") and burstCam >= 3:
		burstCam = 0
		get_tree().set_input_as_handled()

func onReset():
	if burstCam < 3 and Input.is_action_pressed("Shoot") and is_network_master():
		burstCam += 1
		get_parent().emit_signal("fire")
