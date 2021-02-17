extends Spatial
class_name Weapon

signal equipped
signal dequipped

#nodes
var character

onready var LeftIK : BoneAttachment = $Armature/Skeleton/HandIKL
onready var RightIK : BoneAttachment = $Armature/Skeleton/HandIKR

onready var GunMachine = $GunMachine
onready var ReloadMachine = $ReloadMachine
onready var FiremodeMachine = $FiremodeMachine
onready var EquipMachine = $EquipMachine
onready var AimMachine = $AimMachine

onready var _AnimationPlayer : AnimationPlayer = $AnimationPlayer

var WeaponController : Spatial

func _ready():
	#play idle animation
	_AnimationPlayer.call_deferred("play", "Ready")
	_connect_signals()

func _connect_signals() -> void:
	EquipMachine.connect("equipped", self, "on_equipped")
	EquipMachine.connect("dequipped", self, "on_dequipped")

#spring stuff
# warning-ignore:unused_argument
func _process(delta : float) -> void:
	var pos := Vector3.ZERO
	var rot := Vector3.ZERO
	
	pos += EquipMachine.EquipPosSpring.position
	rot += EquipMachine.EquipRotSpring.position
	
	transform.origin = pos
	rotation = rot

#takes care of weapon-side equip protocol
func equip() -> void:
	EquipMachine.change_state("Equip")

#takes care of weapon-side dequip protocol
func dequip() -> void:
	EquipMachine.change_state("Dequip")

func on_equipped() -> void:
	emit_signal("equipped", self)

func on_dequipped() -> void:
	emit_signal("dequipped", self)

func on_character_loaded(c) -> void:
	character = c
