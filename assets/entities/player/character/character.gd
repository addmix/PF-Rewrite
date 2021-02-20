extends KinematicBody
class_name Character


#signals


#general signals
signal loaded

#camera
signal camera_movement

#health/damage
signal spawned
signal died
signal health_changed

#weapons
signal shot_fired
signal update_ammo
signal weapon_changed

#accuracy
signal update_accuracy


#variables


#general data
var process_delta := 0.0
remote var puppet_position := Vector3.ZERO

#anims
var walk_bob_tick := 0.0
var breath_sway_tick := 0.0

#controls
var axis := Vector3.ZERO
var mouse_movement := Vector2.ZERO
remote var puppet_axis := Vector3.ZERO
remote var puppet_mouse_movement := Vector2.ZERO
export var camera_max_angle := 85
export var camera_min_angle := -85
onready var camera_sensitiviy : Vector2 = ProjectSettings.get_setting("controls/mouse/sensitivity")

#camera
var camera_transform := Basis()
remote var puppet_head_rotation := Vector2.ZERO

#movement
onready var gravity : Vector3 = ProjectSettings.get("physics/3d/default_gravity") * ProjectSettings.get("physics/3d/default_gravity_vector")
const discrepancy_allowance_position := .05
const discrepancy_allowance_rotation := .05
var drag_coefficient := 0.7
var air_density := 0.00002
var velocity := Vector3.ZERO
var delta_vel := Vector3.ZERO
var last_vel := Vector3.ZERO
var delta_pos := Vector3.ZERO
var last_pos := Vector3.ZERO
var current_pos := Vector3.ZERO

#health/damage
export var health := 100.0
var damage_stack := []

#weapons
var new_weapon := 0
var weapon_index : int = 0
var current_weapon : Spatial
var Equip := false
var Dequip := false

#accuracy
var accuracy = {}
var movement_spring = V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .99, 14)
var Air := Spring.new(0, 0, 0, .5, 1)
var Aim := Spring.new(0, 0, 0, .5, 1)
var Breath := Spring.new(0, 0, 0, .5, 1)
var Sprint := Spring.new(0, 0, 0, 0, 1)
var Movement := Vector3.ZERO
var Accel := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, 0, 1)
var Reload := Spring.new(0, 0, 0, 0, 1)
var Crouch := Spring.new(0, 0, 0, .99, 5)
var Prone := Spring.new(0, 0, 0, .99, 5)
var Mounted := Spring.new(0, 0, 0, 0, 1)


#nodes


#general nodes
var Player
onready var Smoothing = $Smoothing/RotationHelper/Head/Smoothing
onready var RotationHelper : Spatial = $Smoothing/RotationHelper
onready var Head : Spatial = $Smoothing/RotationHelper/Head
onready var _Camera : Camera = $Smoothing/RotationHelper/Head/Camera
onready var WeaponController : Spatial = $Smoothing/RotationHelper/Head/WeaponController
onready var FootController = $Smoothing/RotationHelper/FootController

#state machine nodes
onready var StanceMachine : Node = $StanceMachine
onready var MovementMachine : Node = $MovementMachine
onready var AimMachine : Node = $AimMachine
onready var AirMachine : Node = $AirMachine

#ik nodes
onready var _Skeleton = $Smoothing/RotationHelper/Skeleton
var IKs := []
var LeftHandIK : SkeletonIK
var RightHandIK : SkeletonIK
var LeftLegIK : SkeletonIK
var RightLegIK : SkeletonIK

#weapon nodes
var weapons := [null, null]





#funcs





#general


func _ready() -> void:
	emit_signal("spawned")
	_Camera.current = is_network_master()
	
	set_physics_process(false)
	set_process(false)
	
	call_deferred("deferred")

func deferred() -> void:
	#branchless set camera stuff
	if is_network_master():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	_Camera.current = is_network_master()
	
	ready_weapons()
	ready_ik()
	
	emit_signal("loaded", self)
	
	set_physics_process(true)
	set_process(true)

