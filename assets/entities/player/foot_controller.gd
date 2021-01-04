extends Spatial

var stride_size := Vector3(0, .5, 1)

var character : KinematicBody
onready var WeaponController : Spatial = get_parent().get_node("Head/WeaponController")

onready var left : Position3D = $LeftLeg
onready var right : Position3D = $RightLeg

func _ready() -> void:
	set_physics_process(false)
	call_deferred("deferred")

func deferred() -> void:
	character = get_parent().get_parent().get_parent()
	print(character.delta_pos)
	call_deferred("set_physics_process", true)

func _physics_process(delta : float) -> void:
	left.transform.origin = Vector3(-.6, sin(), cos()) * stride_size
	right.transform.origin = Vector3(.6, cos(), sin()) * stride_size

