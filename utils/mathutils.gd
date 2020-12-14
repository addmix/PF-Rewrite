extends Node

#used for gun sway, along with other things
static func fromaxisangle(v3 : Vector3) -> Basis:
	if v3.length() < .00001:
		return Basis()
	var m := pow(v3.x * v3.x + v3.y * v3.y + v3.z * v3.z, .5)
	var si := sin(m / 2) / m
	#quaternion
	return Basis(Quat(si * v3.x, si * v3.y, si * v3.z, cos(m/2)))

#Vector3 random range function
static func v3RandfRange(v1 : Vector3, v2 : Vector3) -> Vector3:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var x := rng.randf_range(v1.x, v2.x)
	rng.randomize()
	var y := rng.randf_range(v1.y, v2.y)
	rng.randomize()
	var z := rng.randf_range(v1.z, v2.z)
	
	return Vector3(x, y, z)

static func v3min(v1 : Vector3, v2 : Vector3) -> Vector3:
	return Vector3(min(v1.x, v2.x), min(v1.y, v2.y), min(v1.z, v2.z))

static func v3max(v1 : Vector3, v2 : Vector3) -> Vector3:
	return Vector3(max(v1.x, v2.x), max(v1.y, v2.y), max(v1.z, v2.z))

static func v3Bounds(vector : Vector3, lower : Vector3, upper : Vector3) -> Vector3:
	return v3max(v3min(vector, upper), lower)
