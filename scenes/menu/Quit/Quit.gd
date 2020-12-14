extends PopupDialog


func _on_Quit_pressed():
	get_tree().quit()

func _on_Cancel_pressed():
	hide()
