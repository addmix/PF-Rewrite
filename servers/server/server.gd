extends Node

var network := NetworkedMultiplayerENet.new()

func _ready() -> void:
	connect_signals()

func connect_signals() -> void:
	network.connect("peer_connected", self, "on_peer_connected")
	network.connect("peer_disconnected", self, "on_peer_disconnected")

#for running dedicated server
func load_multiplayer_server() -> void:
	#load default server settings
	load_properties_file()
	#read/apply cmdline arguments
	extract_properties_from_cmdline_args()
	#load map/gamemode
	
	#load server
	start_server()

#for running singleplayer/lan server
func load_singleplayer_server() -> void:
	#load map/gamemode
	
	#load server
	start_server()

func start_server() -> void:
	network.create_server(properties["port"], properties["max_players"], properties["in_bandwidth"], properties["out_bandwidth"])
	get_tree().set_network_peer(network)

func on_peer_connected(id : int) -> void:
	print("Peer successfully connected")

func on_peer_disconnected(id : int) -> void:
	print("Peer disconnected")




#loading map/gamemode




#load map/gamemode
func load_match():
	pass

#unload map/gamemode (for after one match ends, then you can load another match
func unload_match():
	pass




#server.properties




const DEFAULT_PROPERTIES := {
	"map": "Desert Storm",
	"gamemode": "TDM",
	"port": 1909,
	"max_players": 32,
	"in_bandwidth": 0,
	"out_bandwidth": 0,
	"whitelist": false,
	"lan": false,
}

var properties := {
	"map": "Desert Storm",
	"gamemode": "TDM",
	"port": 1909,
	"max_players": 32,
	"in_bandwidth": 0,
	"out_bandwidth": 0,
	"whitelist": false,
	"lan": false,
}

#changes properties by arguements passed from cmdline
func extract_properties_from_cmdline_args() -> void:
	var args := Array(OS.get_cmdline_args())
	
	#load server.properties default args
	
	for key in DEFAULT_PROPERTIES.keys():
		#arguement passed
		var find : int = args.find(key)
		if find != -1:
			
			#enabler tag
			if DEFAULT_PROPERTIES[key] is bool:
				#set to inverse of default
				properties[key] = !DEFAULT_PROPERTIES[key]
			
			#declaration arguement
			else:
				#assign property to the value arguement for the declaration
				properties[key] = args[find + 1]

#load default arguments file and apply them to properties dictionary
func load_properties_file() -> void:
	var args := ConfigFile.new()
	var err := args.load(OS.get_executable_path().get_base_dir() + "/server.properties")
	
	#no error
	if err == OK:
		#load default args
		for key in DEFAULT_PROPERTIES.keys():
			#load value
			var value = args.get_value("properties", key, null)
			#section/key pair not found
			if value == null:
				#set value in properties file
				update_properties_file()
			else:
				properties[key] = value
	
	#if error
	else:
		#no file found
		if err == ERR_FILE_NOT_FOUND:
			create_properties_file()
			load_properties_file()
		#more errs

func update_properties_file() -> void:
	var config := ConfigFile.new()
	var err := config.load(OS.get_executable_path().get_base_dir() + "/server.properties")
	
	if err != OK:
		push_error("Error loading server.properties file at " + OS.get_executable_path().get_base_dir() + "/server.properties" + " Error " + str(err))
		return
	
	for key in DEFAULT_PROPERTIES.keys():
		var value = config.get_value("properties", key, null)
		if value == null:
			#section/key pair not found
			#make new entry
			config.set_value("properties", key, DEFAULT_PROPERTIES[key])
	
	err = config.save(OS.get_executable_path().get_base_dir() + "/server.properties")
	if err != OK:
		push_error("Error saving server.properties file at " + OS.get_executable_path().get_base_dir() + "/server.properties" + " Error " + str(err))
		return

#creates file from the default properties table
func create_properties_file() -> void:
	var config := ConfigFile.new()
	
	#loop through values
	for key in DEFAULT_PROPERTIES.keys():
		#set value
		config.set_value("properties", key, DEFAULT_PROPERTIES[key])
	
	var err := config.save(OS.get_executable_path().get_base_dir() + "/server.properties")
	if err:
		push_error("Could not save server.properties at " + OS.get_executable_path().get_base_dir() + "/server.properties" + " Error " + str(err))
