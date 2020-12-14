extends Node

signal data_recieved
signal error_connecting

# The URL we will connect to
export var url = "ws://127.0.0.1:1909"

# Our WebSocketClient instance
var _client = WebSocketClient.new()

func _ready():
	_connect_singals()

func setURL(newURL):
	url = newURL

func _connect_singals():
	# Connect base signals to get notified of connection open, close, and errors.
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	_client.connect("data_received", self, "_on_data")

func _connect():
	# Initiate connection to the given URL.
	var err = _client.connect_to_url(url)
	if err != OK:
		print("Unable to connect: " + str(err))
		set_process(false)
		emit_signal("error_connecting", err)

func _disconnect():
	_client.disconnect_from_host()

var time
func QueryInfo():
	time = OS.get_ticks_msec()
	_client.get_peer(1).put_packet("QueryInfo".to_utf8())

func _on_data():
	var data : String = _client.get_peer(1).get_packet().get_string_from_utf8()
	
	var arr = data.split(",")
	
	match arr[0]:
		"QueryInfoResult":
			emit_signal("data_recieved", arr)

func _closed(_was_clean = false):
	set_process(false)

func _connected(_proto = ""):
	QueryInfo()

func _process(_delta):
	_client.poll()
