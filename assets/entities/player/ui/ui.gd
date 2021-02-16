extends Control

func _ready() -> void:
	if is_network_master():
		show()
