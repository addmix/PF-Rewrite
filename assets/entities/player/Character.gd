extends KinematicBody

class_name Character

#general data
var Player

#signals
signal died

#in game data
export var health := 100.0
var damage_stack := []

#state machines
onready var StanceMachine : Node = $StanceMachine
onready var MovementMachine : Node = $MovementMachine
onready var AimMachine : Node = $AimMachine
onready var AirMachine : Node = $AirMachine

#nodes
onready var RotationHelper : Spatial = $Smoothing/RotationHelper
onready var Head : Spatial = $Smoothing/RotationHelper/Head
onready var WeaponController : Spatial = $Smoothing/RotationHelper/Head/WeaponController
onready var Smoothing = $Smoothing/RotationHelper/Head/Smoothing
onready var _Camera : Camera = $Smoothing/RotationHelper/Head/Camera

#control finess
signal camera_movement

export var camera_max_angle := 85
export var camera_min_angle := -85

export var camera_sensitiviy := Vector2(.2, .2)

#skeleton and IK stuff
onready var LeftHandIK : SkeletonIK = $"Smoothing/RotationHelper/Player/metarig/Skeleton/LeftHandIK"
onready var RightHandIK : SkeletonIK = $"Smoothing/RotationHelper/Player/metarig/Skeleton/RightHandIK"
onready var LeftLegIK : SkeletonIK = $"Smoothing/RotationHelper/Player/metarig/Skeleton/LeftLegIK"
onready var RightLegIK : SkeletonIK = $"Smoothing/RotationHelper/Player/metarig/Skeleton/RightLegIK"

func _ready() -> void:
	set_physics_process(false)
	set_process(false)
	
	call_deferred("deferred")

func deferred() -> void:
	#branchless set camera stuff
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED * int(is_network_master()) + Input.MOUSE_MODE_VISIBLE * int(!is_network_master()))
	_Camera.current = is_network_master()
	
	ready_weapons()
	ready_ik()
	
	set_physics_process(true)
	set_process(true)

func ready_ik() -> void:
	#branchless set IK precision
	LeftHandIK.max_iterations = 20 * int(is_network_master()) + 4 * int(!is_network_master())
	RightHandIK.max_iterations = 20 * int(is_network_master()) + 4 * int(!is_network_master())
	LeftLegIK.max_iterations = 5 * int(is_network_master()) + 3 * int(!is_network_master())
	RightLegIK.max_iterations = 5 * int(is_network_master()) + 3 * int(!is_network_master())
	
	#set IK target
	LeftHandIK.set_target_node(current_weapon.LeftIK.get_path()) 
	RightHandIK.set_target_node(current_weapon.RightIK.get_path())
	
	LeftHandIK.start()
	RightHandIK.start()
	
	LeftLegIK.start()
	RightLegIK.start()




#weapon stuff
signal shot_fired

#primary, secondary, melee, grenade

signal weapon_changed
signal update_accuracy

#weapon nodes
var weapons := [null, null, null, null]
#index of current weapon
var weapon_index : int = 0
var current_weapon : Spatial

func ready_weapons() -> void:
	#loads weapons
	for weapon in range(Player.loadout.size()):
		if Player.loadout[weapon] == null:
			continue
		set_weapon(weapon, Player.loadout[weapon])
		weapons[weapon].add_to_group("weapons")
		weapons[weapon].add_to_group(Player.loadout[weapon])
		weapons[weapon].connect("shotFired", self, "on_shot_fired")
		weapons[weapon].connect("equipped", self, "on_weapon_equipped")
		weapons[weapon].connect("dequipped", self, "on_weapon_dequipped")
		weapons[weapon].set_network_master(Player.player_id)
	
	#set current weapon
	current_weapon = weapons[weapon_index]
	#add starter weapon to tree
	Smoothing.add_child(current_weapon)
	#start equip machine by equipping new gun
	current_weapon.EquipMachine.change_state("Equip")
	
	update_accuracy()
	
	call_deferred("emit_signal", "weapon_changed", current_weapon)

var accuracy = {}

#weapon modifier springs
var Equip := false
var Dequip := false
var Air := Spring.new(0, 0, 0, .5, 1)
remote var aim_spring_target := 0.0
var Aim := Spring.new(0, 0, 0, .5, 1)
remote var sprint_spring_target := 0.0
var Sprint := Spring.new(0, 0, 0, 0, 1)
var Movement := Vector3.ZERO
var Accel := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, 0, 1)
var Reload := Spring.new(0, 0, 0, 0, 1)
var Crouch := Spring.new(0, 0, 0, .99, 5)
var Prone := Spring.new(0, 0, 0, .99, 5)
var Mounted := Spring.new(0, 0, 0, 0, 1)

var camera_transform := Transform()

