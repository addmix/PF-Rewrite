extends Spatial


#variables


#controls
var rotation_delta := Vector3.ZERO

#movement
var movement_speed := 0.0
onready var base_offset := transform.origin

const aim_pos_variance := .05
var aim_position_spring := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)
remote var puppet_aim_pos := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, 0, 1)

const aim_rot_variance := .05
var aim_rotation_spring := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)
remote var puppet_aim_rot := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, 0, 1)

const recoil_pos_variance := .05
var recoil_translation_spring := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)
remote var puppet_recoil_pos := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, 0, 1)

const recoil_rot_variance := .05
var recoil_rotation_spring := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)
remote var puppet_recoil_rot := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, 0, 1)

const pos_sway_variance := .05
var translation_sway_spring := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)
remote var puppet_sway_pos := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, 0, 1)

const rot_sway_variance := .05
var rotation_sway_spring := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)
remote var puppet_sway_rot := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, 0, 1)

#accuracy
var accuracy := {}


var delta_pos := Vector3.ZERO
var delta_rot := Vector3.ZERO


#nodes


#general
var character : KinematicBody

#weapons
var current_weapon : Spatial
onready var aim_node : Position3D = find_node("Aim")



#functions




#base funcs


func _init() -> void:
	set_process(false)
	set_physics_process(false)

func _physics_process(_delta : float) -> void:
	network_springs()


#nodes


func on_character_loaded(c : Character) -> void:
	character = c
	
	set_process(true)
	set_physics_process(true)


#control


func _on_Character_camera_movement(movement : Vector3) -> void:
	rotation_delta += movement


#movement


func get_linear_velocity() -> Vector3:
	return delta_pos + character.delta_pos

func get_angular_velocity() -> Vector3:
	return delta_rot

func process_recoil(delta : float) -> void:
	#stackable vars
	var pos : Vector3 = accuracy["Pos"]
	var rot : Vector3 = accuracy["Rot"]
	var s : float = current_weapon.data["Weapon handling"]["Walkspeed"]
	
	#accel spring
#	#translate accel spring position to character local space and separate to pos/rot
	pos -= character.Accel.position * accuracy["Accel sway pos i"]
	var x : Vector3 = character.Accel.position * accuracy["Accel sway rot i"]
	rot += Vector3(-x.y, x.x, x.z)
	
	#camera movement sway
	rotation_sway_spring.accelerate(rotation_delta * accuracy["Rot sway"])
	rotation_sway_spring.damper = accuracy["Rot sway d"]
	rotation_sway_spring.speed = accuracy["Rot sway s"]
	rotation_sway_spring.positionvelocity(delta)
	rot += Vector3(rotation_sway_spring.position.x, -rotation_sway_spring.position.y, rotation_sway_spring.position.z)
	
	translation_sway_spring.accelerate(rotation_delta * accuracy["Pos sway"])
	translation_sway_spring.damper = accuracy["Pos sway d"]
	translation_sway_spring.speed = accuracy["Pos sway s"]
	translation_sway_spring.positionvelocity(delta)
	pos += Vector3(translation_sway_spring.position.y, translation_sway_spring.position.x, translation_sway_spring.position.z)
	
	
	#intensity
	pos += Vector3(cos(character.walk_bob_tick / 2) * 2, sin(character.walk_bob_tick), 0) * accuracy["Gun bob pos i"]
	rot += Vector3(cos(character.walk_bob_tick), sin(character.walk_bob_tick / 2), 0) * accuracy["Gun bob rot i"]
	#breath sway
	pos += Vector3(cos(character.breath_sway_tick / 2) * 2, sin(character.breath_sway_tick), 0) * accuracy["Breath sway pos i"]
	rot += Vector3(cos(character.breath_sway_tick), sin(character.breath_sway_tick / 2), 0) * accuracy["Breath sway rot i"]
	
	
	var aim_transform : Transform = current_weapon.get_aim()
	#itnerpolate position and rotation between sights
	aim_rotation_spring.damper = accuracy["Sight swap d"]
	aim_rotation_spring.speed = accuracy["Sight swap s"]
	aim_rotation_spring.target = aim_transform.basis.get_euler()
	aim_rotation_spring.positionvelocity(delta)
	rot -= character.Aim.position * aim_rotation_spring.position
	
	aim_position_spring.damper = accuracy["Sight swap d"]
	aim_position_spring.speed = accuracy["Sight swap s"]
	aim_position_spring.target = aim_transform.origin
	aim_position_spring.positionvelocity(delta)
	pos -= character.Aim.position * Basis(character.Aim.position * aim_rotation_spring.position).xform_inv(aim_position_spring.position) + character.Aim.position * base_offset
	
	#recoil
	recoil_rotation_spring.damper = accuracy["Recoil rot d"]
	recoil_rotation_spring.speed = accuracy["Recoil rot s"]
	recoil_rotation_spring.positionvelocity(delta)
	rot = (Basis(rot) * Basis(recoil_rotation_spring.position)).get_euler()
	
	recoil_translation_spring.damper = accuracy["Recoil pos d"]
	recoil_translation_spring.speed = accuracy["Recoil pos s"]
	recoil_translation_spring.positionvelocity(delta)
	pos += Basis(rot).xform_inv(recoil_translation_spring.position)
	
	transform.origin = pos + character._Camera.base_transform.origin + base_offset
	rotation = rot
	
	delta_pos = transform.origin / delta
	delta_rot = rotation / delta
	
	#resets mouse delta
	rotation_delta = Vector3.ZERO
	movement_speed = s


