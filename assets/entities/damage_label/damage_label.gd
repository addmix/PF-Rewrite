extends Spatial

var velocity := Vector3.ZERO setget set_velocity, get_velocity
export(float) var linear_velocity := 9.0
export(float, 0, 1) var damping := 5

#onready var label = $Label3D

func _ready() -> void:
	add_to_group("DamageLabels")
#	label.set_billboard(true)
	velocity = MathUtils.v3RandfRange(Vector3(-1, 0, -1), Vector3(1, 2, 1))
	velocity = velocity.normalized() * linear_velocity

# warning-ignore:unused_argument
func set_text(text : String) -> void:
	pass
#	label.text = text


func set_velocity(new : Vector3) -> void:
	velocity = new

func get_velocity() -> Vector3:
	return velocity

func _process(delta : float) -> void:
	transform.origin += velocity * delta
	velocity *= (1 - damping * delta)
	
	if velocity.length() <= .01:
		queue_free()
