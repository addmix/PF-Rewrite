extends Spatial

# warning-ignore:unused_signal
signal ammoChanged
# warning-ignore:unused_signal
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
# warning-ignore:unused_argument
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

export var data := {
	"Ballistics": {
		"Head multiplier": float(1.5),
		"Torso multipler": float(1.0),
		"Limb multiplier": float(.8),
		
		"Damage range": Vector2(40, 90),
		"Damage": Vector2(32, 24),
		
		"Velocity": float(2200.0),
		"Velocity variance": float(200.0),
		
		"Penetration depth": float(0),
		
		"Suppression": float(0),
		"Suppression distance": float(0),
		
		"Firerate": float(0),
		"Firerate variance": float(0),
	},
	"Hip accuracy": {
		"Camera rotation damping": float(.8),
		"Camera rotation speed": float(10.0),
		
		"Min camera rotation": Vector3(-.1, -.1, 0),
		"Max camera rotation": Vector3(.2, .1, 0),
		"Min camera rotation force": Vector3(.1, 0, 0),
		"Max camera rotation force": Vector3(.3, 0, 0),
		
		"Camera translation damping": float(.8),
		"Camera translation speed": float(10.0),
		
		"Min camera translation": Vector3.ZERO,
		"Max camera translation": Vector3(2, 2, 2),
		"Min camera translation force": Vector3.ZERO,
		"Max camera translation force": Vector3.ZERO,
		
		"Camera rotation sway": Vector3(.005, .005, 0),
		"Camera rotation sway speed": float(5.0),
		"Camera rotation sway damping": float(.8),
		
		"Camera bob damper": float(.9),
		"Camera bob idle speed": float(4.0),
		"Camera bob idle intensity": Vector3(.1, .1, .1),
		"Camera bob speed": float(0.1),
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
		"Recoil translation speed": float(13.0),
		"Recoil translation damping": float(.7),
		
		"Recoil rotation speed": float(13.0),
		"Recoil rotation damping": float(.7),
		
		#sway springs
		"Translation sway": Vector3(.1, .1, 0),
		"Translation sway speed": float(14.0),
		"Translation sway damping": float(.6),
		
		"Rotation sway": Vector3(.04, .04, 0),
		"Rotation sway speed": float(12.0),
		"Rotation sway damping": float(.7),
		
		"Gun bob position": Vector3(1.1, .7, 1),
		"Gun bob position multiplier": float(0.04),
		"Gun bob rotation": Vector3(.9, 1.4, 1),
		"Gun bob rotation multiplier": float(0.02),
		"Gun bob idle": float(1.0),
		
		"Gun bob intensity speed": float(10.0),
		"Gun bob intensity damper": float(.9),
		"Gun bob speed damper": float(.7),
		"Gun bob speed speed": float(10.0),
		
		"Gun bob intensity multiplier": float(.01),
		"Gun bob position damping": float(.7),
		"Gun bob position speed": float(3.0),
		
		"Accel sway speed": float(6.0),
		"Accel sway damping": float(.9),
		"Accel sway intensity": Vector3(.3, .4, .15),
		"Accel sway offset": Vector3(0, 0, -1.2),
		
		"Walk damper": float(.9),
		"Walk accel": float(8.0),
		"Walk multiplier": float(1.0),
		
		"Sprint damper": float(.9),
		"Sprint speed": float(10.0),
		"Sprint multiplier": float(1.7),
		
		"Sprint position": Vector3(-.2, -.1, 0),
		"Sprint rotation": Vector3(-.4, 1, .2),
		
		"Spread factor": float(0),
		"Choke": float(0),
		
		"Recoil speed": float(15.0),
		"Recoil damping": float(.8),
		
		"Magnification": float(1.0),
	},
	"Sight accuracy": {
		"Camera rotation damping": float(.8),
		"Camera rotation speed": float(10.0),
		
		"Min camera rotation": Vector3(-.1, -.1, 0),
		"Max camera rotation": Vector3(.2, .1, 0),
		"Min camera rotation force": Vector3(.1, 0, 0),
		"Max camera rotation force": Vector3(.3, 0, 0),
		
		"Camera translation damping": float(.8),
		"Camera translation speed": float(10.0),
		
		"Min camera translation": Vector3.ZERO,
		"Max camera translation": Vector3(2, 2, 2),
		"Min camera translation force": Vector3.ZERO,
		"Max camera translation force": Vector3.ZERO,
		
		"Camera rotation sway": Vector3(.05, .05, 0),
		"Camera rotation sway speed": float(6.0),
		"Camera rotation sway damping": float(.3),
		
		"Camera bob damper": float(.9),
		"Camera bob idle speed": float(4.0),
		"Camera bob idle intensity": Vector3(.1, .1, .1),
		"Camera bob speed": float(0.1),
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
		"Recoil translation speed": float(13.0),
		"Recoil translation damping": float(.7),
		
		"Recoil rotation speed": float(13.0),
		"Recoil rotation damping": float(.7),
		
		#sway springs
		"Translation sway": Vector3(.02, .02, 0),
		"Translation sway speed": float(18.0),
		"Translation sway damping": float(.9),
		
		"Rotation sway": Vector3(.01, .01, 0),
		"Rotation sway speed": float(18.0),
		"Rotation sway damping": float(.9),
		
		"Gun bob position": Vector3(1.4, .7, 1),
		"Gun bob position multiplier": float(0.001),
		"Gun bob rotation": Vector3(1.4, .7, 1),
		"Gun bob rotation multiplier": float(0.001),
		"Gun bob idle": (1.5),
		
		"Gun bob intensity speed": float(10.0),
		"Gun bob intensity damper": float(.9),
		"Gun bob speed damper": float(.7),
		"Gun bob speed speed": float(10.0),
		
		"Gun bob intensity multiplier": float(.01),
		"Gun bob position damping": float(.7),
		"Gun bob position speed": float(3.0),
		
		"Accel sway speed": float(8.0),
		"Accel sway damping": float(.85),
		"Accel sway intensity": Vector3(.1, .3, .1),
		"Accel sway offset": Vector3(0, 0, -1),
		
		"Walk damper": float(.9),
		"Walk accel": float(8.0),
		"Walk multiplier": float(.8),
		
		"Sprint damper": float(.9),
		"Sprint speed": float(6.0),
		"Sprint multiplier": float(1.4),
		
		"Sprint position": Vector3(.1, -.2, 0),
		"Sprint rotation": Vector3.ZERO,
		
		"Spread factor": float(0),
		"Choke": float(0),
		
		"Recoil speed": float(15.0),
		"Recoil damping": float(.8),
		
		"Magnification": float(1.2),
	},
	"Weapon handling": {
		"Equip translation speed": float(10.0),
		"Equip translation damping": float(.8),
		"Equip rotation speed": float(8.0),
		"Equip rotation damping": float(.7),
		
		"Equip position": Vector3(0, -1.5, 0),
		"Equip rotation": Vector3(-.7, 0, 0),
		
		"Dequip translation speed": float(12.0),
		"Dequip translation damping": float(.8),
		"Dequip rotation speed": float(12.0),
		"Dequip rotation damping": float(.8),
		
		"Dequip position": Vector3(0, -1.5, 0),
		"Dequip rotation": Vector3(0, 0, 0),
		
		"Aiming speed": float(15.0),
		"Aiming damping": float(.8),
		
		"Crosshair size": float(10.0),
		"Crosshair spread size": float(10.0),
		"Crosshair spread rate": float(10.0),
		"Crosshair recover rate": float(10.0),
		
		"Position": Vector3(0, .2, 0),
		"Rotation": Vector3(0, 0, 0),
		
		"Walkspeed": float(12.0),
		
		"Accel speed": float(6.0),
		"Accel damping": float(.9),
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
