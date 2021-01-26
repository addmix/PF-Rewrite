extends Spatial

#signals
# warning-ignore:unused_signal
signal ammoChanged
signal shotFired

signal equipped
signal dequipped

#nodes
onready var LeftIK : BoneAttachment = $Armature/Skeleton/HandIKL
onready var RightIK : BoneAttachment = $Armature/Skeleton/HandIKR

onready var GunMachine = $GunMachine
onready var ReloadMachine = $ReloadMachine
onready var EquipMachine = $EquipMachine
onready var AimMachine = $AimMachine

#onready var _AnimationPlayer : AnimationPlayer = $AnimationPlayer

var WeaponController : Spatial

#effects
var bullet = preload("res://assets/entities/bullets/556/556.tscn")
var muzzle_flash = preload("res://assets/particles/m4a1_muzzle_flash.tscn")

func _ready():
	#play idle animation
#	_AnimationPlayer.call_deferred("play", "Ready")
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

func get_aim() -> Transform:
	return AimMachine.get_aim()

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

func _on_M4A1_shotFired():
	#muzzle flash
	var instance
	
#	 instance = muzzle_flash.instance()
#	$Barrel.add_child(instance)
	
	#bullet
	instance = bullet.instance()
	instance.transform.origin = $Barrel.get_global_transform().origin
	instance.velocity = data["Ballistics"]["Velocity"] * -$Barrel.get_global_transform().basis.z
	$"/root".add_child(instance)


