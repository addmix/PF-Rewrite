extends Spatial

#signals
# warning-ignore:unused_signal
signal ammoChanged
signal shotFired

signal equipped
signal dequipped

#nodes
onready var aim_node : Position3D = $Aim
onready var LeftIK : BoneAttachment = $Armature/Skeleton/HandIKL
onready var RightIK : BoneAttachment = $Armature/Skeleton/HandIKR

onready var GunMachine = $GunMachine
onready var ReloadMachine = $ReloadMachine
onready var FiremodeMachine = $FiremodeMachine
onready var EquipMachine = $EquipMachine

onready var _AnimationPlayer : AnimationPlayer = $AnimationPlayer

#effects
var bullet = preload("res://assets/entities/bullets/556/556.tscn")
var muzzle_flash = preload("res://assets/particles/m4a1_muzzle_flash.tscn")

var base_offset := Vector3.ZERO

func _ready():
	base_offset = transform.origin
	#play idle animation
	_AnimationPlayer.call_deferred("play", "Ready")
	#initializes ammo data for any interested nodes
	call_deferred("emit_signal", "ammoChanged", chamber, magazine, reserve)
	_connect_signals()

func _connect_signals() -> void:
	EquipMachine.connect("equipped", self, "on_equipped")
	EquipMachine.connect("dequipped", self, "on_dequipped")

#properties
onready var chamber : int = data["Misc"]["Chamber"] setget set_chamber, get_chamber
func set_chamber(value : int) -> void:
	chamber = value
	if is_network_master():
		emit_signal("ammoChanged", get_chamber(), get_magazine(), get_reserve())
func get_chamber() -> int:
	return chamber

onready var magazine : int = data["Misc"]["Magazine"] setget set_magazine, get_magazine
func set_magazine(value : int) -> void:
	magazine = value
	if is_network_master():
		emit_signal("ammoChanged", get_chamber(), get_magazine(), get_reserve())
func get_magazine() -> int:
	return magazine

onready var reserve : int = data["Misc"]["Reserve"] setget set_reserve, get_reserve
func set_reserve(value : int) -> void:
	reserve = value
	if is_network_master():
		emit_signal("ammoChanged", get_chamber(), get_magazine(), get_reserve())
func get_reserve() -> int:
	return reserve

func can_reload() -> bool:
	return magazine < data["Misc"]["Magazine"]

#spring stuff
# warning-ignore:unused_argument
func _process(delta : float) -> void:
	var pos := Vector3.ZERO
	var rot := Vector3.ZERO
	
	pos += EquipMachine.EquipPosSpring.position
	rot += EquipMachine.EquipRotSpring.position
	
	transform.origin = pos + base_offset
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

func _on_M4A1_shotFired():
	#muzzle flash
	var instance = muzzle_flash.instance()
	$Barrel.add_child(instance)
	
	#bullet
	instance = bullet.instance()
	instance.set_position($Barrel.get_global_transform().origin)
	instance.velocity = get_parent().get_linear_velocity()
	$".".add_child(instance)


