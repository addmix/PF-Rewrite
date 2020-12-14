extends Spatial

var player = preload("res://Assets/Weapons/Carbines/M4A1/Gunshots/SoundPlayer.tscn")

func _ready():
# warning-ignore:return_value_discarded
	get_parent().connect("fire", self, "shoot")

func shoot() -> void:
	var instance = player.instance()
	add_child(instance)
	
	instance.play()
