extends Spatial

var particles = preload("res://Assets/Weapons/Carbines/M4A1/Particles/Particles.tscn")

func _ready():
# warning-ignore:return_value_discarded
	get_parent().connect("fire", self, "shoot")

func shoot():
	var instance = particles.instance()
	add_child(instance)