export var data := {
	"Misc": {
		"Name": "P38",
		"Ammo type": "9x19mm Parabellum",
		"Manufacturer": "Walther",
		"Category": "Pistols",
		"Description": "The Walther P38 was the cheap and rugged successor to the Luger Pistole Parabellum. The P38 introduced groundbreaking technical features which are still in use today.",
		
		"Chamber": 1,
		"Magazine": 8,
		"Reserve": 40,
		
		"Path": "res://assets/weapons/pistols/p38",
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
		"Equip rot": Vector3(-.7, 1, 0),
		
		"Dequip s": float(12.0),
		"Dequip d": float(.8),
		
		"Dequip pos": Vector3(0, -1.5, 0),
		"Dequip rot": Vector3(0, 0, 0),
		
		"Aim s": float(15.0),
		"Aim d": float(.8),
		
		"Breath s": float(3.0),
		"Breath d": float(.99999),
		
		"Air s": float(6.0),
		"Air d": float(.8),
		
		"Sprint s": float(8.0),
		"Sprint d": float(.99),
		
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
		"Min pos force": Vector3(-1.2, 2.4, 5.5),
		"Max pos force": Vector3(1.6, 3.2, 7.0),
		"Min rot force": Vector3(6.0, -2.8, 0),
		"Max rot force": Vector3(8.8, 6, 0),
		
		#recoil spring settings
		"Recoil pos s": float(14.0),
		"Recoil pos d": float(.6),
		
		"Recoil rot s": float(19.0),
		"Recoil rot d": float(.5),
		
		
		#sway
		
		
		"Camera rot sway": Vector3(.005, .005, 0),
		"Camera rot sway s": float(5.0),
		"Camera rot sway d": float(.8),
		
		"Camera bob s": float(8),
		"Camera bob d": float(.85),
		"Camera bob i": Vector3(.2, .2, .2),
		
		"Pos sway": Vector3(.1, .1, 0),
		"Pos sway s": float(14.0),
		"Pos sway d": float(.6),
		
		"Rot sway": Vector3(.04, .04, 0),
		"Rot sway s": float(12.0),
		"Rot sway d": float(.7),
		
		"Accel sway s": float(6.5),
		"Accel sway d": float(.9),
		"Accel sway pos i": Vector3(.004, .004, .002),
		"Accel sway rot i": Vector3(.003, .0035, .002),
		"Accel sway offset": Vector3(0, 0, -1.2),
		
		"Breath sway s": float(3),
		"Breath sway pos i": Vector3(0.002, 0.002, 0.002),
		"Breath sway rot i": Vector3(0.002, 0.002, 0.002),
		
		#walk
		
		
		"Walkspeed": float(10.0),
		"Walk s": float(8.0),
		"Walk d": float(0.999),
		
		"Gun bob s": float(0),
		"Gun bob pos i": Vector3(0, 0, 0),
		"Gun bob rot i": Vector3(0, 0, 0),
		
		#reload
		"Reload s": float(7.0),
		"Reload d": float(0.6),
		
		
		#camera magnification
		"Magnification": float(1.0),
		"Spread factor": float(0),
		"Choke": float(0),
		
		#sight change speed
		"Sight swap s": float(12),
		"Sight swap d": float(.875),
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
	"Breath": {
		
	},
	"Sprint" : {
		"Pos": Vector3(-.3, -.3, 0),
		"Rot": Vector3(-.4, .4, 0),
	},
	"Movement" : {
		"Gun bob s": float(1.07),
		"Gun bob pos i": Vector3(.0025, .001, .003),
		"Gun bob rot i": Vector3(.002, .002, .01),
	},
	"Accel" : {
		
	},
	"Reload" : {
		"Pos": Vector3(0, .2, 0),
		"Rot": Vector3(.9, .2, -.3),
	},
	"Crouch" : {
		"Rot": Vector3(0, 0, .4),
	},
	"Prone" : {
		"Pos": Vector3(0, 0, .2),
		"Rot": Vector3(0, 0, 1.3),
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
		"Walkspeed": float(1.0),
		"Walk s": float(10.0),
		"Walk d": float(0.999),
		"Gun bob s": float(0.005),
		"Gun bob pos i": Vector3(0.3, 0.3, 0.5),
		"Gun bob rot i": Vector3(1, 0.05, 0.5),
	},
	"Aim" : {
		"Recoil pos s": float(1.3),
		"Recoil rot s": float(1.3),
		
		"Pos sway": Vector3(.1, .1, 1),
		"Rot sway": Vector3(.5, .5, 1),
		"Rot sway d": float(.65),
		
		"Pos": Vector3(0, 0, 0),
		"Rot": Vector3(0, 0, 0),
		
		"Min camera rot force": Vector3(1.5, 1, 1),
		"Max camera rot force": Vector3(1.5, 1, 1),
		
		"Min pos force": Vector3(.1, .3, .3),
		"Max pos force": Vector3(.1, .3, .3),
		"Min rot force": Vector3(.6, .3, 1),
		"Max rot force": Vector3(.4, .3, 1),
		
		"Accel sway s": float(1.3),
		"Accel sway pos i": Vector3(.2, .2, .4),
		"Accel sway rot i": Vector3(.6, .6, .8),
		
		"Gun bob pos i": Vector3(.12, .12, .1),
		"Gun bob rot i": Vector3(.12, .15, .1),
	},
	"Breath": {
		"Magnification": float(1.1),
		"Breath s": float(2),
		"Breath sway pos i": Vector3(0, 0, 0),
		"Breath sway rot i": Vector3(0, 0, 0),
	},
	"Sprint" : {
		"Walkspeed": float(1.8),
	},
	"Movement" : {
		"Gun bob pos i": Vector3(1.04, 1.04, 1.05),
		"Gun bob rot i": Vector3(1.07, 1.1, 1.1),
	},
	"Accel" : {
		
	},
	"Reload" : {
		"Gun bob s": float(1.3),
		"Gun bob pos i": Vector3(1, 1, 1),
		"Gun bob rot i": Vector3(0.5, 0.5, 0.5),
		
	},
	"Crouch" : {
		"Walkspeed": float(0.6),
	},
	"Prone" : {
		"Walkspeed": float(0.3),
		
		"Gun bob pos i": Vector3(3, 7, 3),
		"Gun bob rot i": Vector3(0.5, 0.5, 0.5),
	},
	"Mounted": {
		
	},
}
