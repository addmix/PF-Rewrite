extends Control

onready var PausePopup : PopupDialog = $PopupDialog

func _on_Resume_pressed():
	resume()

func _on_Options_pressed():
	#popup options menu
	pass # Replace with function body.

func _on_Quit_pressed():
	Server.close_server()

func pause() -> void:
	PausePopup.popup_centered()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func resume() -> void:
	PausePopup.hide()
	if Players.players[get_tree().get_network_unique_id()].character_instance:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

#only one instance of the pause menu
func _unhandled_input(event):
	if PausePopup.visible:
		if event.is_action_pressed("ui_cancel"):
			resume()
			get_tree().set_input_as_handled()
	else:
		if event.is_action_pressed("ui_pause"):
			pause()
			get_tree().set_input_as_handled()
	
