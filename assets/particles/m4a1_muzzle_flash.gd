extends Particles

func _ready() -> void:
	emitting = true
	
	yield(get_tree().create_timer(.5), "timeout")
	queue_free()
