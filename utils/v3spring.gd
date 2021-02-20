extends Resource

class_name V3Spring

var position := Vector3.ZERO
var velocity := Vector3.ZERO
var target := Vector3.ZERO
var damper : float = 0
var speed : float = 1
var mass : float = 1

#base funcs
func _init(p : Vector3, v : Vector3, t : Vector3, d: float, s: float) -> void:
	position = p
	velocity = v
	target = t
	damper = d
	speed = s

func get_class() -> String:
	return "V3Spring"


#physics funcs
func positionvelocity(delta : float) -> void:
	if damper > 1:
		return
	if speed == 0:
		push_error("Speed == 0 on V3Spring")
	
	var direction = position - target
	
	#round curve
	var curve = pow(1 - pow(damper, 2), .5)
	
	#weird exponetial thingy
	var curve1 = (velocity / speed + damper * direction) / curve
	
	#hanging rope
	var cosine = cos(curve * speed * delta)
	
	#deflated bubble
	var sine = sin(curve * speed * delta)
	
	var e = pow(2.718281828459045, damper * speed * delta)
	
	position = target + (direction * cosine + curve1 * sine) / e
	velocity = speed * ((curve * curve1 - damper * direction) * cosine - (curve * direction + damper * curve1) * sine) / e

func apply_force(f : Vector3) -> void:
	velocity += f / mass

func accelerate(s : Vector3) -> void:
	velocity += s


#networking


func get_networking() -> Array:
	return [position, velocity, target]

func set_networking(a : Array) -> void:
	position = a[0]
	velocity = a[1]
	target = a[2]

func check_discrepancy(s : V3Spring, d : float) -> bool:
	return (position - s.position).length() < d
