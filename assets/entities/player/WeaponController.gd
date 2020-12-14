extends Spatial

#primary, secondary, melee, grenade
#weapon names
var loadout := ["M4A1", null, null, null]
#weapon nodes
var weapons := [null, null, null, null]
#index of current weapon
var current_weapon := 0

func _ready() -> void:
	#load weapons
	for weapon in range(loadout.size()):
		if loadout[weapon] == null:
			continue
		
		set_weapon(weapon, loadout[weapon])
	
	#initialize springs
	initialize_springs(weapons[0].data)
	add_child(weapons[current_weapon])

func set_weapon(index : int, weapon : String) -> void:
	#load weapon
	var resource : Resource = load(Weapons.manifest[weapon]["info"]["path"] + "/" + Weapons.manifest[weapon]["info"]["scene"])
	weapons[index] = resource.instance()
	loadout[index] = weapon

func load_weapons() -> void:
	pass

onready var base_offset := transform.origin
onready var aim_node : Position3D = find_node("Aim")

var mouse_delta := Vector2.ZERO


#springs


var aim_spring : Physics.Spring
var sway_spring : Physics.V3Spring

func initialize_springs(data : Dictionary) -> void:
	aim_spring = Physics.Spring.new(0, 0, 0, .95, 14)
	sway_spring = Physics.V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, .75, 15)



func _process(delta : float) -> void:
	var pos := Vector3.ZERO
	var rot := Vector3.ZERO
	
	#aiming
	aim_spring.positionvelocity(delta)
	pos -= aim_spring.position * (base_offset + weapons[current_weapon].aim_node.transform.origin)
	
	var accuracy = interpolateAccuracy(aim_spring.position)
	
	#sway
	sway_spring.accelerate(Vector3(mouse_delta.y, mouse_delta.x, 0))
	sway_spring.positionvelocity(delta)
	
	rot += sway_spring.position
	
	transform.origin = base_offset + pos
	rotation_degrees = rot

#interpolate accuracy values between hip and ads
func interpolateAccuracy(amount):
	var dict = {}
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


func _on_Player_camera_movement(relative : Vector2) -> void:
	mouse_delta = relative
