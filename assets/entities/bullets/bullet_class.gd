extends Spatial
class_name Bullet

var weapon : Spatial
var velocity := Vector3.ZERO
var gravity : Vector3 = ProjectSettings.get("physics/3d/default_gravity") * ProjectSettings.get("physics/3d/default_gravity_vector")

#created when instanced
var ray : RayCast
var trail : Trail3D
var timer : Timer

var material = preload("res://assets/entities/bullets/default_material.tres")

#when instanced
func _init() -> void:
	#raycast
	ray = RayCast.new()
	ray.enabled = true
	ray.collide_with_areas = true
	add_child(ray)
	#trail
	trail = Trail3D.new()
	trail.length = 60
	trail.density_lengthwise = 4
	trail.density_around = 4
	trail.shape = 2
	trail.set_material_override(material)
	add_child(trail)
	#timer
	timer = Timer.new()
	timer.process_mode = 0
	timer.wait_time = 10
	timer.one_shot = true
	timer.autostart = true
	add_child(timer)

#when added to tree
func _ready() -> void:
	pass

func _physics_process(delta : float) -> void:
	velocity += gravity * delta
	#aerodynamic drag
	
	
	
	#we are going to rewrite my old penetration algorithm to not be aids
	#check move
	ray.cast_to = velocity * delta
	
	#get segments
	
	#go through segments in order
	
	transform.origin += velocity * delta

func _on_Timer_timeout() -> void:
	queue_free()
