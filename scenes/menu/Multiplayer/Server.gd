extends Container

signal pressed

var ip
var port

func _ready():
# warning-ignore:return_value_discarded
	$InfoClient.connect("data_recieved", self, "_on_data_recieved")
# warning-ignore:return_value_discarded
	$InfoClient.connect("error_connecting", self, "_on_error_connecting")

func changeIP(address : String):
	var subs = address.split(":", false, 2)
	
	var string : String = subs[0]
	
	ip = subs[0]
	port = 1909
	if subs.size() > 1:
		if subs[1] == "1909":
			string = ip
		else:
			string = address
			port = int(subs[1])
	
	$InfoClient.setURL("ws://" + str(ip) + ":" + str(port))
	$Button/HBoxContainer/IP.text = string

func changeName(newName):
	name = newName
	$Button/HBoxContainer/Name.text = name

func setPlayerCount(playerCount, playerLimit):
	$Button/HBoxContainer/Playercount.text = playerCount + "/" + playerLimit

func refresh():
	setPlayerCount("N", "A")
	$InfoClient.QueryInfo()

func _connect():
	$InfoClient._connect()

func _disconnect():
	$InfoClient._disconnect()
	$Button/HBoxContainer/Playercount.text = "N/A"

func _on_Button_pressed():
	emit_signal("pressed", self)

func _on_data_recieved(data):
	setPlayerCount(data[1], data[2])

func _on_error_connecting(_err):
	pass

func _exit_tree():
	_disconnect()
