extends HoldableObject

var RotationSpring := V3Spring.new()
var PositionSpring := V3Spring.new()

func _physics_process(delta : float) -> void:
	RotationSpring.positionvelocity(delta)
	PositionSpring.positionvelocity(delta)

onready var bolt : SimulationCollider = $Simulator/CycleSpace/Bolt
onready var hammer : SimulationCollider = $Simulator/HammerSpace/Hammer

var trigger : float = 0.0

func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		shoot()
	
	elif event.is_action_pressed("aim"):
		trigger = 1.0
	elif event.is_action_released("aim"):
		trigger = 0.0

func shoot() -> void:
	bolt.velocity = -6.9
