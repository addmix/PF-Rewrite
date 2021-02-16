extends KinematicBody

func hit(bullet, part : BodyPart) -> void:
	pass

func calculate_damage(bullet, part : BodyPart) -> float:
	var damage : float = 30.0
	return damage