func process_springs(delta : float) -> void:
	#branchless set spring targets
	Aim.target = aim_spring_target * int(!is_network_master()) + Aim.target * int(is_network_master())
	Sprint.target = sprint_spring_target * int(!is_network_master()) + Sprint.target * int(is_network_master())
	
	#used in some springs
	camera_transform = _Camera.global_transform.basis
	
	#get accuracy
	update_accuracy()
	
	#modifier variables
	Equip = float(current_weapon.EquipMachine.current_state == "Equip")
	Dequip = float(current_weapon.EquipMachine.current_state == "Dequip")
	Movement = velocity
	
	#in air
	Air.target = float(!is_on_floor())
	Air.damper = accuracy["Air d"]
	Air.speed = accuracy["Air s"]
	Air.positionvelocity(delta)
	
	#reload
	Reload.target = float(current_weapon.ReloadMachine.currentState != "Ready" and !current_weapon.ReloadMachine.states[current_weapon.ReloadMachine.currentState].stopped)
	Reload.damper = accuracy["Reload d"]
	Reload.speed = accuracy["Reload s"]
	Reload.positionvelocity(delta)
	
	#aiming
	Aim.damper = current_weapon.data["Weapon handling"]["Aim d"]
	Aim.speed = current_weapon.data["Weapon handling"]["Aim s"]
	Aim.positionvelocity(delta)
	
	#sprinting
	Sprint.damper = accuracy["Sprint d"]
	Sprint.speed = accuracy["Sprint s"]
	Sprint.positionvelocity(delta)
	
	#acceleration
	Accel.damper = accuracy["Accel sway d"]
	Accel.speed = accuracy["Accel sway s"]
	Accel.accelerate(camera_transform.xform_inv(delta_vel))
	Accel.positionvelocity(delta)
	
	var capsule_height := 3.1
	var capsule_y := 2.35
	
	var body_y := -4.45
	var body_z := 0.0
	var body_angle := 0.0
	
	var head_y := -.425
	var head_z := 0.0
	
	Crouch.positionvelocity(delta)
	capsule_height = lerp(capsule_height, 1.5, Crouch.position)
	capsule_y = lerp(capsule_y, 1.55, Crouch.position)
	
	body_y = lerp(body_y, -6.1, Crouch.position)
	body_z = lerp(body_z, 0, Crouch.position)
	body_angle = lerp(body_angle, 0, Crouch.position)
	
	head_y = lerp(head_y, -2.05, Crouch.position)
	head_z = lerp(head_z, 0, Crouch.position)
	
	Prone.positionvelocity(delta)
	capsule_height = lerp(capsule_height, 0, Prone.position)
	capsule_y = lerp(capsule_y, .8, Prone.position)
	
	body_y = lerp(body_y, -4.1, Prone.position)
	body_z = lerp(body_z, 2.3, Prone.position)
	body_angle = lerp(body_angle, 90, Prone.position)
	
	head_y = lerp(head_y, -4, Prone.position)
	head_z = lerp(head_z, -4.025, Prone.position)
	
	$CollisionShape.shape.height = capsule_height
	$CollisionShape.transform.origin.y = capsule_y
	
	$Smoothing/RotationHelper/Player.transform.origin.y = body_y
	$Smoothing/RotationHelper/Player.transform.origin.z = body_z
	$Smoothing/RotationHelper/Player.rotation_degrees.x = body_angle
	
	Head.transform.origin.y = head_y
	Head.transform.origin.z = head_z

func set_weapon(index : int, weapon : String) -> void:
	#load weapon
	weapons[index] = Weapons.models[weapon].instance()

#used for non-immediate weapon swapping
var new_weapon := 0
func switch_weapon(index : int) -> void:
	if weapons[index] == null:
		return
	#do dequip animation
	weapons[weapon_index].dequip()
	new_weapon = index

#pickup weapon to empty slot
# warning-ignore:unused_argument
func pickup_weapon(selected : Spatial) -> void:
	pass

#swap with weapon on ground
# warning-ignore:unused_argument
func change_weapon(selected : Spatial) -> void:
	pass

# warning-ignore:unused_argument
func on_weapon_equipped(weapon : Spatial) -> void:
	pass

func on_weapon_dequipped(weapon : Spatial) -> void:
	#set current weapon index
	weapon_index = new_weapon
	#remove old weapon
	Smoothing.remove_child(weapon)
	#add new weapon
	Smoothing.add_child(weapons[weapon_index])
	#start equip sequence for new weapon
	weapons[weapon_index].equip()
	#set current weapon
	current_weapon = weapons[weapon_index]
	#emit new weapon
	emit_signal("weapon_changed", weapons[weapon_index])

func on_shot_fired() -> void:
	emit_signal("shot_fired", Aim.position, MathUtils.v3RandfRange(Vector3.ZERO, Vector3(1, 1, 1)))

func update_accuracy() -> void:
	accuracy = get_accuracy()
	emit_signal("update_accuracy", accuracy)