export var data := {
	"Misc": {
		"Name": "M4A1",
		"Ammo type": "5.56x45mm NATO",
		"Manufacturer": "Colt",
		"Category": "Assault rifles",
		"Description": "The Colt M4A1 is a firearm based off of Eugene Stoner's Armalite 15. Adopted by the US military in 1994 to replace the M16.",
		
		"Chamber": int(1),
		"Magazine": int(30),
		"Reserve": int(120),
		
		"Path": "res://Assets/Weapons/Carbines/M4A1/",
	},
	"Ballistics": {
		"Head multiplier": float(1.5),
		"Torso multipler": float(1.0),
		"Limb multiplier": float(.8),
		
		"Damage range": Vector2(40, 90),
		"Damage": Vector2(32, 24),
		
		"Velocity": float(2200.0),
		"Velocity variance": float(100.0),
		
		"Penetration depth": float(0),
		
		"Suppression": float(0),
		"Suppression distance": float(0),
		
		"Firerate": float(0),
		"Firerate variance": float(0),
	},
	"Weapon handling": {
		
		
		#state springs
		
		
		"Equip s": float(10.0),
		"Equip d": float(.8),
		
		"Equip pos": Vector3(0, -1.5, 0),
		"Equip rot": Vector3(-.7, 0, 0),
		
		"Dequip s": float(12.0),
		"Dequip d": float(.8),
		
		"Dequip pos": Vector3(0, -1.5, 0),
		"Dequip rot": Vector3(0, 0, 0),
		
		"Aim s": float(15.0),
		"Aim d": float(.8),
		
		"Sprint s": float(8.0),
		"Sprint d": float(.99),
		
#		"Sprint pos": Vector3(-.3, -.3, 0),
#		"Sprint rot": Vector3(-.76, 1.2, 0),
		
		"Move s": float(6.0),
		"Move d": float(.99),
		
		"Crouch s": float(10.0),
		"Crouch d": float(.99),
		
		"Prone s": float(10.0),
		"Prone d": float(.99),
		
		"Mount s": float(12.0),
		"Mount d": float(.99),
		
		
		#camera
		
		
		#rotation
		"Camera rot d": float(.8),
		"Camera rot s": float(10.0),
		
		"Min camera rot": Vector3(-.1, -.1, 0),
		"Max camera rot": Vector3(.2, .1, 0),
		"Min camera rot force": Vector3(.1, 0, 0),
		"Max camera rot force": Vector3(.3, 0, 0),
		
		#translation
		"Camera pos d": float(.8),
		"Camera pos s": float(10.0),
		
		"Min camera pos": Vector3.ZERO,
		"Max camera pos": Vector3(2, 2, 2),
		"Min camera pos force": Vector3.ZERO,
		"Max camera pos force": Vector3.ZERO,
		
		
		
		#position
		"Pos": Vector3(0, 0, 0),
		"Rot": Vector3(0, 0, 0),
		
		#total bounds
		"Min pos": Vector3(-.75, -.75, 0),
		"Max pos": Vector3(.5, .5, 2.0),
		"Min rot": Vector3(-2, -2, -2),
		"Max rot": Vector3(2, 2, 2),
		
		
		#recoil
		
		
		#force
		"Min pos force": Vector3(-1.2, .2, 2.5),
		"Max pos force": Vector3(1.6, 1.2, 4.0),
		"Min rot force": Vector3(.4, -1.2, 0),
		"Max rot force": Vector3(1.0, 1.4, 0),
		
		#recoil spring settings
		"Recoil pos s": float(13.0),
		"Recoil pos d": float(.7),
		
		"Recoil rot s": float(13.0),
		"Recoil rot d": float(.7),
		
		
		#sway
		
		
		"Camera rot sway": Vector3(.005, .005, 0),
		"Camera rot sway s": float(5.0),
		"Camera rot sway d": float(.8),
		
		"Camera bob s": float(0.1),
		"Camera bob d": float(.9),
		"Camera bob i": Vector3(.01, .01, .01),
		
		"Pos sway": Vector3(.1, .1, 0),
		"Pos sway s": float(14.0),
		"Pos sway d": float(.6),
		
		"Rot sway": Vector3(.04, .04, 0),
		"Rot sway s": float(12.0),
		"Rot sway d": float(.7),
		
		"Accel sway s": float(8.0),
		"Accel sway d": float(.9),
		"Accel sway i": Vector3(.003, .004, .0005),
		"Accel sway offset": Vector3(0, 0, -1.2),
		
		
		#walk
		
		
		"Walkspeed": float(12.0),
		"Walk s": float(8.0),
		"Walk d": float(0.99),
		
		"Gun bob s": float(.1),
		"Gun bob pos i": Vector3(.02, .01, .001),
		"Gun bob rot i": Vector3(.02, .02, .01),
		
		#camera magnification
		"Magnification": float(1.0),
		"Spread factor": float(0),
		"Choke": float(0),
	},
}

var add := {
	#modifier states
	"Equip": {
		
	},
	"Dequip": {
		
	},
	"Air" : {
		
	},
	"Aim" : {
		
	},
	"Sprint" : {
		"Pos": Vector3(-.3, -.3, 0),
		"Rot": Vector3(-.76, 1.2, 0),
	},
	"Movement" : {
		
	},
	"Accel" : {
		
	},
	"Reload" : {
		
	},
	"Crouch" : {
		
	},
	"Prone" : {
		
	},
	"Mounted": {
		
	},
}

var multi := {
	"Equip": {
		
	},
	"Dequip": {
		
	},
	"Air" : {
		
	},
	"Aim" : {
		"Gun bob pos i": Vector3(.1, .1, .1),
		"Gun bob rot i": Vector3(.1, .1, .1),
	},
	"Sprint" : {
		"Walkspeed": float(1.3),
	},
	"Movement" : {
		"Gun bob pos i": Vector3(1.2, 1.2, 1.1),
		"Gun bob rot i": Vector3(1.1, 1.1, 1.1),
		"Gun bob s": float(10),
	},
	"Accel" : {
		
	},
	"Reload" : {
		
	},
	"Crouch" : {
		
	},
	"Prone" : {
		
	},
	"Mounted": {
		
	},
}
