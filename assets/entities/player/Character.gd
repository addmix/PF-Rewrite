extends KinematicBody

class_name Character

#general data
var Player

#signals
signal died

#in game data
export var health := 100.0
var damage_stack := []

#nodes
onready var RotationHelper : Spatial = $Smoothing/RotationHelper
onready var Head : Spatial = $Smoothing/RotationHelper/Head
onready var WeaponController : Spatial = $Smoothing/RotationHelper/Head/WeaponController
onready var _Camera : Camera = $Smoothing/RotationHelper/Head/Camera

#control finess
signal camera_movement

export var camera_max_angle := 85
export var camera_min_angle := -85

export var camera_sensitiviy := Vector2(.2, .2)

#skeleton and IK stuff
onready var LeftHandIK : SkeletonIK = $"Smoothing/RotationHelper/Player/metarig/Skeleton/LeftHandIK"
onready var RightHandIK : SkeletonIK = $"Smoothing/RotationHelper/Player/metarig/Skeleton/RightHandIK"



func _ready() -> void:
	set_physics_process(false)
	set_process(false)
	call_deferred("deferred")

func deferred() -> void:
	if is_network_master():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		LeftHandIK.max_iterations = 20
		RightHandIK.max_iterations = 20
		_Camera.current = true
	
	set_physics_process(true)
	set_process(true)

func _exit_tree() -> void:
	if is_network_master():
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func damage(source, hp : float) -> void:
	#damage player
	health -= hp
	#add damage history
	damage_stack.append([source, hp, OS.get_ticks_msec()])
	#do screen effect
	
	if health <= 0:
		kill()

# warning-ignore:unused_argument
func shot(projectile : Spatial) -> void:
	#calculate damage here
	pass

func kill() -> void:
	emit_signal("died")

func reset() -> void:
	damage_stack.append([self, 100.0, OS.get_ticks_msec()])
	emit_signal("died")


#input


func _unhandled_input(event : InputEvent) -> void:
	if is_network_master():
		#mouse movement
		if event is InputEventMouseMotion:
			var relative = event.relative * camera_sensitiviy
			
			var current = Head.rotation_degrees
			
			RotationHelper.rotate_y(deg2rad(-relative.x))
			
			#branchless way of limiting up/down movement
			Head.rotation_degrees.x = ((Head.rotation_degrees.x - relative.y) * int(!Head.rotation_degrees.x - relative.y <= camera_min_angle and !Head.rotation_degrees.x - relative.y >= camera_max_angle)
			+ camera_min_angle * int(Head.rotation_degrees.x - relative.y <= camera_min_angle)
			+ camera_max_angle * int(Head.rotation_degrees.x - relative.y >= camera_max_angle))
			
			var delta : Vector3 = current - Head.rotation_degrees
			emit_signal("camera_movement", Vector3(delta.x, -relative.x, delta.z))
			rset_unreliable("head_rotation", Vector3(Head.rotation.x, RotationHelper.rotation.y, 0))
			
		if event.is_action_pressed("jump"):
			jump()
		if event.is_action_pressed("reset_character"):
			reset()

remote var puppet_axis := Vector3.ZERO
func get_axis() -> Vector3:
	var axis := Vector3.ZERO
	if is_network_master():
		axis += Vector3(0, 0, -1) * int(Input.is_action_pressed("walk_forward"))
		axis += Vector3(0, 0, 1) * int(Input.is_action_pressed("walk_backward"))
		axis += Vector3(-1, 0, 0) * int(Input.is_action_pressed("walk_left"))
		axis += Vector3(1, 0, 0) * int(Input.is_action_pressed("walk_right"))
		rset_unreliable("puppet_axis", axis)
	else:
		axis = puppet_axis
	return axis

#delta velocity
var delta_vel := Vector3.ZERO
var last_vel := Vector3.ZERO

func set_delta_vel(delta : float) -> void:
	#not normalized to time
	delta_vel = (movement_spring.position - last_vel) / delta
	call_deferred("set_last_vel")

func set_last_vel() -> void:
	last_vel = movement_spring.position

#position/time
var delta_pos := Vector3.ZERO

var last_pos := Vector3.ZERO
var current_pos := Vector3.ZERO

func set_delta_pos(delta : float) -> void:
	current_pos = get_global_transform().origin
	#not normalized to time
	delta_pos = (current_pos - last_pos) / delta
	#set this at last possible moment
	call_deferred("set_last_pos")

func set_last_pos() -> void:
	last_pos = current_pos

onready var gravity : Vector3 = ProjectSettings.get("physics/3d/default_gravity") * ProjectSettings.get("physics/3d/default_gravity_vector")
var movement_spring = V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .8, 14)


remote var puppet_pos := Vector3.ZERO
remote var head_rotation := Vector3.ZERO

func _physics_process(delta : float) -> void:
	
	if !is_network_master():
		Head.rotation.x = head_rotation.x
		transform.origin = puppet_pos
		RotationHelper.rotation.y = head_rotation.y
	
	#local space axis
	var axis := get_axis()
	
	if !is_network_master():
		axis = puppet_axis
	
	#world space axis
