extends Spatial
class_name Weapon

#nodes
onready var LeftIK : BoneAttachment = $Armature/Skeleton/HandIKL
onready var RightIK : BoneAttachment = $Armature/Skeleton/HandIKR

onready var GunMachine = $GunMachine
onready var ReloadMachine = $ReloadMachine
onready var FiremodeMachine = $FiremodeMachine
onready var EquipMachine = $EquipMachine
onready var AimMachine = $AimMachine

onready var _AnimationPlayer : AnimationPlayer = $AnimationPlayer

var WeaponController : Spatial
