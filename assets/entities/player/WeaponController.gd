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
	
	#loads weapons
	for weapon in range(character.player.loadout.size()):
		if character.player.loadout[weapon] == null:
			continue
		set_weapon(weapon, character.player.loadout[weapon])
		character.player.loadout[weapon].connect("shotFired", self, "on_shot_fired")
		character.player.loadout[weapon].connect("equipped", self, "on_weapon_equipped")
		character.player.loadout[weapon].connect("dequipped", self, "on_weapon_dequipped")
	
	add_child(weapons[current_weapon])
	weapons[current_weapon].equip()
	
	#initialize
	accuracy = interpolateAccuracy(0.0)
	
	
	call_deferred("emit_signal", "weapon_changed", weapons[current_weapon])
	call_deferred("deferred")

func deferred() -> void:
	character = get_parent().get_parent().get_parent().get_parent()
	set_process(true)
	emit_signal("set_process", true)

#loading of weapon
func set_weapon(index : int, weapon : String) -> void:
	#load weapon
	var resource : Resource = load(Weapons.manifest[weapon]["info"]["path"] + "/" + Weapons.manifest[weapon]["info"]["scene"])
	weapons[index] = resource.instance()

func switch_weapon(index : int) -> void:
	#do dequip animation
	weapons[current_weapon].dequip()
	new_weapon = index
#used for non-immediate weapon swapping
var new_weapon := 0

#pickup weapon to empty slot
func pickup_weapon(selected : Spatial) -> void:
	pass

#swap with weapon on ground
func change_weapon(selected : Spatial) -> void:
	pass

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


var aim_spring := Physics.Spring.new(0, 0, 0, .5, 1)

var recoil_rotation_spring := Physics.V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)
var recoil_translation_spring := Physics.V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)

var rotation_sway_spring := Physics.V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)
var translation_sway_spring := Physics.V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)

var walk_bob_speed_spring := Physics.Spring.new(0, 0, 0, 0, 1)
var walk_bob_intensity := Physics.Spring.new(1, 0, 1, 0, 1)

#allows for time-based spring stuff
var walk_bob_tick := 0.0

var sprint_spring := Physics.Spring.new(0, 0, 0, 0, 1)

var accel_spring := Physics.V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, 0, 1)

var accuracy := {}#interpolateAccuracy(aim_spring.position)

