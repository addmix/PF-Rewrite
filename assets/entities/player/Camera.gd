extends Camera

onready var WeaponController = get_parent().get_node("WeaponController")

var rotation_delta := Vector3.ZERO

var rotation_spring := Physics.V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, 0, 1)
var translation_spring := Physics.V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, 0, 1)
var rotation_sway_spring := Physics.V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, 0, 1)

func _on_WeaponController_shot_fired(aim : float) -> void:
	rotation_spring.accelerate(MathUtils.v3RandfRange(WeaponController.accuracy["Min camera rotation force"], WeaponController.accuracy["Max camera rotation force"]))
	translation_spring.accelerate(MathUtils.v3RandfRange(WeaponController.accuracy["Min camera translation force"], WeaponController.accuracy["Max camera translation force"]))

func _on_WeaponController_weapon_changed(weapon : Spatial) -> void:
	pass # Replace with function body.

func _process(delta : float) -> void:
	var pos := Vector3.ZERO
	var rot := Vector3.ZERO
	
	#recoil rotation
	rotation_spring.damper = WeaponController.accuracy["Camera rotation damping"]
	rotation_spring.speed = WeaponController.accuracy["Camera rotation speed"]
	
	rotation_spring.positionvelocity(delta)
	rot += rotation_spring.position
	
	#recoil translation
	translation_spring.damper = WeaponController.accuracy["Camera translation damping"]
	translation_spring.speed = WeaponController.accuracy["Camera translation speed"]
	
	translation_spring.positionvelocity(delta)
	pos += translation_spring.position
	
	#camera movement sway
	rotation_sway_spring.damper = WeaponController.accuracy["Camera rotation sway damping"]
	rotation_sway_spring.speed = WeaponController.accuracy["Camera rotation sway speed"]
	
#	rotation_sway_spring.accelerate(Vector3(rotation_delta.x, rotation_delta.y, rotation_delta.z) * WeaponController.accuracy["Camera rotation sway"])
	rotation_sway_spring.positionvelocity(delta)
	rot += rotation_sway_spring.position
	
	transform.origin = pos
	rotation = rot

#		"Min camera rotation": Vector3(-.1, -.1, 0),
#		"Max camera rotation": Vector3(.2, .1, 0),

#		"Min camera translation": Vector3.ZERO,
#		"Max camera translation": Vector3(2, 2, 2),


func _on_Player_camera_movement(relative : Vector3) -> void:
	rotation_delta = relative


func _on_WeaponController_set_process(value : bool) -> void:
	set_process(value)
