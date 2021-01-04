extends Spatial

var radius : float = 0.75
var stride_size := Vector3(0, .5, 1)

var character : KinematicBody
onready var WeaponController : Spatial = get_parent().get_node("Head/WeaponController")

onready var l : Spatial = $LSphere
onready var r : Spatial = $RSphere
onready var left : Position3D = $LSphere/LeftLeg
onready var right : Position3D = $RSphere/RightLeg

func _ready() -> void:
	set_physics_process(false)
	call_deferred("deferred")

func deferred() -> void:
	character = get_parent().get_parent().get_parent()
#	print(character.delta_pos)
	call_deferred("set_physics_process", true)

var distance := 0.0
func _physics_process(delta : float) -> void:
	var movement : Vector3 = character.RotationHelper.get_global_transform().basis.xform_inv(character.delta_pos)
	var tangent := Vector3(1, 0, 0)
	
	if movement.length() != 0 and movement.normalized().y != 1 and movement.normalized().y != -1:
		#get tangent on horizon
		tangent = MathUtils.intersect_planes(Vector3(0, 0, 0), movement.normalized(), Vector3(0, 0, 0), Vector3(0, 1, 0), Vector3(1, 1, 1))[1]
	
	#walk backwards
	distance += movement.length() * ((-1 * int(movement.z < 0)) + int(!movement.z < 0))
	
	var radians := deg2rad(distance / (2 * PI * radius) * 360)
	
	l.rotation.x = radians
	r.rotation.x = radians + deg2rad(270)
	left.rotation.x = -l.rotation.x + deg2rad(-90)
	right.rotation.x =  -r.rotation.x + deg2rad(-90)
	
	
	l.translation.y = radius
	r.translation.y = radius
	left.translation.z = -radius
	right.translation.z = radius
