extends HoldableObject

var RotationSpring := V3Spring.new()
var PositionSpring := V3Spring.new()

func _physics_process(delta : float) -> void:
	RotationSpring.positionvelocity(delta)
	PositionSpring.positionvelocity(delta)

onready var bolt : SimulationCollider = $Simulator/SimulationSpace/Bolt

func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		shoot()

func shoot() -> void:
	bolt.accelerate(-50)
