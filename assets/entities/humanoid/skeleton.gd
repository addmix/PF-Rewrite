extends Skeleton
class_name HumanoidSkeleton 

signal hit
signal movement

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


#settings


var invert_x : bool = ProjectSettings.get_setting("controls/camera/invert_x")
var invert_y : bool = ProjectSettings.get_setting("controls/camera/invert_y")
var camera_sensitivity : Vector2 = ProjectSettings.get_setting("controls/mouse/sensitivity") * Vector2(-1.0 * float(invert_x) + float(!invert_x), -1.0 * float(invert_y) + float(!invert_y))

func settings_changed() -> void:
	invert_x = ProjectSettings.get_setting("controls/invert_x")
	invert_y = ProjectSettings.get_setting("controls/invert_y")
	camera_sensitivity = ProjectSettings.get_setting("controls/mouse/sensitivity") * Vector2(-1.0 * float(invert_x) + float(!invert_x), -1.0 * float(invert_y) + float(!invert_y))
	
	

func _ready() -> void:
	#when settings are changed, the game will reload settings on instances
	Settings.connect("load_settings", self, "settings_changed")
	#when the camera is moved, call this func
#	connect("movement", self, "move_head")
	
	for part in parts:
		parts[part].connect("hit", self, "hit")

func _process(delta : float) -> void:
	update_movement()

func _physics_process(delta : float) -> void:
	pass

var is_controlling := false

func _unhandled_input(event : InputEvent) -> void:
	if !is_network_master() or !is_controlling:
		return
	
	if event is InputEventMouseMotion:
		move_head(event.relative * camera_sensitivity)
		get_tree().set_input_as_handled()



#ik stuff



#called in _ready
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


#damage stuff


func hit(projectile : Projectile, part : BodyPart) -> void:
	emit_signal("hit", projectile, part)


#movement stuff


#this is for positioning the gun
onready var ObjectController : Spatial = $ChestAttachment/Armpit

#get bone id at runtime to avoid ID errors
onready var head_id : int = find_bone("head")
onready var body_id : int = find_bone("spine.001")

#values for body/head rotation
var body_rotation_offset := 0.35
var head_rotation := Vector2.ZERO
var max_x := 0.35
var max_y := 1.4
var body_rotation := 0.0

#desired transforms
var desired_head_transform : Transform = Transform()
var desired_body_transform : Transform = Transform()
var desired_armpit_transform : Transform = Transform()

var head_transform : Transform = Transform()
var body_transform : Transform = Transform()
var armpit_transform : Transform = Transform()

#called in _unhandled_input
func move_head(movement := Vector2.ZERO) -> void:
	#desired head movement
	#change the 0.01 to mouse sensitivity
	var new_head_rotation : Vector2 = head_rotation + movement
	var difference : Vector2 = new_head_rotation - head_rotation
	#limit head movement
	head_rotation = Vector2(min(max(-max_x, new_head_rotation.x), max_x), min(max(-max_y, new_head_rotation.y), max_y))
	#get difference in desired head movement and limited head movement
	
	#rotate body by difference
	#try to make a smooth difference between the two
	body_rotation += difference.x
	
	desired_head_transform = Transform(Basis(Vector3(head_rotation.y, -head_rotation.x + body_rotation_offset, 0)), Vector3.ZERO)
	desired_body_transform = Transform(Basis(Vector3(0, -body_rotation - body_rotation_offset, 0)), Vector3.ZERO)
	desired_armpit_transform = head_transform
	
	ObjectController.on_body_moved(difference.x)
	emit_signal("movement", Vector2(difference.y, -movement.x))

#called in _process
func update_movement() -> void:
	desired_armpit_transform = head_transform
	head_transform = desired_head_transform
	#we will change this eventually
	body_transform = desired_body_transform
	
	set_bone_pose(head_id, head_transform)
	set_bone_pose(body_id, body_transform)
	
	#set object controller desired position
	ObjectController.desired_transform = desired_armpit_transform
	
