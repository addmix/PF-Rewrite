extends HSlider

func set_min(m : float) -> void:
	call_deferred("_set_min", m)

func _set_min(m : float) -> void:
	min_value = m

func set_max(m : float) -> void:
	call_deferred("_set_max", m)

func _set_max(m : float) -> void:
	max_value = m

func set_step(m : float) -> void:
	call_deferred("_set_step", m)

func _set_step(m : float) -> void:
	step = m

func set_value(v : float) -> void:
	value = v

func get_value() -> float:
	return value
