extends HBoxContainer

onready var x : SpinBox = $X/X
onready var y : SpinBox = $Y/Y
onready var z : SpinBox = $Z/Z

var _min : Vector3
var _max : Vector3

func set_min(v : Vector3) -> void:
	call_deferred("_set_min", v)

func _set_min(v : Vector3) -> void:
	x.min_value = v.x
	y.min_value = v.y
	z.min_value = v.y

func set_max(v : Vector3) -> void:
	call_deferred("_set_max", v)

func _set_max(v : Vector3) -> void:
	x.max_value = v.x
	y.max_value = v.y
	z.max_value = v.y

func set_step(v : float) -> void:
	call_deferred("_set_step", v)

func _set_step(v : float) -> void:
	x.step = v
	y.step = v
	z.step = v

func set_value(v : Vector3) -> void:
	x.value = v.x
	y.value = v.y
	z.value = v.z

func get_value() -> Vector3:
	return Vector3(x.value, y.value, z.value)
