extends BoneAttachment
class_name BodyPart

enum BodyEnum {HEAD, CHEST, WAIST, HIPS, BICEP, FOREARM, HAND, THIGH, SHIN, FOOT}

signal hit

export(BodyEnum) var body_enum = 0

onready var area : Area = $Area

func hit(bullet) -> void:
	emit_signal("hit", bullet, self)
