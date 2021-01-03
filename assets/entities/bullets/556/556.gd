extends Spatial
class_name Bullet

var weapon : Spatial
var velocity := Vector3.ZERO
onready var body : KinematicBody = $KinematicBody
var gravity : Vector3 = ProjectSettings.get("physics/3d/default_gravity") * ProjectSettings.get("physics/3d/default_gravity_vector")

func set_position(pos : Vector3) -> void:
	body.transform.origin = pos

func _physics_process(delta : float) -> void:
	velocity += gravity * delta
	
	#Get collision
	
	#do penetration stuff here
	
	#move
	velocity = body.move_and_slide(velocity)
	
