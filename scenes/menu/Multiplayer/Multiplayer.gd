extends Popup

#var FileUtils = preload("res://Utils/FileUtils.gd")

var selected
var server = preload("res://scenes/menu/multiplayer/server.tscn")

func _ready():
	load_servers()

#individual servers
func _onServerPressed(ser):
	selected = ser

#adding servers and related buttons
func _on_Add_server_pressed():
	$"Add server".popup_centered()

#recieves server info from add server popup
func _on_Add_server_serverAdded(name, ip):
	add_server(name, ip)

#instances server button
func add_server(servername, serverIP):
	var instance = server.instance()
	instance.changeName(servername)
	instance.changeIP(serverIP)
	
	instance.connect("pressed", self, "_onServerPressed")
	$TabContainer/Favorites/MarginContainer2/VBoxContainer/ScrollContainer/VBoxContainer.add_child(instance)

#editing servers and related buttons
func _on_Edit_server_pressed():
	if selected != null:
		editServer(selected)

#recieved server info from edit server popup
func _on_Edit_server_serverEdited(newname, ip):
	selected.changeName(newname)
	selected.changeIP(ip)

#opens edit server popup with current info
func editServer(sel):
	$"Edit server".popup_centered()
	$"Edit server".begin(sel.name, sel.ip)

#deleting servers
func _on_Delete_pressed():
	if selected != null:
		$"Delete server".popup_centered()
		$"Delete server".begin(selected.name)

func _on_Delete_server_serverDeleted():
	selected.queue_free()

#refreshing servers
func _on_Refresh_pressed():
	var children = $TabContainer/Favorites/MarginContainer2/VBoxContainer/ScrollContainer/VBoxContainer.get_children()
	for i in range(children.size()):
		children[i].refresh()

func _connect_servers():
	var children = $TabContainer/Favorites/MarginContainer2/VBoxContainer/ScrollContainer/VBoxContainer.get_children()
	for i in range(children.size()):
		children[i]._connect()

func _disconnect_servers():
	var children = $TabContainer/Favorites/MarginContainer2/VBoxContainer/ScrollContainer/VBoxContainer.get_children()
	for i in range(children.size()):
		children[i]._disconnect()

func _exit_tree():
	_disconnect_servers()
	save_servers()

#bottom UI buttons
func _on_Connect_pressed():
	if !selected:
		return
	#disconnect UI servers
	_disconnect_servers()
	
	#connect to server
	Server.set_server(selected.ip, selected.port)
	Server.start_client()

func _on_Cancel_pressed():
	_disconnect_servers()
	self.hide()





#saving/loading servers
var ServerFilePath = "./servers"

func load_servers():
	var servers : Dictionary = FileUtils.load_dictionary_from_config_file(ServerFilePath)
	
	for serverKey in servers.keys():
		add_server(servers[serverKey]["name"], serverKey)

func save_servers():
	var servers = {}
	
	#get all server nodes
	var children : Array = $TabContainer/Favorites/MarginContainer2/VBoxContainer/ScrollContainer/VBoxContainer.get_children()
	
	for i in range(children.size()):
		#translate server to dictionary for compact storage
		var serverDict = {
			"name": children[i].name,
			"ip": children[i].ip,
			"port": children[i].port,
		}
		
		#add server to dictionary
		servers[str(children[i].ip) + ":" + str(children[i].port)] = serverDict
	
	#save dictionary as config file
	FileUtils.save_dictionary_as_config_file(ServerFilePath, servers)
