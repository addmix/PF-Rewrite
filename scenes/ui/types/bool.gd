extends CheckBox

func set_value(v : bool) -> void:
	pressed = v

func get_value() -> bool:
	return pressed
