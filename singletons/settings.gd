extends Node


#signals


#variables


#nodes


func load_settings() -> void:
	load_audio()

func load_audio() -> void:
	#master volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), (1 - max(0, min(1, ProjectSettings.get_setting("audio/volume/master_volume")))) * -80)
	#sfx volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Gunshots"), (1 - max(0, min(1, ProjectSettings.get_setting("audio/volume/sfx_volume")))) * -80)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Explosions"), (1 - max(0, min(1, ProjectSettings.get_setting("audio/volume/sfx_volume")))) * -80)
	
	#hitmarkers
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Hitmarkers"), (1 - max(0, min(1, ProjectSettings.get_setting("audio/volume/hitmarker_volume")))) * -80)
