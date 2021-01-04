extends Particles

func _ready() -> void:
	emitting = true
	start()

func start():
	yield(get_tree().create_timer(.5), "timeout")
	queue_free()
