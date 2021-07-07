extends Spatial
#this will only do sway, wont do recoil


#object control


#nodes
#most variables will come from here
var held_object : HoldableObject

#arm values
var arm_mass : float = 1.0
var arm_strength : float = 10.0
var arm_damping : float = 0.7

#springs
var RotationSpring := V3Spring.new()
var PositionSpring := V3Spring.new()

#transforms
var desired_transform := Transform()
onready var default_transform : Transform = transform

#newtonian values
var last_head_movement := Vector2.ZERO
var head_movement := Vector2.ZERO

onready var last_transform : Transform = get_parent().get_global_transform()
var last_linear_velocity := Vector3.ZERO
var linear_velocity := Vector3.ZERO
var angular_velocity := Vector3.ZERO
var linear_acceleration := Vector3.ZERO
var angular_acceleration := Vector3.ZERO

#hold distances from CoM

func _physics_process(delta : float) -> void:
	calculate_newtonian_values(delta)
	
	calculate_springs(delta)
	
	#reset every frame, because it only is set on mouse movements
	last_head_movement = head_movement
	head_movement = Vector2.ZERO

func calculate_springs(delta : float) -> void:
	RotationSpring.damper = arm_damping
	PositionSpring.damper = arm_damping
	
	RotationSpring.target = desired_transform.basis.get_euler()
	PositionSpring.target = desired_transform.origin
	
	if held_object == null or !held_object is HoldableObject:
		RotationSpring.mass = arm_mass
		RotationSpring.speed = arm_strength
		
		PositionSpring.mass = arm_mass
		PositionSpring.speed = arm_strength
	else:
		#in local space
		var center_of_mass : Vector3 = held_object.transform.xform(held_object.center_of_mass)
		var mass : float = held_object.mass + arm_mass * center_of_mass.length()
		#in local space
		var hold_position : Vector3 = held_object.transform.xform(held_object.get_hold_position())
		var hold_strength : float = (held_object.get_hold_strength() + arm_strength) / (mass)
		
		RotationSpring.mass = mass
		RotationSpring.speed = hold_strength
		
		PositionSpring.mass = mass
		PositionSpring.speed = hold_strength
	
	RotationSpring.accelerate(Vector3(-angular_acceleration.y, angular_acceleration.x, 0.0))
	print(angular_acceleration.x)
	PositionSpring.accelerate(linear_acceleration)
	
	RotationSpring.positionvelocity(delta)
	PositionSpring.positionvelocity(delta)
	
	transform = default_transform * Transform(Basis(RotationSpring.position), PositionSpring.position)

func calculate_newtonian_values(delta : float) -> void:
	angular_velocity = Vector3(head_movement.y, -head_movement.x, 0) / delta
	var delta_head_movement : Vector2 = head_movement - last_head_movement
	angular_acceleration = Vector3(delta_head_movement.y, delta_head_movement.x, 0)
	linear_velocity = get_parent().global_transform.origin - last_transform.origin
	linear_acceleration = (linear_velocity - last_linear_velocity )
	
	last_linear_velocity = linear_velocity
	last_transform = get_parent().global_transform

func _on_Skeleton_movement(value : Vector2) -> void:
	head_movement += value

func on_body_moved(movement : float) -> void:
	RotationSpring.position.y += movement
