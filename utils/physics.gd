extends Node

class Spring:
	var position : float = 0
	var velocity : float = 0
	var target : float = 0
	var damper : float = 0
	var speed : float = 1
	var mass : float = 1
	
	func _init(p : float, v : float, t : float, d : float, s : float):
		position = p
		velocity = v
		target = t
		damper = d
		speed = s
	
	#returns position, velocity
	func positionvelocity(delta):
		if damper > 1:
			return [position, velocity]
		if speed == 0:
			push_error("Speed == 0 on Spring")
		
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
		
		return [target + (direction * cosine + curve1 * sine) / e,
			speed * ((curve * curve1 - damper * direction) * cosine - (curve * direction + damper * curve1) * sine) / e]
	
	func apply_force(force):
		velocity += force / mass
	
# warning-ignore:shadowed_variable
	func accelerate(speed):
		velocity += speed

class V3Spring:
	var position := Vector3.ZERO
	var velocity := Vector3.ZERO
	var target := Vector3.ZERO
	var damper : float = 0
	var speed : float = 1
	var mass : float = 1
	
	func _init(p : Vector3, v : Vector3, t : Vector3, d: float, s: float):
		position = p
		velocity = v
		target = t
		damper = d
		speed = s
	
	#returns position, velocity
	func positionvelocity(delta : float):
		if damper > 1:
			return [position, velocity]
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
		
		return [target + (direction * cosine + curve1 * sine) / e,
			speed * ((curve * curve1 - damper * direction) * cosine - (curve * direction + damper * curve1) * sine) / e]
	
	func apply_force(force : Vector3):
		velocity += force / mass
	
# warning-ignore:shadowed_variable
	func accelerate(speed : Vector3):
		velocity += speed