func _physics_process(delta : float) -> void:
	if get_tree().is_network_server():
		server_process(delta)
	else:
		client_process(delta)
	
	#update walk bob
	process_walk(delta)
	#update breath sway
	process_breath(delta)
	#calculate spring movement
	process_springs(delta)
	
	WeaponController.process_recoil(delta)
	#do movement step
	process_movement(delta)

func _process(delta : float) -> void:
	process_delta = delta
	if !is_network_master():
		rotate_head(mouse_movement * delta)

func _exit_tree() -> void:
	#branchless change mouse mode
	if is_network_master():
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	#cleanup weapons
	for weapon in weapons:
		if weapon != null:
			weapon.free()
	


func _notification(what : int) -> void:
	match what:
		MainLoop.NOTIFICATION_WM_FOCUS_IN:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#ik funcs


func ready_ik() -> void:
	IKs = _Skeleton.setup_ik()
	
	LeftHandIK = IKs[0]
	RightHandIK = IKs[1]
	LeftLegIK = IKs[2]
	RightLegIK = IKs[3]
	
	LeftHandIK.use_magnet = true
	LeftHandIK.magnet = Vector3(2, 2, 0.4)
	
	RightHandIK.use_magnet = true
	RightHandIK.magnet = Vector3(-2, 1, 0.2)
	
	LeftLegIK.use_magnet = true
	LeftLegIK.magnet = Vector3(.5, .5, 3)
	
	RightLegIK.use_magnet = true
	RightLegIK.magnet = Vector3(-.5, .5, 3)
	
	LeftLegIK.target_node = FootController.left.get_path()
	RightLegIK.target_node = FootController.right.get_path()
	
	#branchless set IK precision
	LeftHandIK.max_iterations = 20 * int(is_network_master()) + 4 * int(!is_network_master())
	RightHandIK.max_iterations = 20 * int(is_network_master()) + 4 * int(!is_network_master())
	LeftLegIK.max_iterations = 3 * int(is_network_master()) + 3 * int(!is_network_master())
	RightLegIK.max_iterations = 3 * int(is_network_master()) + 3 * int(!is_network_master())
	
	update_ik()
	
	LeftLegIK.start()
	RightLegIK.start()

func start_ik() -> void:
	LeftHandIK.start()
	RightHandIK.start()
	LeftLegIK.start()
	RightLegIK.start()

func stop_ik() -> void:
	LeftHandIK.stop()
	RightHandIK.stop()
	LeftLegIK.stop()
	RightLegIK.stop()

func update_ik() -> void:
	#set IK target
	LeftHandIK.set_target_node(current_weapon.LeftIK.get_path()) 
	RightHandIK.set_target_node(current_weapon.RightIK.get_path())
	
	start_ik()


#anim funcs


func process_springs(delta : float) -> void:
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
	Reload.target = float(current_weapon.ReloadMachine.current_state != "Ready" and !current_weapon.ReloadMachine.states[current_weapon.ReloadMachine.current_state].stopped)
	Reload.damper = accuracy["Reload d"]
	Reload.speed = accuracy["Reload s"]
	Reload.positionvelocity(delta)
	
	#aiming
	Aim.damper = current_weapon.data["Weapon handling"]["Aim d"]
	Aim.speed = current_weapon.data["Weapon handling"]["Aim s"]
	Aim.positionvelocity(delta)
	
	#holding breath
	Breath.damper = current_weapon.data["Weapon handling"]["Breath d"]
	Breath.speed = current_weapon.data["Weapon handling"]["Breath s"]
	Breath.positionvelocity(delta)
	
	#sprinting
	Sprint.damper = accuracy["Sprint d"]
	Sprint.speed = accuracy["Sprint s"]
	Sprint.positionvelocity(delta)
	
	#acceleration
	Accel.damper = accuracy["Accel sway d"]
	Accel.speed = accuracy["Accel sway s"]
	Accel.accelerate(camera_transform.xform_inv(delta_vel))
	Accel.positionvelocity(delta)
	
	process_body(delta)

