extends Node


#signals


#variables


#nodes


func load_settings() -> void:
	load_gameplay()
	load_graphics()
	load_audio()
	ProjectSettings.save()

func load_gameplay() -> void:
	#hitmarkers
	ProjectSettings.set_initial_value("gameplay/hitmarker/color", Color(1, 1, 1, 1))
	ProjectSettings.set_initial_value("gameplay/hitmarker/size", Vector2(20, 4))
	ProjectSettings.set_initial_value("gameplay/hitmarker/space", 10.0)

func load_graphics() -> void:
	ProjectSettings.set_initial_value("rendering/quality/filters/anisotropic_filter_level", 0)
	ProjectSettings.set_initial_value("rendering/quality/filters/msaa", 0)

func load_audio() -> void:
	#master volume
	ProjectSettings.set_initial_value("audio/volume/master_volume", 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), (1 - max(0, min(1, ProjectSettings.get_setting("audio/volume/master_volume")))) * -80)
	#ambient
	ProjectSettings.set_initial_value("audio/volume/ambient_volume", 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Ambient"), (1 - max(0, min(1.5, ProjectSettings.get_setting("audio/volume/ambient_volume")))) * -80)
	#sfx volume
	ProjectSettings.set_initial_value("audio/volume/sfx_volume", 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Gunshots"), (1 - max(0, min(1, ProjectSettings.get_setting("audio/volume/sfx_volume")))) * -80)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Explosions"), (1 - max(0, min(1, ProjectSettings.get_setting("audio/volume/sfx_volume")))) * -80)
	
	#music
	ProjectSettings.set_initial_value("audio/volume/music_volume", 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), (1 - max(0, min(1.5, ProjectSettings.get_setting("audio/volume/music_volume")))) * -80)
	
	#hitmarkers
	ProjectSettings.set_initial_value("audio/volume/hitmarker_volume", 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Hitmarkers"), (1 - max(0, min(1, ProjectSettings.get_setting("audio/volume/hitmarker_volume")))) * -80)
	
	#voice
	ProjectSettings.set_initial_value("audio/volume/voice_recieve_volume", 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("VoiceRecieve"), (1 - max(0, min(1.5, ProjectSettings.get_setting("audio/volume/voice_recieve_volume")))) * -80)
	ProjectSettings.set_initial_value("audio/volume/voice_emit_volume", 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("VoiceEmit"), (1 - max(0, min(1.5, ProjectSettings.get_setting("audio/volume/voice_emit_volume")))) * -80)
