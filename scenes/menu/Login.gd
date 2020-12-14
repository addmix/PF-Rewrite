extends PopupDialog

onready var username = $MarginContainer/VBoxContainer/HBoxContainer/Username
onready var password = $MarginContainer/VBoxContainer/HBoxContainer2/Password
onready var login = $MarginContainer/VBoxContainer/HBoxContainer3/Login
onready var cancel = $MarginContainer/VBoxContainer/HBoxContainer3/Cancel

#onready var Gateway = $"/root/Gateway"

func _on_Login_pressed():
	if username.text == "" or password.text == "":
		print("Please enter username and password")
	else:
		login.disabled = true
		cancel.disabled = true
		print("Attempting login")
#		Gateway.ConnectToServer(username.text, password.text)


func _on_Cancel_pressed():
	self.hide()