func process_body(delta : float) -> void:
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
	body_z = lerp(body_z, 4.5, Prone.position)
	body_angle = lerp(body_angle, 90, Prone.position)
	
	head_y = lerp(head_y, -4, Prone.position)
	head_z = lerp(head_z, 0, Prone.position)
	
	$CollisionShape.shape.height = capsule_height
	$CollisionShape.transform.origin.y = capsule_y
	
	_Skeleton.transform.origin.y = body_y
	_Skeleton.transform.origin.z = body_z
	_Skeleton.rotation_degrees.x = body_angle
	
	Head.transform.origin.y = head_y
	Head.transform.origin.z = head_z

func process_walk(delta : float) -> void:
	walk_bob_tick += delta * (accuracy["Gun bob s"] + 1)

func process_breath(delta : float) -> void:
	breath_sway_tick += delta * (accuracy["Breath sway s"])


#weapon funcs


func ready_weapons() -> void:
	#loads weapons
	for weapon in range(Player.loadout.size()):
		if Player.loadout[weapon] == null:
			continue
		set_weapon(weapon, Player.loadout[weapon])
		weapons[weapon].WeaponController = WeaponController
		weapons[weapon].add_to_group("weapons")
		weapons[weapon].add_to_group(Player.loadout[weapon])
		weapons[weapon].connect("shot_fired", self, "on_shot_fired")
		weapons[weapon].connect("update_ammo", self, "update_ammo")
		weapons[weapon].connect("equipped", self, "on_weapon_equipped")
		weapons[weapon].connect("dequipped", self, "on_weapon_dequipped")
		
# warning-ignore:return_value_discarded
		connect("loaded", weapons[weapon], "on_character_loaded")
		weapons[weapon].set_network_master(Player.player_id)
	
	#set current weapon
	current_weapon = weapons[weapon_index]
	#add starter weapon to tree
	Smoothing.add_child(current_weapon)
	#update ammo counter
	current_weapon.update_ammo()
	#start equip machine by equipping new gun
	current_weapon.EquipMachine.change_state("Equip")
	
	update_accuracy()
	
	call_deferred("emit_signal", "weapon_changed", current_weapon)

# warning-ignore:unused_argument
func on_weapon_equipped(weapon : Spatial) -> void:
	pass

func on_weapon_dequipped(weapon : Spatial) -> void:
	#set current weapon index
	weapon_index = new_weapon
	stop_ik()
	#remove old weapon
	Smoothing.remove_child(weapon)
	#add new weapon
	Smoothing.add_child(weapons[weapon_index])
	
	call_deferred("update_ik")
	#start equip sequence for new weapon
	weapons[weapon_index].call_deferred("equip")
	#set current weapon
	current_weapon = weapons[weapon_index]
	
	current_weapon.update_ammo()
	#emit new weapon
	emit_signal("weapon_changed", weapons[weapon_index])

func switch_weapon(index : int) -> void:
	if index == weapon_index:
		return
	if  get_tree().is_network_server():
		rpc("puppet_switch_weapon", index)
	else:
		rpc_id(1, "puppet_switch_weapon", index)
	if weapons[index % weapons.size()] == null:
		return
	#do dequip animation
	weapons[weapon_index].dequip()
	new_weapon = index % weapons.size()

puppet func puppet_switch_weapon(index : int) -> void:
	if  get_tree().is_network_server():
		rpc("puppet_switch_weapon", index)
	if weapons[index % weapons.size()] == null:
		return
	#do dequip animation
	weapons[weapon_index].dequip()
	new_weapon = index % weapons.size()

func set_weapon(index : int, weapon : String) -> void:
	#load weapon
	weapons[index] = Weapons.models[weapon].instance()

func pickup_weapon(_selected : Spatial) -> void:
	pass

func swap_weapon(_selected : Spatial) -> void:
	pass

func on_shot_fired() -> void:
	var direction : Vector3 = MathUtils.v3RandfRange(Vector3.ZERO, Vector3(1, 1, 1))
	if get_tree().is_network_server() and is_network_master():
		rpc("puppet_shot_fired", direction)
		emit_signal("shot_fired", direction)
	elif is_network_master():
		rpc_id(1, "puppet_shot_fired", direction)
		emit_signal("shot_fired", direction)

