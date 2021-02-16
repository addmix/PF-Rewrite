extends Area

func hit(bullet) -> void:
	get_parent().hit(bullet)
