extends Skeleton
class_name HumanoidSkeleton 

enum BodyEnum {HEAD, CHEST, WAIST, HIPS, BICEP, FOREARM, HAND, THIGH, SHIN, FOOT}

onready var parts := {
	"Head": $Head,
	"Chest": $Chest,
	"Waist": $Waist,
	"Hips": $Hips,
	"BicepL": $BicepL,
	"BicepR": $BicepR,
	"ForearmL": $ForearmL,
	"ForearmR": $ForearmR,
	"HandL": $HandL,
	"HandR": $HandR,
	"ThighL": $ThighL,
	"ThighR": $ThighR,
	"ShinL": $ShinL,
	"ShinR": $ShinR,
	"FootL": $FootL,
	"FootR": $FootR,
}

func _ready() -> void:
	for part in parts:
		part.connect("hit", self, "hit")

func hit(bullet, part : BodyPart) -> void:
	pass
