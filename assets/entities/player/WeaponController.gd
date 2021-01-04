extends Spatial

#nodes
var character : KinematicBody

#signals
signal weapon_changed
signal shot_fired
signal set_process

#primary, secondary, melee, grenade

#weapon nodes
var weapons := [null, null, null, null]
#index of current weapon
var current_weapon := 0

func _ready() -> void:
	set_process(false)
	emit_signal("set_process", false)
	call_deferred("deferred")

func deferred() -> void:
	character = get_parent().get_parent().get_parent().get_parent()
	
	#loads weapons
	for weapon in range(character.Player.loadout.size()):
		if character.Player.loadout[weapon] == null:
			continue
		set_weapon(weapon, character.Player.loadout[weapon])
		weapons[weapon].connect("shotFired", self, "on_shot_fired")
		weapons[weapon].connect("equipped", self, "on_weapon_equipped")
		weapons[weapon].connect("dequipped", self, "on_weapon_dequipped")
		weapons[weapon].set_network_master(character.Player.player_id)
	
	add_child(weapons[current_weapon])
	weapons[current_weapon].equip()
	
	accuracy = weapons[current_weapon].data["Weapon handling"]
	
	call_deferred("emit_signal", "weapon_changed", weapons[current_weapon])
	
	
	set_process(true)
	emit_signal("set_process", true)

#loading of weapon
func set_weapon(index : int, weapon : String) -> void:
	#load weapon
	weapons[index] = Weapons.models[weapon].instance()

func switch_weapon(index : int) -> void:
	if weapons[index] == null:
		return
	#do dequip animation
	weapons[current_weapon].dequip()
	new_weapon = index
#used for non-immediate weapon swapping
var new_weapon := 0

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
	current_weapon = new_weapon
	remove_child(weapon)
	
	add_child(weapons[current_weapon])
	weapons[current_weapon].equip()
	
	emit_signal("weapon_changed", weapons[current_weapon])


onready var base_offset := transform.origin
onready var aim_node : Position3D = find_node("Aim")

var rotation_delta := Vector3.ZERO

var movement_speed := 0.0


#springs

remote var aim_spring_target := 0.0
var aim_spring := Physics.Spring.new(0, 0, 0, .5, 1)

var recoil_rotation_spring := Physics.V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)
var recoil_translation_spring := Physics.V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)

var rotation_sway_spring := Physics.V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)
var translation_sway_spring := Physics.V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)

#allows for time-based spring stuff
var walk_bob_tick := 0.0

remote var sprint_spring_target := 0.0
var sprint_spring := Physics.Spring.new(0, 0, 0, 0, 1)

var accel_spring := Physics.V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, 0, 1)

var accuracy := {}

var delta_pos := Vector3.ZERO
var delta_rot := Vector3.ZERO

func _process(delta : float) -> void:
	var camera_transform = character._Camera.global_transform.basis
	
	#stackable vars
	var pos : Vector3 = weapons[current_weapon].data["Weapon handling"]["Pos"]
	var rot : Vector3 = weapons[current_weapon].data["Weapon handling"]["Rot"]
	var s : float = weapons[current_weapon].data["Weapon handling"]["Walkspeed"]
	
	
	#modifying springs
	#sprinting
	#aiming
	
	#modifying variables
	#s
	#acceleration
	
	
	if !is_network_master():
		aim_spring.target = aim_spring_target
		sprint_spring.target = sprint_spring_target
	
	
	#aiming
	
	
	aim_spring.damper = weapons[current_weapon].data["Weapon handling"]["Aim d"]
	aim_spring.speed = weapons[current_weapon].data["Weapon handling"]["Aim s"]
	
	aim_spring.positionvelocity(delta)
	pos -= aim_spring.position * (base_offset + weapons[current_weapon].aim_node.transform.origin - character._Camera.base_offset + weapons[current_weapon].data["Weapon handling"]["Pos"])
	
