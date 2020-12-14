extends Spatial

onready var aim_spring = Physics.Spring.new(0, 0, 0, .95, 14)

func _process(delta : float) -> void:
	aim_spring.positionvelocity(delta)
	

func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("aim"):
		aim_spring.target = 1
		get_tree().set_input_as_handled()
	elif event.is_action_released("aim"):
		aim_spring.target = 0
		get_tree().set_input_as_handled()
