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


var body_rotation_offset := 0.35
var head_rotation := Vector2.ZERO
var max_x := 0.35
var max_y := 1.4

var body_rotation := 0.0

#this is for positioning the gun
onready var Armpit : Spatial = $ChestAttachment/Armpit
onready var ArmpitTransform : Transform = Armpit.get_transform()

#get bone id at runtime to avoid ID errors
onready var head_id : int = find_bone("head")
onready var spine_id : int = find_bone("spine.001")

func move_head(movement := Vector2.ZERO) -> void:
	#desired head movement
	#change the 0.01 to mouse sensitivity
	var new_head_rotation : Vector2 = head_rotation + movement * 0.01
	#limit head movement
	head_rotation = Vector2(min(max(-max_x, new_head_rotation.x), max_x), min(max(-max_y, new_head_rotation.y), max_y))
	#get difference in desired head movement and limited head movement
	var difference : Vector2 = new_head_rotation - head_rotation
	#rotate body by difference
	#try to make a smooth difference between the two
	body_rotation += difference.x
	
	var working_head_transform : Transform = Transform(Basis(Vector3(head_rotation.y, -head_rotation.x + body_rotation_offset, 0)), Vector3.ZERO)
	var working_body_transform : Transform = Transform(Basis(Vector3(0, -body_rotation - body_rotation_offset, 0)), Vector3.ZERO)
	
	set_bone_custom_pose(spine_id, working_body_transform)
	set_bone_custom_pose(head_id, working_head_transform)
	
	#gun/chest stuff
	Armpit.transform = ArmpitTransform * Transform(Basis(Vector3(head_rotation.y, -head_rotation.x + body_rotation_offset, 0)), Vector3.ZERO)

