extends Spatial
class_name HoldableObject

export var mass := 1.0
#gun center of mass
#for each object:
#total += obj.position * obj.mass
#center of mass = total / n
export var center_of_mass := Vector3.ZERO
#gun moment of inertia https://en.wikipedia.org/wiki/Moment_of_inertia
#basically leverage distance, need to find balance between distance from axis/mass
#A solid sphere rotating on an axis that goes through the center of the sphere, with mass M and radius R, has a moment of inertia determined by the formula:
#I = (2/5) MR 2
export var moment_of_inertia := Vector3.ZERO
#stock length/ hold distance
export var held_position := Vector3.ZERO
#position of where the object is being held against the body
export var brace_position := Vector3.ZERO
var object_braced := false
#where the object is held
export var left_grip_position := Vector3.ZERO
export var right_grip_position := Vector3.ZERO

export var left_grip_strength := 1.0
export var right_grip_strength := 1.0

#if the hand is gripping or not
var left_gripped := true
var right_gripped := true

func get_hold_position() -> Vector3:
	return left_grip_position * left_grip_strength * float(left_gripped) + right_grip_position * right_grip_strength * float(right_gripped)

func get_hold_strength() -> float:
	return left_grip_strength * float(left_gripped) + right_grip_strength * float(right_gripped)
