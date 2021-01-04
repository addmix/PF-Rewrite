extends Spatial
class_name Bullet

var weapon : Spatial
var velocity := Vector3.ZERO
var gravity : Vector3 = ProjectSettings.get("physics/3d/default_gravity") * ProjectSettings.get("physics/3d/default_gravity_vector")

onready var ray : RayCast = $RayCast

func _physics_process(delta : float) -> void:
	velocity += gravity * delta
	#drag
	
	
	#check move
	ray.cast_to = velocity * delta
	
	#get segments
	
	#go through segments in order
	
	transform.origin += velocity * delta
