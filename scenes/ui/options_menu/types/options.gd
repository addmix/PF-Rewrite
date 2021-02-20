extends OptionButton

var options := [] setget set_options

func set_options(o : Array) -> void:
	options = o
	
	for string in o.size():
		add_item(o[string], string)

func set_value(v : int) -> void:
	selected = v

func get_value() -> int:
	return selected
