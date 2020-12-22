extends Spatial

signal ammoChanged
signal shotFired

signal equipped
signal dequipped

onready var aim_node : Position3D = $Aim
onready var LeftIK : BoneAttachment = $Armature/Skeleton/HandIKL
onready var RightIK : BoneAttachment = $Armature/Skeleton/HandIKR

onready var GunMachine = $GunMachine
onready var ReloadMachine = $ReloadMachine
onready var EquipMachine = $EquipMachine

var base_offset := Vector3.ZERO

func _ready() -> void:
	base_offset = transform.origin
	_connect_signals()

func _connect_signals() -> void:
	EquipMachine.connect("equipped", self, "on_equipped")
	EquipMachine.connect("dequipped", self, "on_dequipped")
	

onready var chamber : int = data["Misc"]["Chamber"] setget set_chamber, get_chamber
func set_chamber(value : int) -> void:
	chamber = value
#	if is_network_master():
#		get_parent().emit_signal("ammoChanged", get_chamber(), get_magazine(), get_reserve())
func get_chamber() -> int:
	return chamber

onready var magazine : int = data["Misc"]["Magazine"] setget set_magazine, get_magazine
func set_magazine(value : int) -> void:
	magazine = value
#	if is_network_master():
#		get_parent().emit_signal("ammoChanged", get_chamber(), get_magazine(), get_reserve())
func get_magazine() -> int:
	return magazine

onready var reserve : int = data["Misc"]["Reserve"] setget set_reserve, get_reserve
func set_reserve(value : int) -> void:
	reserve = value
#	if is_network_master():
#		get_parent().emit_signal("ammoChanged", get_chamber(), get_magazine(), get_reserve())
func get_reserve() -> int:
	return reserve

func can_reload() -> bool:
	return magazine < data["Misc"]["Magazine"]

#spring stuff
func _process(delta : float) -> void:
	var pos := Vector3.ZERO
	var rot := Vector3.ZERO
	
	pos += EquipMachine.EquipPositionSpring.position
	rot += EquipMachine.EquipRotationSpring.position
	
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

