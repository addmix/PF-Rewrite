extends BoneAttachment
class_name BodyPart

signal hit

export(HumanoidSkeleton.BodyEnum) var body_enum = 0

onready var area : Area = $Area

func hit(bullet) -> void:
	emit_signal("hit", bullet, self)