remote func puppet_shot_fired(direction : Vector3) -> void:
	if is_network_master():
		return
	else:
		emit_signal("shot_fired", direction)

func update_ammo(c : int, m : int, r : int) -> void:
	emit_signal("update_ammo", c, m, r)


#movement


func get_max_movement_speed() -> float:
	return accuracy["Walkspeed"]

func process_movement(delta : float) -> void:
	#local space axis
	
	if is_network_master():
		axis = get_axis()
	else:
		axis = puppet_axis
	
	#gets pos basis for ground normal pos
	var basis : Basis = RotationHelper.get_global_transform().basis
	if is_on_floor():
		#change floor normal to be average of slides
		basis = get_ground_normal_translation(basis, get_floor_normal())
	
	#xform input vector by basis
	var translated := basis.xform(axis.normalized())
	
	movement_spring.target = translated * accuracy["Walkspeed"]
	movement_spring.positionvelocity(delta)
	
	if is_on_floor() and AirMachine.current_state != "Up":
		velocity = move_and_slide(movement_spring.position - Vector3(0, 0.1, 0), Vector3(0, 1, 0), true, 8, deg2rad(45), false)
	else:
		velocity = move_and_slide(movement_spring.position * 0.005 + velocity, Vector3(0, 1, 0), true, 8, deg2rad(45), false)
	
	velocity += (gravity * delta) * float(!is_on_floor())
	velocity -= velocity.normalized() * 0.5 * air_density * (velocity * velocity) * drag_coefficient * 1.5
	
	#keeps on ground so that it works
# warning-ignore:return_value_discarded
	move_and_slide(Vector3(0, -.1, 0), Vector3(0, 1, 0), true, 1)
	
	set_delta_pos(delta)
	set_delta_vel(delta)

func _on_AirMachine_jump() -> void:
	velocity.y += 10

func get_ground_normal_translation(basis : Basis, normal : Vector3) -> Basis:
	#intersection of ground normal and rotation helper's planes
	var zy := normal.cross(basis.x)
	var xy := normal.cross(basis.z)
	
	#projected basis to xform input
	var projected := Basis(xy, Vector3(0, 1, 0), -zy)
	return projected


#damage funcs


func damage(source, hp : float) -> void:
	emit_signal("health_changed", hp)
	
	#damage player
	health -= hp
	#add damage history
	damage_stack.append([source, hp, OS.get_ticks_msec()])
	#do screen effect
	
	if get_tree().is_network_server():
		rset("health", health)
	
	if health <= 0:
		kill()

func calculate_damage(projectile : Projectile, part : BodyPart) -> float:
	var damage : float = projectile.weapon.data["Ballistics"]["Damage"] * projectile.weapon.data["Ballistics"][part.name]
	return damage

func kill() -> void:
	if get_tree().is_network_server():
		rpc("puppet_kill")
	emit_signal("died")

remote func puppet_kill() -> void:
	emit_signal("died")

func reset() -> void:
	if get_tree().is_network_server():
		rpc("puppet_reset")
	damage_stack.append([self, 100.0, OS.get_ticks_msec()])
	emit_signal("died")

remote func puppet_reset() -> void:
	if get_tree().is_network_server():
		rpc("puppet_reset")
	else:
		rpc_id(1, "puppet_reset")
	damage_stack.append([self, 100.0, OS.get_ticks_msec()])
	emit_signal("died")

func _on_Skeleton_hit(projectile : Projectile, part : BodyPart) -> void:
	var damage := calculate_damage(projectile, part)
	damage(projectile, damage)


#accuracy


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


#input