var data := {
	"Ballistics": {
		"Head multiplier": float(1.5),
		"Torso multipler": float(1.0),
		"Limb multiplier": float(.8),
		
		"Damage range": Vector2(40, 90),
		"Damage": Vector2(32, 24),
		
		"Velocity": 2200.0,
		"Velocity variance": 200.0,
		
		"Penetration depth": float(0),
		
		"Suppression": float(0),
		"Suppression distance": float(0),
		
		"Firerate": float(0),
		"Firerate variance": float(0),
	},
	"Hip accuracy": {
		"Camera rotation damping": .8,
		"Camera rotation speed": 10.0,
		
		"Min camera rotation": Vector3(-.1, -.1, 0),
		"Max camera rotation": Vector3(.2, .1, 0),
		"Min camera rotation force": Vector3(.1, 0, 0),
		"Max camera rotation force": Vector3(.3, 0, 0),
		
		"Camera translation damping": .8,
		"Camera translation speed": 10.0,
		
		"Min camera translation": Vector3.ZERO,
		"Max camera translation": Vector3(2, 2, 2),
		"Min camera translation force": Vector3.ZERO,
		"Max camera translation force": Vector3.ZERO,
		
		"Camera rotation sway": Vector3(.005, .005, 0),
		"Camera rotation sway speed": 5.0,
		"Camera rotation sway damping": .8,
		
		"Camera bob damper": .9,
		"Camera bob idle speed": 4.0,
		"Camera bob idle intensity": Vector3(.1, .1, .1),
		"Camera bob speed": 0.1,
		"Camera bob intensity": Vector3(.01, .01, .01),
		
		#total bounds
		"Min translation": Vector3(-.75, -.75, 0),
		"Max translation": Vector3(.5, .5, 2.0),
		"Min rotation": Vector3(-2, -2, -2),
		"Max rotation": Vector3(2, 2, 2),
		
		#recoil force
		"Min translation force": Vector3(-1.2, .2, 2.5),
		"Max translation force": Vector3(1.6, 1.2, 4.0),
		"Min rotation force": Vector3(.4, -1.2, 0),
		"Max rotation force": Vector3(1.0, 1.4, 0),
		
		#recoil spring settings
		"Recoil translation speed": 13.0,
		"Recoil translation damping": .7,
		
		"Recoil rotation speed": 13.0,
		"Recoil rotation damping": .7,
		
		#sway springs
		"Translation sway": Vector3(.1, .1, 0),
		"Translation sway speed": 14.0,
		"Translation sway damping": .6,
		
		"Rotation sway": Vector3(.04, .04, 0),
		"Rotation sway speed": 12.0,
		"Rotation sway damping": .7,
		
		"Gun bob position": Vector3(1.1, .7, 1),
		"Gun bob position multiplier": 0.04,
		"Gun bob rotation": Vector3(.9, 1.4, 1),
		"Gun bob rotation multiplier": 0.02,
		"Gun bob idle": 1,
		
		"Gun bob intensity speed": 10,
		"Gun bob intensity damper": .9,
		"Gun bob speed damper": .7,
		"Gun bob speed speed": 10,
		
		"Gun bob intensity multiplier": .01,
		"Gun bob position damping": .7,
		"Gun bob position speed": 3,
		
		"Walkspeed": 12.0,
		
		"Spread factor": float(0),
		"Choke": float(0),
		
		"Recoil speed": 15.0,
		"Recoil damping": .8,
		
		"Magnification": 1.0,
	},
	"Sight accuracy": {
		"Camera rotation damping": .8,
		"Camera rotation speed": 10.0,
		
		"Min camera rotation": Vector3(-.1, -.1, 0),
		"Max camera rotation": Vector3(.2, .1, 0),
		"Min camera rotation force": Vector3(.1, 0, 0),
		"Max camera rotation force": Vector3(.3, 0, 0),
		
		"Camera translation damping": .8,
		"Camera translation speed": 10.0,
		
		"Min camera translation": Vector3.ZERO,
		"Max camera translation": Vector3(2, 2, 2),
		"Min camera translation force": Vector3.ZERO,
		"Max camera translation force": Vector3.ZERO,
		
		"Camera rotation sway": Vector3(.05, .05, 0),
		"Camera rotation sway speed": 6,
		"Camera rotation sway damping": .3,
		
		"Camera bob damper": .9,
		"Camera bob idle speed": 4.0,
		"Camera bob idle intensity": Vector3(.1, .1, .1),
		"Camera bob speed": 0.1,
		"Camera bob intensity": Vector3(.01, .01, .01),
		
		#total bounds
		"Min translation": Vector3(-.75, -.75, 0),
		"Max translation": Vector3(.5, .5, 2.0),
		"Min rotation": Vector3(-2, -2, -2),
		"Max rotation": Vector3(2, 2, 2),
		
		#recoil force
		"Min translation force": Vector3(-1.2, .2, 2.5),
		"Max translation force": Vector3(1.6, 1.2, 4.0),
		"Min rotation force": Vector3(.4, -1.2, 0),
		"Max rotation force": Vector3(1.0, 1.4, 0),
		
		#recoil spring settings
		"Recoil translation speed": 13.0,
		"Recoil translation damping": .7,
		
		"Recoil rotation speed": 13.0,
		"Recoil rotation damping": .7,
		
		#sway springs
		"Translation sway": Vector3(.02, .02, 0),
		"Translation sway speed": 18.0,
		"Translation sway damping": .9,
		
		"Rotation sway": Vector3(.01, .01, 0),
		"Rotation sway speed": 18.0,
		"Rotation sway damping": .9,
		
		"Gun bob position": Vector3(1.4, .7, 1),
		"Gun bob position multiplier": 0.001,
		"Gun bob rotation": Vector3(1.4, .7, 1),
		"Gun bob rotation multiplier": 0.001,
		"Gun bob idle": 1.5,
		
		"Gun bob intensity speed": 10,
		"Gun bob intensity damper": .9,
		"Gun bob speed damper": .7,
		"Gun bob speed speed": 10,
		
		"Gun bob intensity multiplier": .01,
		"Gun bob position damping": .7,
		"Gun bob position speed": 3,
		
		"Walkspeed": 6.0,
		
		"Spread factor": float(0),
		"Choke": float(0),
		
		"Recoil speed": 15.0,
		"Recoil damping": .8,
		
		"Magnification": 1.2,
	},
	"Weapon handling": {
		"Equip translation speed": 10,
		"Equip translation damping": .8,
		"Equip rotation speed": 8,
		"Equip rotation damping": .7,
		
		"Equip position": Vector3(0, -1.5, 0),
		"Equip rotation": Vector3(-.7, 0, 0),
		
		"Dequip translation speed": 12,
		"Dequip translation damping": .8,
		"Dequip rotation speed": 12,
		"Dequip rotation damping": .8,
		
		"Dequip position": Vector3(0, -1.5, 0),
		"Dequip rotation": Vector3(0, 0, 0),
		
		"Aiming speed": 15,
		"Aiming damping": .8,
		
		"Crosshair size": 10.0,
		"Crosshair spread size": 10.0,
		"Crosshair spread rate": 10.0,
		"Crosshair recover rate": 10.0,
		
		"Sprint multiplier": 1.7,
		"Sprint speed": 4.0,
		"Sprint damping": 1.0,
		
		"Sprint position damper": .7,
		"Sprint position speed": 14,
		"Sprint position": Vector3.ZERO,
		"Sprint rotation damper": .7,
		"Sprint rotation speed": 14,
		"Sprint rotation": Vector3.ZERO,
		
		"Accel speed": 6.0,
		"Accel damping": 1.0,
	},
	"Misc": {
		"Name": "P38",
		"Ammo type": "9x19mm Parabellum",
		"Manufacturer": "Walther",
		"Category": "Pistols",
		"Description": "The Walther P38 was the cheap and rugged successor to the Luger Pistole Parabellum. The P38 introduced groundbreaking technical features which are still in use today.",
		
		"Chamber": 1,
		"Magazine": 8,
		"Reserve": 40,
		
		"Path": "res://Assets/Weapons/Carbines/M4A1/",
	},
}
