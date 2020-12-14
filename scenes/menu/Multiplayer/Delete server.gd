extends PopupDialog

signal serverDeleted

func begin(servername):
	$MarginContainer/VBoxContainer/server.text = servername

func _on_Delete_pressed():
	emit_signal("serverDeleted")
	self.hide()

func _on_Cancel_pressed():
	self.hide()