func _unhandled_input(event : InputEvent) -> void:
	if is_network_master():
		#mouse movement
		if event is InputEventMouseMotion:
			var relative = event.relative * camera_sensitiviy
			var current = Head.rotation_degrees
			
			mouse_movement += relative / process_delta
			rotate_head(relative)
			
			var delta : Vector3 = current - Head.rotation_degrees
			emit_signal("camera_movement", Vector3(delta.x, -relative.x, delta.z))
			
			get_tree().set_input_as_handled()
		elif event.is_action_pressed("weapon_next"):
			switch_weapon(weapon_index + 1)
			get_tree().set_input_as_handled()
		elif event.is_action_pressed("weapon_prev"):
			switch_weapon(weapon_index - 1)
			get_tree().set_input_as_handled()
		elif event.is_action_pressed("weapon_1"):
			switch_weapon(0)
			get_tree().set_input_as_handled()
		elif event.is_action_pressed("weapon_2"):
			switch_weapon(1)
			get_tree().set_input_as_handled()
		elif event.is_action_pressed("weapon_3"):
			switch_weapon(2)
			get_tree().set_input_as_handled()
		elif event.is_action_pressed("weapon_4"):
			switch_weapon(3)
			get_tree().set_input_as_handled()
		elif event.is_action_pressed("reset_character"):
			reset()
			get_tree().set_input_as_handled()

func rotate_head(relative : Vector2) -> void:
	RotationHelper.rotate_y(deg2rad(-relative.x))
	#branchless way of limiting up/down movement
	Head.rotation_degrees.x = ((Head.rotation_degrees.x - relative.y) * int(!Head.rotation_degrees.x - relative.y <= camera_min_angle and !Head.rotation_degrees.x - relative.y >= camera_max_angle)
	+ camera_min_angle * int(Head.rotation_degrees.x - relative.y <= camera_min_angle)
	+ camera_max_angle * int(Head.rotation_degrees.x - relative.y >= camera_max_angle))

func get_axis() -> Vector3:
	#reset axis to 0 when getting value
	if is_network_master():
		axis = Vector3.ZERO
	axis += Vector3(0, 0, -1) * Input.get_action_strength("walk_forward")
	axis += Vector3(0, 0, 1) * Input.get_action_strength("walk_backward")
	axis += Vector3(-1, 0, 0) * Input.get_action_strength("walk_left")
	axis += Vector3(1, 0, 0) * Input.get_action_strength("walk_right")
	return axis

func set_delta_vel(delta : float) -> void:
	#not normalized to time
	delta_vel = (velocity - last_vel) / delta
	call_deferred("set_last_vel")

func set_last_vel() -> void:
	last_vel = velocity

func set_delta_pos(_delta : float) -> void:
	current_pos = get_global_transform().origin
	#not normalized to time
	delta_pos = (current_pos - last_pos)
	#set this at last possible moment
	call_deferred("set_last_pos")

func set_last_pos() -> void:
	last_pos = current_pos


#networking


func client_process(_delta : float) -> void:
	if is_network_master():
		#client to server
		rset_unreliable_id(1, "puppet_position", transform.origin)
		rset_unreliable_id(1, "puppet_axis", axis)
		rset_unreliable_id(1, "puppet_head_rotation", Vector2(Head.rotation.x, RotationHelper.rotation.y))
		rset_unreliable_id(1, "puppet_mouse_movement", mouse_movement)
	else:
		#apply data from server
		transform.origin = puppet_position
		axis = puppet_axis
		Head.rotation.x = puppet_head_rotation.x
		RotationHelper.rotation.y = puppet_head_rotation.y
		mouse_movement = puppet_mouse_movement

func server_process(_delta : float) -> void:
	#client to us
	#allow client's position report if it is within given discrepancy
	#position
	if (transform.origin - puppet_position).length() < get_max_movement_speed() * (1 + discrepancy_allowance_position):
		transform.origin = puppet_position
	#reset client's position because it is too far off
	else:
		rpc("set_player_position", transform.origin)
	
	
	if !is_network_master():
		Head.rotation.x = puppet_head_rotation.x
		RotationHelper.rotation.y = puppet_head_rotation.y
		axis = puppet_axis
		mouse_movement = puppet_mouse_movement
	
	#us to clients
	rset_unreliable("puppet_position", transform.origin)
	rset_unreliable("puppet_axis", axis)
	rset_unreliable("puppet_head_rotation", Vector2(Head.rotation.x, RotationHelper.rotation.y))
	rset_unreliable("puppet_mouse_movement", mouse_movement)

remote func set_player_position(pos : Vector3) -> void:
	transform.origin = pos
