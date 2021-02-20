extends Node


#signals


#variables


#nodes


func load_settings() -> void:
	load_audio()

func load_audio() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), 0)
