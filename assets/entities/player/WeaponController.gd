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
		weapons[weapon].add_to_group("weapons")
		weapons[weapon].add_to_group(character.Player.loadout[weapon])
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


#we want to move these somewhere else
#modifier variables
var Equip := false
var Dequip := false
var Air := true
remote var aim_spring_target := 0.0
var Aim := Spring.new(0, 0, 0, .5, 1)
remote var sprint_spring_target := 0.0
var Sprint := Spring.new(0, 0, 0, 0, 1)
var Movement := Vector3.ZERO
var Accel := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, 0, 1)
var Reload := Spring.new(0, 0, 0, 0, 1)
var Crouch := Spring.new(0, 0, 0, 0, 1)
var Prone := Spring.new(0, 0, 0, 0, 1)
var Mounted := Spring.new(0, 0, 0, 0, 1)

#springs


var recoil_rotation_spring := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)
var recoil_translation_spring := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)

var rotation_sway_spring := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)
var translation_sway_spring := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)

#allows for time-based spring stuff
var walk_bob_tick := 0.0

var accuracy := {}

var delta_pos := Vector3.ZERO
var delta_rot := Vector3.ZERO

func _process(delta : float) -> void:
	accuracy = get_accuracy()
	
	var camera_transform = character._Camera.global_transform.basis
	
	#stackable vars
	var pos : Vector3 = accuracy["Pos"]
	var rot : Vector3 = accuracy["Rot"]
	var s : float = weapons[current_weapon].data["Weapon handling"]["Walkspeed"]
	
	
	
	if !is_network_master():
		Aim.target = aim_spring_target
		Sprint.target = sprint_spring_target
	
	
	#modifier variables
	
	
	Equip = float(weapons[current_weapon].EquipMachine.current_state == "Equip")
	Dequip = float(weapons[current_weapon].EquipMachine.current_state == "Dequip")
	Air = float(character.is_on_floor())
	Movement = character.movement_spring.position
	
	#reload
	Reload.target = float(weapons[current_weapon].ReloadMachine.currentState != "Ready" and !weapons[current_weapon].ReloadMachine.states[weapons[current_weapon].ReloadMachine.currentState].stopped)
	Reload.damper = accuracy["Reload d"]
	Reload.speed = accuracy["Reload s"]
	Reload.positionvelocity(delta)
	
	#aiming
	Aim.damper = weapons[current_weapon].data["Weapon handling"]["Aim d"]
	Aim.speed = weapons[current_weapon].data["Weapon handling"]["Aim s"]
	Aim.positionvelocity(delta)
	pos -= Aim.position * (base_offset + weapons[current_weapon].aim_node.transform.origin - character._Camera.base_offset + weapons[current_weapon].data["Weapon handling"]["Pos"])
	
	#sprinting
	Sprint.damper = accuracy["Sprint d"]
	Sprint.speed = accuracy["Sprint s"]
	Sprint.positionvelocity(delta)
	
#	pos += Sprint.position * accuracy["Sprint pos"]
#	rot += Sprint.position * accuracy["Sprint rot"]
	
	#acceleration
	Accel.damper = accuracy["Accel sway d"]
	Accel.speed = accuracy["Accel sway s"]
	Accel.accelerate(camera_transform.xform_inv(character.delta_vel))
	Accel.positionvelocity(delta)
	
	#translate accel spring position to character local space and separate to pos/rot
	pos -= Accel.position * accuracy["Accel sway i"]
	
#	Crouch = Spring.new(0, 0, 0, 0, 1)
#	Prone = Spring.new(0, 0, 0, 0, 1)
#	Mounted = Spring.new(0, 0, 0, 0, 1)
	
	
	
	
	
	
	
	
	
	
	
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
	
	walk_bob_tick += delta * (accuracy["Gun bob s"] + 1)
	
	pos += Vector3(cos(walk_bob_tick / 2) * 2, sin(walk_bob_tick), 0) * accuracy["Gun bob pos i"]
	rot += Vector3(cos(walk_bob_tick), sin(walk_bob_tick / 2), 0) * accuracy["Gun bob rot i"]
	
	
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
	emit_signal("shot_fired", Aim.position)
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

func get_accuracy() -> Dictionary:
	#make copy of data
	var data : Dictionary = weapons[current_weapon].data["Weapon handling"]
	
	var copy := {}
	#clone dictionary
	for i in data.keys():
		copy[i] = data[i]
	
	#modifiers only use multiplication
	
	#multiplicative
	for modifier in weapons[current_weapon].multi.keys():
		var value = get_modifier_value(modifier)
	
		#each property
		for key in weapons[current_weapon].multi[modifier].keys():
			#hacky way to normalize values and add
			copy[key] *= lerp(weapons[current_weapon].multi[modifier][key] / weapons[current_weapon].multi[modifier][key], weapons[current_weapon].multi[modifier][key], value)
	
	#additive
	for modifier in weapons[current_weapon].add.keys():
		var value = get_modifier_value(modifier)
		
		#each property
		for key in weapons[current_weapon].add[modifier].keys():
			#hacky way to normalize values and add
			copy[key] += weapons[current_weapon].add[modifier][key] * value
	
	
	
	return copy

func get_modifier_value(modifier : String):
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
		TYPE_VECTOR3:
			value = prop.length()
		TYPE_VECTOR2:
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

func _unhandled_input(event : InputEvent) -> void:
	if !is_network_master():
		return
	
	
	if event.is_action_pressed("aim"):
		rset("aim_spring_target", 1)
		Aim.target = 1
		get_tree().set_input_as_handled()
	elif event.is_action_released("aim"):
		rset("aim_spring_target", 0)
		Aim.target = 0
		get_tree().set_input_as_handled()
	
	elif event.is_action_pressed("sprint"):
		rset("sprint_spring_target", 1)
		Sprint.target = 1
		get_tree().set_input_as_handled()
	elif event.is_action_released("sprint"):
		rset("sprint_spring_target", 0)
		Sprint.target = 0
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
