extends Node

export var update := false setget set_update

func set_update(value : bool) -> void:
	update_data()
#	update = false

export var weapon := "M4A1"


func update_data() -> void:
	get_tree().call_group(weapon, "update_data", data, modifiers)

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
		"Accel sway i": Vector3(.003, .004, .0015),
		"Accel sway offset": Vector3(0, 0, -1.2),
		
		
		#walk
		
		
		"Walkspeed": float(12.0),
		"Walk s": float(8.0),
		"Walk d": float(0.99),
		
		"Gun bob s": float(0.1),
		"Gun bob pos i": Vector3(.01, .01, .01),
		"Gun bob rot i": Vector3(.01, .01, .01),
		
		#camera magnification
		"Magnification": float(1.0),
		"Spread factor": float(0),
		"Choke": float(0),
	},
}

export var modifiers := {
	#modifier states
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
		
	},
	"Movement" : {
		"Gun bob pos i": Vector3(.1, .1, .1),
		"Gun bob rot i": Vector3(.1, .1, .1),
		"Gun bob s": float(12),
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