#networking

remote func set_aim_pos() -> void:
	aim_position_spring = puppet_aim_pos

remote func set_aim_rot() -> void:
	aim_rotation_spring = puppet_aim_rot

remote func set_recoil_pos() -> void:
	recoil_translation_spring = puppet_recoil_pos

remote func set_recoil_rot() -> void:
	recoil_rotation_spring = puppet_recoil_rot

remote func set_sway_pos() -> void:
	translation_sway_spring = puppet_sway_pos

remote func set_sway_rot() -> void:
	rotation_sway_spring = puppet_sway_rot

func network_springs() -> void:
	if get_tree().is_network_server():
		#check values
		#position
		if aim_position_spring.check_discrepancy(puppet_aim_pos, aim_pos_variance):
			aim_position_spring = puppet_aim_pos
		else:
			rpc("set_aim_pos")
		
		if aim_rotation_spring.check_discrepancy(puppet_aim_rot, aim_rot_variance):
			aim_rotation_spring = puppet_aim_rot
		else:
			rpc("set_aim_rot")
		
		#recoil
		if recoil_translation_spring.check_discrepancy(puppet_recoil_pos, recoil_pos_variance):
			recoil_translation_spring = puppet_recoil_pos
		else:
			rpc("set_recoil_pos")
		
		if recoil_rotation_spring.check_discrepancy(puppet_recoil_rot, recoil_rot_variance):
			recoil_rotation_spring = puppet_recoil_rot
		else:
			rpc("set_recoil_rot")
		
		#sway
		if translation_sway_spring.check_discrepancy(puppet_sway_pos, pos_sway_variance):
			translation_sway_spring = puppet_sway_pos
		else:
			rpc("set_sway_pos")
		
		if rotation_sway_spring.check_discrepancy(puppet_sway_rot, rot_sway_variance):
			rotation_sway_spring = puppet_sway_rot
		else:
			rpc("set_sway_rot")
		
		#apply values
		rset("puppet_aim_pos", aim_position_spring)
		rset("puppet_aim_rot", aim_rotation_spring)
		rset("puppet_recoil_pos", recoil_translation_spring)
		rset("puppet_recoil_rot", recoil_rotation_spring)
		rset("puppet_sway_pos", translation_sway_spring)
		rset("puppet_sway_rot", rotation_sway_spring)
	else:
		if is_network_master():
			rset_id(1, "puppet_aim_pos", aim_position_spring)
			rset_id(1, "puppet_aim_rot", aim_rotation_spring)
			rset_id(1, "puppet_recoil_pos", recoil_translation_spring)
			rset_id(1, "puppet_recoil_rot", recoil_rotation_spring)
			rset_id(1, "puppet_sway_pos", translation_sway_spring)
			rset_id(1, "puppet_sway_rot", rotation_sway_spring)
		else:
			aim_position_spring = puppet_aim_pos
			aim_rotation_spring = puppet_aim_rot
			recoil_translation_spring = puppet_recoil_pos
			recoil_rotation_spring = puppet_recoil_rot
			translation_sway_spring = puppet_sway_pos
			rotation_sway_spring = puppet_sway_rot


#weapons


func _on_Character_weapon_changed(weapon : Spatial) -> void:
	current_weapon = weapon

func _on_Character_update_accuracy(new : Dictionary) -> void:
	accuracy = new

func _on_Character_shot_fired(direction : Vector3) -> void:
	recoil_rotation_spring.accelerate(MathUtils.v3lerp(accuracy["Min rot force"], accuracy["Max rot force"], direction))
	recoil_translation_spring.accelerate(MathUtils.v3lerp(accuracy["Min pos force"], accuracy["Max pos force"], direction))