#used to calculate accuracy
func get_accuracy() -> Dictionary:
	#make copy of data
	var data : Dictionary = current_weapon.data["Weapon handling"]
	
	var copy := {}
	#clone dictionary
	for i in data.keys():
		copy[i] = data[i]
	
	#additive
	for modifier in current_weapon.add.keys():
		var value := get_modifier_value(modifier)
		
		#each property
		for key in current_weapon.add[modifier].keys():
			#hacky way to normalize values and add
			copy[key] += current_weapon.add[modifier][key] * value
	
	#multiplicative
	for modifier in current_weapon.multi.keys():
		var value := get_modifier_value(modifier)
		
		#each property
		for key in current_weapon.multi[modifier].keys():
			var default
			
			match typeof(current_weapon.multi[modifier][key]):
				TYPE_REAL:
					default = 1.0
				TYPE_VECTOR3:
					default = Vector3(1, 1, 1)
				_:
					push_error("Modifier variable cannot be of type " + Variant.get_type(typeof(current_weapon.multi[modifier][key])))
			
			copy[key] *= lerp(default, current_weapon.multi[modifier][key], value)
	
	return copy

#gets value to interpolate modifier by
func get_modifier_value(modifier : String) -> float:
	#get modifier's property
	var prop = get(modifier)
	
	var value : float
	#gets float from different datatypes
	match typeof(prop):
		TYPE_REAL:
			value = prop
		TYPE_BOOL:
			value = float(prop)
		TYPE_INT:
			value = float(prop)
		TYPE_VECTOR2:
			value = prop.length()
		TYPE_VECTOR3:
			value = prop.length()
		TYPE_OBJECT:
			#for custom classes
			match prop.get_class():
				"Spring":
					value = prop.position
				"V3Spring":
					value = prop.position.length()
				_:
					push_error("Modifier " + modifier + " links to illegal variable  of the same name, with class " + prop.get_class())
		_:
			push_error("Modifier " + modifier + " links to illegal variable  of the same name, with type " + Variant.get_type(prop))
	
	return value
#end of weapon stuff

#walk bob stuff
#allows for time-based spring stuff
var walk_bob_tick := 0.0

func process_walk(delta : float) -> void:
	walk_bob_tick += delta * (accuracy["Gun bob s"] + 1)



#when character is removed from the tree
func _exit_tree() -> void:
	#branchless change mouse mode
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE * int(is_network_master()) + Input.get_mouse_mode() * int(!is_network_master()))
	
	#cleanup weapons
	for weapon in weapons:
		if weapon != null:
			weapon.free()

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
	delta_pos = (current_pos - last_pos)
	#set this at last possible moment
	call_deferred("set_last_pos")

func set_last_pos() -> void:
	last_pos = current_pos

onready var gravity : Vector3 = ProjectSettings.get("physics/3d/default_gravity") * ProjectSettings.get("physics/3d/default_gravity_vector")
var movement_spring = V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .99, 14)


remote var puppet_pos := Vector3.ZERO
remote var head_rotation := Vector3.ZERO


var vel := Vector3.ZERO
func _physics_process(delta : float) -> void:
	#update walk bob
	process_walk(delta)
	#calculate spring movement
	process_springs(delta)
	
	WeaponController.process_recoil(delta)
	#do movement step
	process_movement(delta)
	
	#branchlessly apply puppet transform
	Head.rotation.x = head_rotation.x * int(!is_network_master()) + Head.rotation.x * int(is_network_master())
	transform.origin = puppet_pos  * int(!is_network_master()) + transform.origin * int(is_network_master())
	RotationHelper.rotation.y = head_rotation.y * int(!is_network_master()) + RotationHelper.rotation.y * int(is_network_master())

#persistent character velocity
var velocity := Vector3.ZERO
func process_movement(delta : float) -> void:
	#local space axis
	var axis := get_axis()
	
	if !is_network_master():
		axis = puppet_axis
	
	#gets pos basis for ground normal pos
	var basis : Basis = RotationHelper.get_global_transform().basis
	if is_on_floor():
		#change floor normal to be average of slides
		basis = get_ground_normal_translation(basis, get_floor_normal())
	
	#xform input vector by basis
	var translated := (basis.xform(axis.normalized()) - Vector3(0, 0.1, 0)).normalized()
	
	movement_spring.target = translated * accuracy["Walkspeed"]
	movement_spring.positionvelocity(delta)
	
	if is_on_floor():
		velocity = move_and_slide(movement_spring.position, Vector3(0, 1, 0), true, 8, deg2rad(45), false)
	else:
		velocity = move_and_slide(movement_spring.position * 0.005 + velocity, Vector3(0, 1, 0), true, 8, deg2rad(45), false)
	
	velocity += (gravity * delta) * float(!is_on_floor())
	velocity *= 1 - velocity.length() / 25000
	
	#keeps on ground so that it works
	move_and_slide(Vector3(0, -.1, 0), Vector3(0, 1, 0), true, 1)
	
	if is_network_master():
		rset_unreliable("puppet_pos", transform.origin)
	
	set_delta_pos(delta)
	set_delta_vel(delta)

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