# warning-ignore:unused_variable
#	var xformed : Vector3 = RotationHelper.global_transform.basis.xform(axis)
	
	#gets pos basis for ground normal pos
	var basis : Basis = RotationHelper.get_global_transform().basis
	if is_on_floor():
		#change floor normal to be average of slides
		basis = get_ground_normal_translation(basis, get_floor_normal())
	
	#xform input vector by basis
	var translated := basis.xform(axis)
	
	if is_on_floor() and movement_spring.position.y > 0 and !Input.is_action_just_pressed("jump"):
		movement_spring.position.y *= 0
	
	movement_spring.speed = WeaponController.accuracy["Walk s"]
	movement_spring.damper = WeaponController.accuracy["Walk d"]
	movement_spring.target = translated * WeaponController.accuracy["Walkspeed"]
	movement_spring.positionvelocity(delta)
	
	#gravity
	movement_spring.position += gravity * delta
	
	movement_spring.position = move_and_slide(movement_spring.position, Vector3(0, 1, 0), false, 4, deg2rad(45), false)
	
	if is_network_master():
		rset_unreliable("puppet_pos", transform.origin)
	
	set_delta_pos(delta)
	set_delta_vel(delta)

func jump() -> void:
	if is_on_floor():
		movement_spring.position.y += 7.5

func get_ground_normal_translation(basis : Basis, normal : Vector3) -> Basis:
	var zy := intersect_planes(Vector3.ZERO, normal, Vector3.ZERO, basis.x, Vector3.ZERO)
	#intersection of ground normal and rotation helper's ZY plane
	var xy := intersect_planes(Vector3.ZERO, normal, Vector3.ZERO, basis.z, Vector3.ZERO)
	#intersection of ground normal and rotation helper's XY plane
	
	#projected basis to xform input
	var projected := Basis(xy[1], Vector3(0, 1, 0), -zy[1])
	return projected

#plane intersection fucntion
#http://tbirdal.blogspot.com/2016/10/a-better-approach-to-plane-intersection.html
func intersect_planes(p1 : Vector3, n1 : Vector3, p2 : Vector3, n2 : Vector3, p0 : Vector3) -> PoolVector3Array:
	
	var M := [
		[2, 0, 0, n1.x, n2.x],
		[0, 2, 0, n1.y, n2.y],
		[0, 0, 2, n1.z, n2.z],
		[n1.x, n1.y, n1.z, 0, 0],
		[n2.x, n2.y, n2.z, 0, 0]]
	
	var bx := p1 * n1
	var by := p2 * n2
	
	var b4 := bx.x + bx.y + bx.z
	var b5 := by.x + by.y + by.z
	
	var b = [
		[2*p0.x],
		[2*p0.y],
		[2*p0.z],
		[b4],
		[b5]]
	
# warning-ignore:unused_variable
	var x := multiply(inverse(M), b)
	
	var p = 1
	var n = n1.cross(n2)
	return PoolVector3Array([p, n])
	

#matrix multiplication funcs
#https://godotengine.org/qa/41768/matrix-matrix-vector-multiplication

func zero_matrix(nX : int, nY : int) -> Array:
	var matrix := []
	for x in range(nX):
		matrix.append([])
# warning-ignore:unused_variable
		for y in range(nY):
			matrix[x].append(0)
	return matrix

func multiply(a : Array, b : Array) -> Array:
	var matrix := zero_matrix(a.size(), b[0].size())
	
	for i in range(a.size()):
		for j in range(b[0].size()):
			for k in range(a[0].size()):
				matrix[i][j] = matrix[i][j] + a[i][k] * b[k][j]
	return matrix

#https://integratedmlai.com/matrixinverse/
func inverse(a : Array) -> Array:
	var n := a.size()
	var am := a.duplicate(true)
	var I = identity_matrix(n)
	var im = I.duplicate(true)
	
	for fd in range(n):
		var fdScaler : float = 1.0 / am[fd][fd]
		
		for j in range(n):
			am[fd][j] *= fdScaler
			im[fd][j] *= fdScaler
		
		for i in range(n):
			if i == fd:
				continue
			
			var crScaler : float = am[i][fd]
			for j in range(n):
				am[i][j] = am[i][j] - crScaler * am[fd][j]
				im[i][j] = im[i][j] - crScaler * im[fd][j]
	
	return im

#unused
func check_squareness(a : Array) -> void:
	if a.size() != a[0].size():
		push_error("Matrix not square")

func identity_matrix(n : int) -> Array:
	var matrix := []
	
	for y in range(n):
		var row := []
		for x in range(n):
			row.append(int(y == x))
		matrix.append(row)
	
	return matrix


func _on_WeaponController_weapon_changed(weapon : Spatial) -> void:
	LeftHandIK.target_node = weapon.LeftIK.get_path()
	RightHandIK.target_node = weapon.RightIK.get_path()
	LeftHandIK.start()
	RightHandIK.start()
