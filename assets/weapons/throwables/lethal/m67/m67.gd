extends RigidBody

onready var timer : Timer = $Timer
var fragment_count : int = 26

func start() -> void:
	timer.start()

func _on_Timer_timeout():
	explode()

func explode() -> void:
	for i in fragment_count:
		create_shrapnel(random_vector())
	
	queue_free()

# warning-ignore:unused_argument
func create_shrapnel(dir : Vector3) -> void:
	pass

func random_vector() -> Vector3:
	return Vector3(randf(), randf(), randf()).normalized()
