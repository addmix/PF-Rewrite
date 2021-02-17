extends Area
class_name BodyPartArea

func hit(bullet) -> void:
	get_parent().hit(bullet)

func get_class() -> String:
	return "BodyPart"
