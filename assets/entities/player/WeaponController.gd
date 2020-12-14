extends Spatial

onready var base_offset := transform.origin
onready var aim_node : Position3D = find_node("Aim")

var mouse_delta := Vector2.ZERO

onready var aim_spring = Physics.Spring.new(0, 0, 0, .95, 14)
onready var sway_spring = Physics.V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .75, 15)

func _process(delta : float) -> void:
	var pos := Vector3.ZERO
	var rot := Vector3.ZERO
	
	#aiming
	aim_spring.positionvelocity(delta)
	pos -= aim_spring.position * (base_offset + aim_node.transform.origin)
	
	#sway
	sway_spring.accelerate(Vector3(mouse_delta.y, mouse_delta.x, 0))
	sway_spring.positionvelocity(delta)
	
	rot += sway_spring.position
	
	transform.origin = base_offset + pos
	rotation_degrees = rot

func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("aim"):
		aim_spring.target = 1
		get_tree().set_input_as_handled()
	elif event.is_action_released("aim"):
		aim_spring.target = 0
		get_tree().set_input_as_handled()


func _on_Player_camera_movement(relative : Vector2) -> void:
	mouse_delta = relative
