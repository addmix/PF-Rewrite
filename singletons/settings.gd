extends Node


#signals


signal load_settings
signal load_gameplay
signal load_graphics
signal load_controls
signal load_audio

func load_settings() -> void:
	load_gameplay()
	load_graphics()
	load_controls()
	load_audio()
	emit_signal("load_settings")
#	var _err := ProjectSettings.save()

func load_gameplay() -> void:
	emit_signal("load_gameplay")
	#hitmarkers
	ProjectSettings.set_initial_value("gameplay/hitmarker/color", Color(1, 1, 1, 1))
	ProjectSettings.set_initial_value("gameplay/hitmarker/size", Vector2(20, 4))
	ProjectSettings.set_initial_value("gameplay/hitmarker/spacing", 10.0)

func load_graphics() -> void:
	emit_signal("load_graphics")
	ProjectSettings.set_initial_value("rendering/quality/filters/anisotropic_filter_level", 0)
	ProjectSettings.set_initial_value("rendering/quality/filters/msaa", 0)

func load_controls() -> void:
	emit_signal("load_controls")
	ProjectSettings.set_initial_value("controls/camera/invert_x", false)
	ProjectSettings.set_initial_value("controls/camera/invert_y", false)
	ProjectSettings.set_initial_value("controls/mouse/sensitivity", Vector2(1, 1))

func load_audio() -> void:
	emit_signal("load_audio")
	#master volume
	ProjectSettings.set_initial_value("audio/volume/master_volume", 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), (1.0 - clamp(ProjectSettings.get_setting("audio/volume/master_volume"), 0.0, 1.0)) * -80.0)
	#ambient
	ProjectSettings.set_initial_value("audio/volume/ambient_volume", 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Ambient"), (1.0 - clamp(ProjectSettings.get_setting("audio/volume/ambient_volume"), 0.0, 1.5)) * -80.0)
	#sfx volume
	ProjectSettings.set_initial_value("audio/volume/sfx_volume", 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Gunshots"), (1.0 - clamp(ProjectSettings.get_setting("audio/volume/sfx_volume"), 0.0, 1.0)) * -80.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Explosions"), (1.0 - clamp(ProjectSettings.get_setting("audio/volume/sfx_volume"), 0.0, 1.0)) * -80.0)
	
	#music
	ProjectSettings.set_initial_value("audio/volume/music_volume", 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), (1.0 - clamp(ProjectSettings.get_setting("audio/volume/music_volume"), 0.0, 1.5)) * -80.0)
	
	#hitmarkers
	ProjectSettings.set_initial_value("audio/volume/hitmarker_volume", 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Hitmarkers"), (1.0 - clamp(ProjectSettings.get_setting("audio/volume/hitmarker_volume"), 0.0, 1.5)) * -80.0)
	
	#voice
	ProjectSettings.set_initial_value("audio/volume/voice_recieve_volume", 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("VoiceRecieve"), (1.0 - clamp(ProjectSettings.get_setting("audio/volume/voice_recieve_volume"), 0.0, 1.5)) * -80.0)
	ProjectSettings.set_initial_value("audio/volume/voice_transmit_volume", 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("VoiceTransmit"), (1.0 - clamp(ProjectSettings.get_setting("audio/volume/voice_transmit_volume"), 0.0, 1.5)) * -80.0)

