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
	
	#initialize
	accuracy = interpolateAccuracy(0.0)
	
	call_deferred("emit_signal", "weapon_changed", weapons[current_weapon])
	print(weapons)
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

remote var aim_spring_target := 0.0
var aim_spring := Physics.Spring.new(0, 0, 0, .5, 1)

var recoil_rotation_spring := Physics.V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)
var recoil_translation_spring := Physics.V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)

var rotation_sway_spring := Physics.V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)
var translation_sway_spring := Physics.V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)

var walk_bob_speed_spring := Physics.Spring.new(0, 0, 0, 0, 1)
var walk_bob_intensity := Physics.Spring.new(1, 0, 1, 0, 1)

#allows for time-based spring stuff
var walk_bob_tick := 0.0

remote var sprint_spring_target := 0.0
var sprint_spring := Physics.Spring.new(0, 0, 0, 0, 1)

var accel_spring := Physics.V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, 0, 1)

var accuracy := {
		"Camera rotation damping": float(.8),
		"Camera rotation speed": float(10.0),
		
		"Min camera rotation": Vector3(-.1, -.1, 0),
		"Max camera rotation": Vector3(.2, .1, 0),
		"Min camera rotation force": Vector3(.1, 0, 0),
		"Max camera rotation force": Vector3(.3, 0, 0),
		
		"Camera translation damping": float(.8),
		"Camera translation speed": float(10.0),
		
		"Min camera translation": Vector3.ZERO,
		"Max camera translation": Vector3(2, 2, 2),
		"Min camera translation force": Vector3.ZERO,
		"Max camera translation force": Vector3.ZERO,
		
		"Camera rotation sway": Vector3(.005, .005, 0),
		"Camera rotation sway speed": float(5.0),
		"Camera rotation sway damping": float(.8),
		
		"Camera bob damper": float(.9),
		"Camera bob idle speed": float(4.0),
		"Camera bob idle intensity": Vector3(.1, .1, .1),
		"Camera bob speed": float(0.1),
		"Camera bob intensity": Vector3(.01, .01, .01),
		
		#total bounds
		"Min translation": Vector3(-.75, -.75, 0),
		"Max translation": Vector3(.5, .5, 2.0),
		"Min rotation": Vector3(-2, -2, -2),
		"Max rotation": Vector3(2, 2, 2),
		
		#recoil force
		"Min translation force": Vector3(-1.2, .2, 2.5),
		"Max translation force": Vector3(1.6, 1.2, 4.0),
		"Min rotation force": Vector3(.4, -1.2, 0),
		"Max rotation force": Vector3(1.0, 1.4, 0),
		
		#recoil spring settings
		"Recoil translation speed": float(13.0),
		"Recoil translation damping": float(.7),
		
		"Recoil rotation speed": float(13.0),
		"Recoil rotation damping": float(.7),
		
		#sway springs
		"Translation sway": Vector3(.1, .1, 0),
		"Translation sway speed": float(14.0),
		"Translation sway damping": float(.6),
		
		"Rotation sway": Vector3(.04, .04, 0),
		"Rotation sway speed": float(12.0),
		"Rotation sway damping": float(.7),
		
		"Gun bob position": Vector3(1.1, .7, 1),
		"Gun bob position multiplier": float(0.04),
		"Gun bob rotation": Vector3(.9, 1.4, 1),
		"Gun bob rotation multiplier": float(0.02),
		"Gun bob idle": float(1.0),
		
		"Gun bob intensity speed": float(10.0),
		"Gun bob intensity damper": float(.9),
		"Gun bob speed damper": float(.7),
		"Gun bob speed speed": float(10.0),
		
		"Gun bob intensity multiplier": float(.01),
		"Gun bob position damping": float(.7),
		"Gun bob position speed": float(3.0),
		
		"Accel sway speed": float(6.0),
		"Accel sway damping": float(.9),
		"Accel sway intensity": Vector3(.3, .4, .15),
		"Accel sway offset": Vector3(0, 0, -1.2),
		
		"Walk damper": float(.9),
		"Walk accel": float(8.0),
		"Walk multiplier": float(1.0),
		
		"Sprint damper": float(.9),
		"Sprint speed": float(10.0),
		"Sprint multiplier": float(1.7),
		
		"Sprint position": Vector3(-.2, -.1, 0),
		"Sprint rotation": Vector3(-.4, 1, .2),
		
		"Spread factor": float(0),
		"Choke": float(0),
		
		"Recoil speed": float(15.0),
		"Recoil damping": float(.8),
		
		"Magnification": float(1.0),
	}

func _process(delta : float) -> void:
	#stackable vars
	var camera_transform = character._Camera.global_transform.basis
	var pos : Vector3 = weapons[current_weapon].data["Weapon handling"]["Position"]
	var rot : Vector3 = weapons[current_weapon].data["Weapon handling"]["Rotation"]
	var speed : float = weapons[current_weapon].data["Weapon handling"]["Walkspeed"]
	
	
	if !is_network_master():
		aim_spring.target = aim_spring_target
		sprint_spring.target = sprint_spring_target
		
	
	
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
