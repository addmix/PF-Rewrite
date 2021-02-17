extends Spatial

#nodes
var character : KinematicBody

#signals
# warning-ignore:unused_signal
signal shot_fired
# warning-ignore:unused_signal
signal set_process

onready var base_offset := transform.origin
onready var aim_node : Position3D = find_node("Aim")

func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	
	call_deferred("deferred")

func deferred() -> void:
	character = get_parent().get_parent().get_parent().get_parent()
	
	set_process(true)
	set_physics_process(true)


var rotation_delta := Vector3.ZERO

var movement_speed := 0.0
var current_weapon : Spatial

#springs
var aim_position_spring := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)

remote var puppet_aim_pos_p := Vector3.ZERO
remote var puppet_aim_pos_v := Vector3.ZERO
remote var puppet_aim_pos_t := Vector3.ZERO

var aim_rotation_spring := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)

remote var puppet_aim_rot_p := Vector3.ZERO
remote var puppet_aim_rot_v := Vector3.ZERO
remote var puppet_aim_rot_t := Vector3.ZERO

var recoil_translation_spring := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)

remote var puppet_recoil_pos_p := Vector3.ZERO
remote var puppet_recoil_pos_v := Vector3.ZERO
remote var puppet_recoil_pos_t := Vector3.ZERO

var recoil_rotation_spring := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)

remote var puppet_recoil_rot_p := Vector3.ZERO
remote var puppet_recoil_rot_v := Vector3.ZERO
remote var puppet_recoil_rot_t := Vector3.ZERO

var rotation_sway_spring := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)
var translation_sway_spring := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)

var accuracy := {}

var delta_pos := Vector3.ZERO
var delta_rot := Vector3.ZERO

func process_recoil(delta : float) -> void:
	network_springs()
	
# warning-ignore:unused_variable
	var camera_transform = character._Camera.global_transform.basis
	
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
	
	aim_position_spring.damper = accuracy["Sight swap d"]
	aim_position_spring.speed = accuracy["Sight swap s"]
	aim_position_spring.target = aim_transform.origin
	aim_position_spring.positionvelocity(delta)
	
	#factors in rotation now
	rot -= character.Aim.position * aim_rotation_spring.position
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
	
	#recoil now goes in direction of gun
	
	#applies all combinative effects
	
	delta_pos = transform.origin
	delta_rot = rotation
	
	transform.origin = pos + character._Camera.base_transform.origin + base_offset
	rotation = rot
	
	delta_pos -= transform.origin / delta
	delta_rot -= rotation / delta
	
	#resets mouse delta
	rotation_delta = Vector3.ZERO
	
	movement_speed = s