func _process(delta : float) -> void:
	#stackable vars
	var camera_transform = character._Camera.global_transform.basis
	var pos : Vector3 = weapons[current_weapon].data["Weapon handling"]["Position"]
	var rot : Vector3 = weapons[current_weapon].data["Weapon handling"]["Rotation"]
	var speed : float = weapons[current_weapon].data["Weapon handling"]["Walkspeed"]
	
	
	#aiming
	
	
	aim_spring.damper = weapons[current_weapon].data["Weapon handling"]["Aiming damping"]
	aim_spring.speed = weapons[current_weapon].data["Weapon handling"]["Aiming speed"]
	
	aim_spring.positionvelocity(delta)
	pos -= aim_spring.position * (base_offset + weapons[current_weapon].aim_node.transform.origin - character._Camera.base_offset + weapons[current_weapon].data["Weapon handling"]["Position"])
	
	accuracy = interpolateAccuracy(aim_spring.position)
	
	speed *= accuracy["Walk multiplier"]
	
	
	#sprinting
	
	
	sprint_spring.damper = accuracy["Sprint damper"]
	sprint_spring.speed = accuracy["Sprint speed"]
	sprint_spring.target = float(is_network_master() and Input.is_action_pressed("sprint"))
	
	sprint_spring.positionvelocity(delta)
	
	pos += sprint_spring.position * accuracy["Sprint position"]
	rot += sprint_spring.position * accuracy["Sprint rotation"]
	speed *= lerp(1.0, accuracy["Sprint multiplier"], sprint_spring.position) 
	
	
	#acceleration
	
	
	accel_spring.damper = accuracy["Accel sway damping"]
	accel_spring.speed = accuracy["Accel sway speed"]
	accel_spring.accelerate(camera_transform.xform_inv(character.delta_vel))
	accel_spring.positionvelocity(delta)
	
	#translate accel spring position to character local space and separate to pos/rot
	pos -= accel_spring.position * accuracy["Accel sway intensity"]
	
	
	#recoil
	
	
	recoil_rotation_spring.damper = accuracy["Recoil rotation damping"]
	recoil_rotation_spring.speed = accuracy["Recoil rotation speed"]
	
	recoil_rotation_spring.positionvelocity(delta)
	rot += recoil_rotation_spring.position
	
	recoil_translation_spring.damper = accuracy["Recoil translation damping"]
	recoil_translation_spring.speed = accuracy["Recoil translation speed"]
	
	recoil_translation_spring.positionvelocity(delta)
	pos += recoil_translation_spring.position
	
	
	#camera movement sway
	
	
	rotation_sway_spring.accelerate(rotation_delta * accuracy["Rotation sway"])
	rotation_sway_spring.damper = accuracy["Rotation sway damping"]
	rotation_sway_spring.speed = accuracy["Rotation sway speed"]
	
	rotation_sway_spring.positionvelocity(delta)
	rot += Vector3(rotation_sway_spring.position.x, -rotation_sway_spring.position.y, rotation_sway_spring.position.z)
	
	translation_sway_spring.accelerate(rotation_delta * accuracy["Translation sway"])
	translation_sway_spring.damper = accuracy["Translation sway damping"]
	translation_sway_spring.speed = accuracy["Translation sway speed"]
	
	translation_sway_spring.positionvelocity(delta)
	pos += Vector3(translation_sway_spring.position.y, translation_sway_spring.position.x, translation_sway_spring.position.z)
	
	
	#walk bob speed
	
	
	walk_bob_speed_spring.damper = accuracy["Gun bob speed damper"]
	walk_bob_speed_spring.speed = accuracy["Gun bob speed speed"]
	walk_bob_speed_spring.target = character.player_velocity.length() * int(character.is_on_floor())
	walk_bob_speed_spring.positionvelocity(delta)
	
	
	#intensity
	
	
	walk_bob_intensity.damper = accuracy["Gun bob intensity damper"]
	walk_bob_intensity.speed = accuracy["Gun bob intensity speed"]
	walk_bob_intensity.target = character.player_velocity.length() * accuracy["Gun bob intensity multiplier"] + accuracy["Gun bob idle"]
	walk_bob_intensity.positionvelocity(delta)
	
	walk_bob_tick += delta * (walk_bob_speed_spring.position + 1)
	
	pos += Vector3(cos(walk_bob_tick / 2) * 2, sin(walk_bob_tick), 0) * accuracy["Gun bob position"] * accuracy["Gun bob position multiplier"] * walk_bob_intensity.position
	rot += Vector3(cos(walk_bob_tick), sin(walk_bob_tick / 2), 0) * accuracy["Gun bob rotation"] * accuracy["Gun bob rotation multiplier"] * walk_bob_intensity.position
	
	
	#applies all combinative effects
	
	transform.origin = base_offset + pos - weapons[current_weapon].base_offset
	
	rotation = rot
	rotation_delta = Vector3.ZERO
	
	movement_speed = speed

func on_shot_fired() -> void:
	emit_signal("shot_fired", aim_spring.position)
	recoil_rotation_spring.accelerate(MathUtils.v3RandfRange(accuracy["Min rotation force"], accuracy["Max rotation force"]))
	recoil_translation_spring.accelerate(MathUtils.v3RandfRange(accuracy["Min translation force"], accuracy["Max translation force"]))

#interpolate accuracy values between hip and ads
func interpolateAccuracy(amount : float) -> Dictionary:
	var dict := {}
	#go through each value and interpolate between Hip accuracy value and Sight accuracy value
	for key in weapons[current_weapon].data["Sight accuracy"].keys():
		#reconstruct accuracy dictionary
		dict[key] = lerp(weapons[current_weapon].data["Hip accuracy"][key], weapons[current_weapon].data["Sight accuracy"][key], amount)
	return dict

func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("aim"):
		aim_spring.target = 1
		get_tree().set_input_as_handled()
	elif event.is_action_released("aim"):
		aim_spring.target = 0
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
