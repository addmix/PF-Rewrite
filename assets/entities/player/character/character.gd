extends KinematicBody
class_name Character

var player

signal spawned
signal died


#nodes


onready var camera : Camera = $Smoothing/Skeleton/HeadAttachment/Camera
func get_camera() -> Camera:
	return camera

onready var skeleton : Skeleton = $Smoothing/Skeleton
func get_skeleton() -> Skeleton:
	return skeleton




func _enter_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#local player, we want to set as player
	call_deferred("on_enter")

func on_enter() -> void:
	if is_network_master():
		camera.current = true

func _exit_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _ready() -> void:
	if is_network_master():
		skeleton.is_controlling = true

func _notification(what : int) -> void:
	match what:
		MainLoop.NOTIFICATION_WM_FOCUS_IN:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func spawn(position : Vector3 = Vector3.ZERO, direction : float = 0.0) -> void:
	global_transform = Transform(Basis(Vector3(0, direction, 0)), position)
	call_deferred("emit_signal", "spawned", position, direction)




#movement


func get_ground_normal_translation(basis : Basis, normal : Vector3) -> Basis:
	#intersection of ground normal and rotation helper's planes
	var zy := normal.cross(basis.x)
	var xy := normal.cross(basis.z)
	
	#projected basis to xform input
	var projected := Basis(xy, Vector3(0, 1, 0), -zy)
	return projected

var movement_axis := Vector3.ZERO
func get_movement_axis() -> Vector3:
	#reset axis to 0 when getting value
	if is_network_master():
		movement_axis = Vector3.ZERO
	
	movement_axis += Vector3(0, 0, -1) * Input.get_action_strength("walk_forward")
	movement_axis += Vector3(0, 0, 1) * Input.get_action_strength("walk_backward")
	movement_axis += Vector3(-1, 0, 0) * Input.get_action_strength("walk_left")
	movement_axis += Vector3(1, 0, 0) * Input.get_action_strength("walk_right")
	
	return movement_axis





