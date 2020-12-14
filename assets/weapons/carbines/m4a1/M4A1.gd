extends Spatial

# warning-ignore:unused_signal
signal ammoChanged
signal fire

onready var aim_node = $Aim

onready var chamber : int = data["Misc"]["Chamber"] setget set_chamber, get_chamber
func set_chamber(value : int) -> void:
	chamber = value
	if is_network_master():
		get_parent().emit_signal("ammoChanged", get_chamber(), get_magazine(), get_reserve())
func get_chamber() -> int:
	return chamber

onready var magazine : int = data["Misc"]["Magazine"] setget set_magazine, get_magazine
func set_magazine(value : int) -> void:
	magazine = value
	if is_network_master():
		get_parent().emit_signal("ammoChanged", get_chamber(), get_magazine(), get_reserve())
func get_magazine() -> int:
	return magazine

onready var reserve : int = data["Misc"]["Reserve"] setget set_reserve, get_reserve
func set_reserve(value : int) -> void:
	reserve = value
	if is_network_master():
		get_parent().emit_signal("ammoChanged", get_chamber(), get_magazine(), get_reserve())
func get_reserve() -> int:
	return reserve

onready var gunMachine = $GunMachine
onready var animationPlayer : AnimationPlayer = $AnimationPlayer

const magazineCapacity := 30

func can_reload() -> bool:
	return magazine < magazineCapacity

func _ready():
	$AnimationPlayer.call_deferred("play", "Ready")
	call_deferred("emit_signal", "ammoChanged", chamber, magazine, reserve)

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
		
		"Min translation": Vector3(-.75, -.75, 0),
		"Max translation": Vector3(.5, .5, 2.0),
		"Min translation force": Vector3(-1.2, .2, 2.5),
		"Max translation force": Vector3(1.6, 1.2, 4.0),
		
		"Min rotation": Vector3(-2, -2, -2),
		"Max rotation": Vector3(2, 2, 2),
		"Min rotation force": Vector3(.4, -1.2, 0),
		"Max rotation force": Vector3(1.0, 1.4, 0),
		
		"TranslationSway": Vector3(.2, .2, 0),
		"TranslationSwaySpeed": 12.0,
		"TranslationSwayDamping": .7,
		
		"RotationSway": Vector3(.4, .4, 0),
		"RotationSwaySpeed": 12.0,
		"RotationSwayDamping": .7,
		
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
		"Min camera rotation force": Vector3(.3, 0, 0),
		"Max camera rotation force": Vector3(.6, 0, 0),
		
		"Camera translation damping": .8,
		"Camera translation speed": 10.0,
		
		"Min camera translation": Vector3.ZERO,
		"Max camera translation": Vector3.ZERO,
		"Min camera translation force": Vector3.ZERO,
		"Max camera translation force": Vector3.ZERO,
		
		"Min translation": Vector3(-.75, -.75, 0),
		"Max translation": Vector3(.5, .5, 2.0),
		"Min translation force": Vector3(-.2, .1, 1),
		"Max translation force": Vector3(.4, .3, 2),
		
		"Min rotation": Vector3(-2, -2, -2),
		"Max rotation": Vector3(2, 2, 2),
		"Min rotation force": Vector3(.3, -.3, 0),
		"Max rotation force": Vector3(.7, .5, 0),
		
		"TranslationSway": Vector3(.1, .1, 0),
		"TranslationSwaySpeed": 12.0,
		"TranslationSwayDamping": .85,
		
		"RotationSway": Vector3(.05, .05, 0),
		"RotationSwaySpeed": 12.0,
		"RotationSwayDamping": .85,
		
		"Walkspeed": 12.0,
		
		"Spread factor": float(0),
		"Choke": float(0),
		
		"Recoil speed": 14.0,
		"Recoil damping": .85,
		
		"Magnification": 1.5,
	},
	"Weapon handling": {
		"Equip speed": 12,
		"Aiming speed": 15,
		
		"Crosshair size": 10.0,
		"Crosshair spread size": 10.0,
		"Crosshair spread rate": 10.0,
		"Crosshair recover rate": 10.0,
		
		"Sprint multiplier": 1.7,
		"Sprint speed": 4.0,
		"Sprint damping": 1.0,
		
		"Accel speed": 6.0,
		"Accel damping": 1.0,
	},
	"Misc": {
		"Name": "M4A1",
		"Ammo type": "5.56x45mm NATO",
		"Manufacturer": "Colt",
		"Category": 1,
		"Description": "The Colt M4A1 is a firearm based off of Eugene Stoner's Armalite 15. Adopted by the US military in 1994 to replace the M16.",
		
		"Chamber": 1,
		"Magazine": 30,
		"Reserve": 120,
		
		"Path": "res://Assets/Weapons/Carbines/M4A1/",
	},
}
