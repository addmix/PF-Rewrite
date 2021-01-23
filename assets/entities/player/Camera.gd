extends Camera

var character : KinematicBody
var accuracy := {}

func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	
	call_deferred("deferred")

func deferred() -> void:
	character = get_parent().get_parent().get_parent().get_parent()
	
	set_process(true)
	set_physics_process(true)

#vars
var rotation_delta := Vector3.ZERO
var base_offset := transform.origin

#springs
var zoom_spring := Spring.new(1, 0, 1, .85, 12)
var rotation_spring := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, 0, 1)
var translation_spring := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, 0, 1)
var rotation_sway_spring := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, 0, 1)
var bob_intensity_spring := V3Spring.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, 0, 1)

func _process(delta : float) -> void:
	var pos := Vector3.ZERO
	var rot := Vector3.ZERO
	
	zoom_spring.target = accuracy["Magnification"]
	zoom_spring.positionvelocity(delta)
	
	set_fov(70 / zoom_spring.position)
	
	#recoil rotation
	rotation_spring.damper = accuracy["Camera rot d"]
	rotation_spring.speed = accuracy["Camera rot s"]
	
	rotation_spring.positionvelocity(delta)
	rot += rotation_spring.position
	
	#recoil pos
	translation_spring.damper = accuracy["Camera pos d"]
	translation_spring.speed = accuracy["Camera pos s"]
	
	translation_spring.positionvelocity(delta)
	pos += translation_spring.position
	
	#camera movement sway
	rotation_sway_spring.damper = accuracy["Camera rot sway d"]
	rotation_sway_spring.speed = accuracy["Camera rot sway s"]
	
#	rotation_sway_spring.accelerate(Vector3(rotation_delta.x, rotation_delta.y, rotation_delta.z) * WeaponController.accuracy["Camera rotation sway"])
	rotation_sway_spring.positionvelocity(delta)
	rot += rotation_sway_spring.position
	
	#camera walk sway
	bob_intensity_spring.damper = accuracy["Camera bob d"]
	bob_intensity_spring.speed = accuracy["Camera bob s"]
	bob_intensity_spring.target = accuracy["Camera bob i"]
	bob_intensity_spring.positionvelocity(delta)
	
	rot += Vector3(deg2rad(cos(character.walk_bob_tick)), deg2rad(sin(character.walk_bob_tick / 2)), 0) * bob_intensity_spring.position
	
	transform.origin = pos + base_offset
	rotation = rot

#update accuracy
func _on_Character_update_accuracy(new : Dictionary) -> void:
	accuracy = new

#update camera movement
func _on_Character_camera_movement(relative : Vector3) -> void:
	rotation_delta = relative

func _on_Character_shot_fired(aim : float, direction : Vector3) -> void:
	rotation_spring.accelerate(MathUtils.v3lerp(accuracy["Min camera rot force"], accuracy["Max camera rot force"], direction))
	translation_spring.accelerate(MathUtils.v3lerp(accuracy["Min camera pos force"], accuracy["Max camera pos force"], direction))
