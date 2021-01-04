extends Camera

#nodes
onready var player = get_parent().get_parent().get_parent().get_parent()
onready var WeaponController = get_parent().get_node("WeaponController")

#vars
var rotation_delta := Vector3.ZERO
var base_offset := transform.origin

#springs
var zoom_spring := Spring.new(1, 0, 1, .85, 12)
var rotation_spring := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, 0, 1)
var translation_spring := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, 0, 1)
var rotation_sway_spring := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, 0, 1)
var bob_intensity_spring := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, 0, 1)

# warning-ignore:unused_argument
func _on_WeaponController_shot_fired(aim : float) -> void:
	rotation_spring.accelerate(MathUtils.v3RandfRange(WeaponController.accuracy["Min camera rotation force"], WeaponController.accuracy["Max camera rotation force"]))
	translation_spring.accelerate(MathUtils.v3RandfRange(WeaponController.accuracy["Min camera pos force"], WeaponController.accuracy["Max camera pos force"]))

func _process(delta : float) -> void:
	var pos := Vector3.ZERO
	var rot := Vector3.ZERO
	
	zoom_spring.target = WeaponController.accuracy["Magnification"]
	zoom_spring.positionvelocity(delta)
	
	set_fov(70 / zoom_spring.position)
	
	#recoil rotation
	rotation_spring.damper = WeaponController.accuracy["Camera rot d"]
	rotation_spring.speed = WeaponController.accuracy["Camera rot s"]
	
	rotation_spring.positionvelocity(delta)
	rot += rotation_spring.position
	
	#recoil pos
	translation_spring.damper = WeaponController.accuracy["Camera pos d"]
	translation_spring.speed = WeaponController.accuracy["Camera pos s"]
	
	translation_spring.positionvelocity(delta)
	pos += translation_spring.position
	
	#camera movement sway
	rotation_sway_spring.damper = WeaponController.accuracy["Camera rot sway d"]
	rotation_sway_spring.speed = WeaponController.accuracy["Camera rot sway s"]
	
#	rotation_sway_spring.accelerate(Vector3(rotation_delta.x, rotation_delta.y, rotation_delta.z) * WeaponController.accuracy["Camera rotation sway"])
	rotation_sway_spring.positionvelocity(delta)
	rot += rotation_sway_spring.position
	
	#camera walk sway
	bob_intensity_spring.damper = WeaponController.accuracy["Camera bob d"]
	bob_intensity_spring.speed = WeaponController.accuracy["Camera bob idle s"] + (WeaponController.accuracy["Camera bob s"] * player.player_velocity.length())
	bob_intensity_spring.target = WeaponController.accuracy["Camera bob idle i"] + (WeaponController.accuracy["Camera bob i"] * player.player_velocity.length())
	bob_intensity_spring.positionvelocity(delta)
	
	rot += Vector3(deg2rad(cos(WeaponController.walk_bob_tick)), deg2rad(sin(WeaponController.walk_bob_tick / 2)), 0) * bob_intensity_spring.position
	
	
	
	transform.origin = pos + base_offset
	rotation = rot

func _on_Player_camera_movement(relative : Vector3) -> void:
	rotation_delta = relative


func _on_WeaponController_set_process(value : bool) -> void:
	set_process(value)


# warning-ignore:unused_argument
func _on_WeaponController_weapon_changed(weapon):
	pass # Replace with function body.
