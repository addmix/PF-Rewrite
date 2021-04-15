extends HBoxContainer

onready var label : Label = $Label

var setting : String
var type

<<<<<<< HEAD
=======
func _ready() -> void:
	call_deferred("set_value", ProjectSettings.get_setting(setting))

>>>>>>> parent of 56e0a8c (Menu improvements)
func set_name(n : String) -> void:
	self.name = n
	call_deferred("set_text", n)

func set_text(t : String) -> void:
	call_deferred("_set_text", t)

func _set_text(t : String) -> void:
	label.text = t

func get_setting() -> String:
	return setting

func set_value(v) -> void:
	type.set_value(v)

func get_value() -> Variant:
	return type.get_value()
