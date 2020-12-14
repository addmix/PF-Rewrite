extends PopupDialog

signal serverEdited

onready var namebox = $MarginContainer/VBoxContainer/Name
onready var ip = $MarginContainer/VBoxContainer/Address

func _on_Save_pressed():
	emit_signal("serverEdited", namebox.text, ip.text)
	namebox.text = ""
	ip.text = ""
	refresh()
	self.hide()

func _on_Cancel_pressed():
	namebox.text = ""
	ip.text = ""
	self.hide()

func begin(oldname, oldip):
	namebox.text = oldname
	ip.text = oldip

func refresh():
	pass
