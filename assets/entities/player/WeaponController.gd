extends Spatial

signal weapon_changed
signal shot_fired
signal set_process

#primary, secondary, melee, grenade
#weapon names
var loadout := ["M4A1", null, null, null]
#weapon nodes
var weapons := [null, null, null, null]
#index of current weapon
var current_weapon := 0

func _ready() -> void:
	emit_signal("set_process", false)
	#load weapons
	for weapon in range(loadout.size()):
		if loadout[weapon] == null:
			continue
		set_weapon(weapon, loadout[weapon])
		weapons[weapon].connect("shotFired", self, "on_shot_fired")
	
	add_child(weapons[current_weapon])
	accuracy = interpolateAccuracy(0.0)
	emit_signal("set_process", true)
	call_deferred("emit_signal", "weapon_changed", weapons[current_weapon])

func set_weapon(index : int, weapon : String) -> void:
	#load weapon
	var resource : Resource = load(Weapons.manifest[weapon]["info"]["path"] + "/" + Weapons.manifest[weapon]["info"]["scene"])
	weapons[index] = resource.instance()
	loadout[index] = weapon

func load_weapons() -> void:
	pass

func change_weapon(index : int) -> void:
	remove_child(weapons[current_weapon])
	current_weapon = index
	add_child(weapons[current_weapon])
	emit_signal("weapon_changed", weapons[current_weapon])

onready var base_offset := transform.origin
onready var aim_node : Position3D = find_node("Aim")

var rotation_delta := Vector3.ZERO


#springs




#
#		#total bounds
#		"Min translation": Vector3(-.75, -.75, 0),
#		"Max translation": Vector3(.5, .5, 2.0),
#		"Min rotation": Vector3(-2, -2, -2),
#		"Max rotation": Vector3(2, 2, 2),
#
#		#recoil force
#		"Min translation force": Vector3(-1.2, .2, 2.5),
#		"Max translation force": Vector3(1.6, 1.2, 4.0),
#		"Min rotation force": Vector3(.4, -1.2, 0),
#		"Max rotation force": Vector3(1.0, 1.4, 0),
#
#		#recoil spring settings
#		"Recoil translation speed": 13,
#		"Recoil translation damping": .7,
#
#		"Recoil rotation speed": 13,
#		"Recoil rotation damping": .7,
#
#		#sway springs
#		"Translation sway": Vector3(.2, .2, 0),
#		"Translation sway speed": 12.0,
#		"Translation sway damping": .7,
#
#		"Rotation sway": Vector3(.4, .4, 0),
#		"Rotation sway speed": 12.0,
#		"Rotation sway damping": .7,
#
#		"Walkspeed": 12.0,
#
#		"Spread factor": float(0),
#		"Choke": float(0),
#
#		"Recoil speed": 15.0,
#		"Recoil damping": .8,
#
#		"Magnification": 1.0,
#	},

var aim_spring := Physics.Spring.new(0, 0, 0, .5, 1)

var recoil_rotation_spring := Physics.V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)
var recoil_translation_spring := Physics.V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)

var rotation_sway_spring := Physics.V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)
var translation_sway_spring := Physics.V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .5, 1)


var accuracy := {}#interpolateAccuracy(aim_spring.position)

func _process(delta : float) -> void:
	var pos := Vector3.ZERO
	var rot := Vector3.ZERO
	
	#aiming
	aim_spring.damper = weapons[current_weapon].data["Weapon handling"]["Aiming damping"]
	aim_spring.speed = weapons[current_weapon].data["Weapon handling"]["Aiming speed"]
	
	aim_spring.positionvelocity(delta)
	pos -= aim_spring.position * (base_offset + weapons[current_weapon].aim_node.transform.origin)
	
	accuracy = interpolateAccuracy(aim_spring.position)
	
	#recoil
	recoil_rotation_spring.damper = accuracy["Recoil rotation damping"]
	recoil_rotation_spring.speed = accuracy["Recoil rotation speed"]
	
	recoil_rotation_spring.positionvelocity(delta)
	rot += recoil_rotation_spring.position
	
	recoil_translation_spring.damper = accuracy["Recoil translation damping"]
	recoil_translation_spring.speed = accuracy["Recoil translation speed"]
	
	recoil_translation_spring.positionvelocity(delta)
	pos += recoil_translation_spring.position
	
	#sway
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
	
	
	transform.origin = base_offset + pos
	rotation = rot
	rotation_delta = Vector3.ZERO

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
	
	
	elif event.is_action_pressed("weapon_1"):
			change_weapon(0)
	elif event.is_action_pressed("weapon_2"):
			change_weapon(1)
	elif event.is_action_pressed("weapon_3"):
			change_weapon(2)
	elif event.is_action_pressed("weapon_4"):
			change_weapon(3)

func _on_Player_camera_movement(relative : Vector3) -> void:
	rotation_delta = relative
