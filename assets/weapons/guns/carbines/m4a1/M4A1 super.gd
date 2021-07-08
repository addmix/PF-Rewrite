extends HoldableObject

var RotationSpring := V3Spring.new()
var PositionSpring := V3Spring.new()

func _physics_process(delta : float) -> void:
	RotationSpring.positionvelocity(delta)
	PositionSpring.positionvelocity(delta)
