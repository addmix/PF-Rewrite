extends Spatial
class_name Projectile

var weapon : Weapon
var player
var velocity := Vector3.ZERO
var gravity : Vector3 = ProjectSettings.get("physics/3d/default_gravity") * ProjectSettings.get("physics/3d/default_gravity_vector")

#created when instanced
var trail : Trail3D
var timer : Timer

var material : Material
var default_material = preload("res://assets/entities/projectiles/bullets/default_material.tres")

#when instanced
func _init() -> void:
	add_to_group("Projectiles")
	
	#trail
	trail = Trail3D.new()
	trail.length = 60
	trail.density_lengthwise = 4
	trail.density_around = 4
	trail.shape = 2
	
	if material:
		trail.set_material_override(material)
	else:
		trail.set_material_override(default_material)
	
	add_child(trail)
	#timer
	timer = Timer.new()
	timer.process_mode = 0
	timer.wait_time = 10
	timer.one_shot = true
	timer.autostart = true
# warning-ignore:return_value_discarded
	timer.connect("timeout", self, "on_timeout")
	add_child(timer)

func _physics_process(delta : float) -> void:
	velocity += gravity * delta
	#aerodynamic drag
	
	var space_state = get_world().direct_space_state
	
	#we are going to rewrite my old penetration algorithm to not be aids
	#check move
	var result : Dictionary = space_state.intersect_ray(transform.origin, transform.origin + velocity, [], 5, true, true)
	
	
	#get segments
	
	#go through segments in order
	
	#if object to hit
	if result.size() > 0:
		#check for hit method
		if result["collider"].has_method("hit"):
			result["collider"].hit(self)
		if result["collider"].get_class() == "BodyPart":
			player.connect_hit()
	
	transform.origin += velocity * delta

func on_timeout() -> void:
	queue_free()
