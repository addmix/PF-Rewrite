extends KinematicBody
class_name Character

var player

signal spawned
signal died

#settings

var invert_x : bool = ProjectSettings.get_setting("controls/camera/invert_x")
var invert_y : bool = ProjectSettings.get_setting("controls/camera/invert_y")
var camera_sensitivity : Vector2 = ProjectSettings.get_setting("controls/mouse/sensitivity")

func settings_changed() -> void:
	if !is_network_master():
		return
	
	invert_x = ProjectSettings.get_setting("controls/invert_x")
	invert_y = ProjectSettings.get_setting("controls/invert_y")
	
	camera_sensitivity = ProjectSettings.get_setting("controls/mouse/sensitivity") * Vector2(-1.0 * float(invert_x) + 1.0 * float(!invert_x), -1.0 * float(invert_y) + 1.0 * float(!invert_y))


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
	emit_signal("spawned")
	if is_network_master():
		camera.current = true

func _exit_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _unhandled_input(event : InputEvent) -> void:
	if !is_network_master():
		return
	
	if event is InputEventMouseMotion:
		#apply settings here
		
		skeleton.move_head(event.relative * camera_sensitivity)


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





func _notification(what : int) -> void:
	match what:
		MainLoop.NOTIFICATION_WM_FOCUS_IN:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