#	accuracy = interpolateAccuracy(aim_spring.position)
	accuracy = weapons[current_weapon].data["Weapon handling"]
	
	
	#sprinting
	
	
	sprint_spring.damper = accuracy["Sprint d"]
	sprint_spring.speed = accuracy["Sprint s"]
	
	sprint_spring.positionvelocity(delta)
	
	
	#acceleration
	
	
	accel_spring.damper = accuracy["Accel sway d"]
	accel_spring.speed = accuracy["Accel sway s"]
	accel_spring.accelerate(camera_transform.xform_inv(character.delta_vel))
	accel_spring.positionvelocity(delta)
	
	#translate accel spring position to character local space and separate to pos/rot
	pos -= accel_spring.position * accuracy["Accel sway i"]
	
	
	#recoil
	
	
	recoil_rotation_spring.damper = accuracy["Recoil rot d"]
	recoil_rotation_spring.speed = accuracy["Recoil rot s"]
	
	recoil_rotation_spring.positionvelocity(delta)
	rot += recoil_rotation_spring.position
	
	recoil_translation_spring.damper = accuracy["Recoil pos d"]
	recoil_translation_spring.speed = accuracy["Recoil pos s"]
	
	recoil_translation_spring.positionvelocity(delta)
	pos += recoil_translation_spring.position
	
	
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
	
	var walk_bob_speed : float = accuracy["Gun bob s"]
	var walk_bob_pos_i : Vector3 = accuracy["Gun bob pos i"]
	var walk_bob_rot_i : Vector3 = accuracy["Gun bob rot i"]
	
	walk_bob_speed *= character.player_velocity.length() * int(character.is_on_floor())
	
	walk_bob_tick += delta * (walk_bob_speed + 1)
	
	pos += Vector3(cos(walk_bob_tick / 2) * 2, sin(walk_bob_tick), 0) * (character.player_velocity.length() * accuracy["Gun bob pos i"])
	rot += Vector3(cos(walk_bob_tick), sin(walk_bob_tick / 2), 0) * (character.player_velocity.length() * accuracy["Gun bob rot i"])
	
	
	#applies all combinative effects
	
	delta_pos = transform.origin
	delta_rot = rotation
	
	transform.origin = base_offset + pos - weapons[current_weapon].base_offset
	rotation = rot
	
	delta_pos -= transform.origin / delta
	delta_rot -= rotation / delta
	
	#resets mouse delta
	rotation_delta = Vector3.ZERO
	
	movement_speed = s

func get_linear_velocity() -> Vector3:
	return delta_pos + character.delta_pos

func get_angular_velocity() -> Vector3:
	return delta_rot

func on_shot_fired() -> void:
	emit_signal("shot_fired", aim_spring.position)
	recoil_rotation_spring.accelerate(MathUtils.v3RandfRange(accuracy["Min rot force"], accuracy["Max rot force"]))
	recoil_translation_spring.accelerate(MathUtils.v3RandfRange(accuracy["Min pos force"], accuracy["Max pos force"]))

#interpolate accuracy values between hip and ads
func interpolateAccuracy(amount : float) -> Dictionary:
	var dict := {}
	#go through each value and interpolate between Hip accuracy value and Sight accuracy value
	for key in weapons[current_weapon].data["Sight accuracy"].keys():
		#reconstruct accuracy dictionary
		dict[key] = lerp(weapons[current_weapon].data["Hip accuracy"][key], weapons[current_weapon].data["Sight accuracy"][key], amount)
	return dict

func _unhandled_input(event : InputEvent) -> void:
	if !is_network_master():
		return
	
	
	if event.is_action_pressed("aim"):
		rset("aim_spring_target", 1)
		aim_spring.target = 1
		get_tree().set_input_as_handled()
	elif event.is_action_released("aim"):
		rset("aim_spring_target", 0)
		aim_spring.target = 0
		get_tree().set_input_as_handled()
	
	elif event.is_action_pressed("sprint"):
		rset("sprint_spring_target", 1)
		sprint_spring.target = 1
		get_tree().set_input_as_handled()
	elif event.is_action_released("sprint"):
		rset("sprint_spring_target", 0)
		sprint_spring.target = 0
		get_tree().set_input_as_handled()
	
	#switch to next weapon
	elif event.is_action_pressed("weapon_next"):
		#looparound functionality
		if current_weapon + 1 > weapons.size():
			switch_weapon(0)
		else:
			switch_weapon((current_weapon + 1) % weapons.size())
	#switch to previous weapon
	elif event.is_action_pressed("weapon_prev"):
		#looparound functionality
		if current_weapon - 1 < 0:
			switch_weapon(weapons.size() - 1)
		else:
			switch_weapon((current_weapon - 1) % weapons.size())
	
	#switching to specific weapons
	elif event.is_action_pressed("weapon_1"):
			if current_weapon == 0:
				return
			switch_weapon(0)
	elif event.is_action_pressed("weapon_2"):
			if current_weapon == 1:
				return
			if weapons.size() >= 1:
				switch_weapon(1)
	elif event.is_action_pressed("weapon_3"):
			if current_weapon == 2:
				return
			if weapons.size() >= 2:
				switch_weapon(2)
	elif event.is_action_pressed("weapon_4"):
			if current_weapon == 3:
				return
			if weapons.size() >= 3:
				switch_weapon(3)

func _on_Player_camera_movement(relative : Vector3) -> void:
	rotation_delta = relative
