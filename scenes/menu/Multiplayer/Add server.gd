extends PopupDialog

signal serverAdded

onready var namebox = $MarginContainer/VBoxContainer/Name
onready var ip = $MarginContainer/VBoxContainer/Address

func _on_Add_pressed():
	emit_signal("serverAdded", namebox.text, ip.text)
	namebox.text = ""
	ip.text = ""
	self.hide()

func _on_Cancel_pressed():
	self.hide()
