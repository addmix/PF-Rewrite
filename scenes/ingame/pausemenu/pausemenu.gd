extends Control

onready var PausePopup : PopupDialog = $PopupDialog

func _on_Resume_pressed():
	resume()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_Options_pressed():
	#popup options menu
	pass # Replace with function body.

func _on_Quit_pressed():
	if get_tree().is_network_server():
		Server.close_server()
	else:
		Server.close_server()

func resume() -> void:
	PausePopup.hide()

#only one instance of the pause menu
func _unhandled_input(event):
	if PausePopup.visible:
		if event.is_action_pressed("ui_cancel"):
			resume()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_tree().set_input_as_handled()
	else:
		if event.is_action_pressed("ui_pause"):
			PausePopup.popup_centered()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
