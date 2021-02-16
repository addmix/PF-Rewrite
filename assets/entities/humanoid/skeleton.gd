extends Skeleton
class_name HumanoidSkeleton 

signal hit

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
		parts[part].connect("hit", self, "hit")

func setup_ik() -> Array:
	var IKs := []
	
	#left hand
	var ik : SkeletonIK = SkeletonIK.new()
	ik.root_bone = "shoulder_l"
	ik.tip_bone = "hand_l"
	ik.name = "LeftHandIK"
	add_child(ik, true)
	IKs.append(ik)
	#right hand
	ik = SkeletonIK.new()
	ik.root_bone = "shoulder_r"
	ik.tip_bone = "hand_r"
	ik.name = "RightHandIK"
	add_child(ik, true)
	IKs.append(ik)
	#left leg
	ik = SkeletonIK.new()
	ik.root_bone = "thigh_l"
	ik.tip_bone = "toe_l"
	ik.name = "LeftLegIK"
	add_child(ik, true)
	IKs.append(ik)
	#right leg
	ik = SkeletonIK.new()
	ik.root_bone = "thigh_r"
	ik.tip_bone = "toe_r"
	ik.name = "RightLegIK"
	add_child(ik, true)
	IKs.append(ik)
	
	return IKs

func hit(projectile : Projectile, part : BodyPart) -> void:
	emit_signal("hit", projectile, part)