func network_springs() -> void:
	if get_tree().is_network_server():
		if is_network_master():
			rset_unreliable("puppet_aim_pos_p", aim_position_spring.position)
			rset_unreliable("puppet_aim_pos_v", aim_position_spring.velocity)
			rset_unreliable("puppet_aim_pos_t", aim_position_spring.target)
			
			rset_unreliable("puppet_aim_rot_p", aim_rotation_spring.position)
			rset_unreliable("puppet_aim_rot_v", aim_rotation_spring.velocity)
			rset_unreliable("puppet_aim_rot_t", aim_rotation_spring.target)
			
			rset_unreliable("puppet_recoil_pos_p", recoil_translation_spring.position)
			rset_unreliable("puppet_recoil_pos_v", recoil_translation_spring.velocity)
			rset_unreliable("puppet_recoil_pos_t", recoil_translation_spring.target)
			
			rset_unreliable("puppet_recoil_rot_p", recoil_rotation_spring.position)
			rset_unreliable("puppet_recoil_rot_v", recoil_rotation_spring.velocity)
			rset_unreliable("puppet_recoil_rot_t", recoil_rotation_spring.target)
		else:
			rset_unreliable("puppet_aim_pos_p", puppet_aim_pos_p)
			rset_unreliable("puppet_aim_pos_v", puppet_aim_pos_v)
			rset_unreliable("puppet_aim_pos_t", puppet_aim_pos_t)
			
			rset_unreliable("puppet_aim_rot_p", puppet_aim_pos_p)
			rset_unreliable("puppet_aim_rot_v", puppet_aim_pos_v)
			rset_unreliable("puppet_aim_rot_t", puppet_aim_pos_t)
			
			rset_unreliable("puppet_recoil_pos_p", puppet_recoil_pos_p)
			rset_unreliable("puppet_recoil_pos_v", puppet_recoil_pos_v)
			rset_unreliable("puppet_recoil_pos_t", puppet_recoil_pos_t)
			
			rset_unreliable("puppet_recoil_rot_p", puppet_recoil_rot_p)
			rset_unreliable("puppet_recoil_rot_v", puppet_recoil_rot_v)
			rset_unreliable("puppet_recoil_rot_t", puppet_recoil_rot_t)
	else:
		if is_network_master():
			rset_unreliable_id(1, "puppet_aim_pos_p", aim_position_spring.position)
			rset_unreliable_id(1, "puppet_aim_pos_v", aim_position_spring.velocity)
			rset_unreliable_id(1, "puppet_aim_pos_t", aim_position_spring.target)
			
			rset_unreliable_id(1, "puppet_aim_rot_p", aim_rotation_spring.position)
			rset_unreliable_id(1, "puppet_aim_rot_v", aim_rotation_spring.velocity)
			rset_unreliable_id(1, "puppet_aim_rot_t", aim_rotation_spring.target)
			
			rset_unreliable_id(1, "puppet_recoil_pos_p", recoil_translation_spring.position)
			rset_unreliable_id(1, "puppet_recoil_pos_v", recoil_translation_spring.velocity)
			rset_unreliable_id(1, "puppet_recoil_pos_t", recoil_translation_spring.target)
			
			rset_unreliable_id(1, "puppet_recoil_rot_p", recoil_rotation_spring.position)
			rset_unreliable_id(1, "puppet_recoil_rot_v", recoil_rotation_spring.velocity)
			rset_unreliable_id(1, "puppet_recoil_rot_t", recoil_rotation_spring.target)
		else:
			aim_position_spring.position = puppet_aim_pos_p
			aim_position_spring.velocity = puppet_aim_pos_v
			aim_position_spring.target = puppet_aim_pos_t
			
			aim_rotation_spring.position = puppet_aim_rot_p
			aim_rotation_spring.velocity = puppet_aim_rot_v
			aim_rotation_spring.target = puppet_aim_rot_t
			
			recoil_translation_spring.position = puppet_recoil_pos_p
			recoil_translation_spring.velocity = puppet_recoil_pos_v
			recoil_translation_spring.target = puppet_recoil_pos_t
			
			recoil_rotation_spring.position = puppet_recoil_rot_p
			recoil_rotation_spring.velocity = puppet_recoil_rot_v
			recoil_rotation_spring.target = puppet_recoil_rot_t

func get_linear_velocity() -> Vector3:
	return delta_pos + character.delta_pos

func get_angular_velocity() -> Vector3:
	return delta_rot

#signals from character
func _on_Character_weapon_changed(weapon : Spatial) -> void:
	current_weapon = weapon

#new accuracy
func _on_Character_update_accuracy(new : Dictionary) -> void:
	accuracy = new

#when gun fires
func _on_Character_shot_fired(direction : Vector3) -> void:
	recoil_rotation_spring.accelerate(MathUtils.v3lerp(accuracy["Min rot force"], accuracy["Max rot force"], direction))
	recoil_translation_spring.accelerate(MathUtils.v3lerp(accuracy["Min pos force"], accuracy["Max pos force"], direction))


func _on_Character_camera_movement(movement : Vector3) -> void:
	rotation_delta += movement
