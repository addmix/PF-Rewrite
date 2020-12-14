extends CPUParticles

func _enter_tree():
	emitting = true


func _on_Timer_timeout():
	queue_free()
