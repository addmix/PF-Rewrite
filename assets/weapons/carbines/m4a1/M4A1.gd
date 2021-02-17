extends Gun
class_name M4A1

#effects
var bullet_script : Script = load("res://assets/entities/projectiles/bullets/556x45/556x45.gd")
var muzzle_flash : PackedScene = preload("res://assets/particles/m4a1_muzzle_flash.tscn")

func _ready() -> void:
	.set_data(data)
	.set_add(add)
	.set_multi(multi)

func _on_shotFired() -> void:
	update_ammo()
	#muzzle flash
	var instance
	
#	instance = muzzle_flash.instance()
#	$Barrel.add_child(instance)
	
	#bullet
	instance = Spatial.new()
	instance.set_script(bullet_script)
	instance.weapon = self
	instance.transform.origin = $Barrel.get_global_transform().origin
	instance.velocity = data["Ballistics"]["Velocity"] * -$Barrel.get_global_transform().basis.z
	$"/root".add_child(instance)

var data = {
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
		"Head": float(2.0),
		"Chest": float(1.4),
		"Waist": float(1.1),
		"Hips": float(.9),
		"BicepL": float(.9),
		"BicepR": float(.9),
		"ForearmL": float(.7),
		"ForearmR": float(.7),
		"HandL": float(.5),
		"HandR": float(.5),
		"ThighL": float(1.2),
		"ThighR": float(1.2),
		"ShinL": float(.6),
		"ShinR": float(.6),
		"FootL": float(.3),
		"FootR": float(.3),
		
		"Damage": float(32.0),
		
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
		"Camera rot s": float(16.0),
		
		"Min camera rot": Vector3(-.1, -.1, 0),
		"Max camera rot": Vector3(.2, .1, 0),
		"Min camera rot force": Vector3(.35, -.3, 0),
		"Max camera rot force": Vector3(.55, .3, 0),
		
		#translation
		"Camera pos d": float(.8),
		"Camera pos s": float(10.0),
		
		"Min camera pos": Vector3.ZERO,
		"Max camera pos": Vector3(2, 2, 2),
		"Min camera pos force": Vector3(0, .01, -.05),
		"Max camera pos force": Vector3(0, .025, -.05),
		
		
		
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
		"Min pos force": Vector3(-1, 1.2, .2),
		"Max pos force": Vector3(1.3, 1.6, .5),
		"Min rot force": Vector3(-.8, -.8, -.4),
		"Max rot force": Vector3(1.2, 1.1, .4),
		
		#recoil spring settings
		"Recoil pos s": float(12.0),
		"Recoil pos d": float(.5),
		
		"Recoil rot s": float(12.0),
		"Recoil rot d": float(.4),
		
		
		#sway
		
		
		"Camera rot sway": Vector3(.005, .005, 0),
		"Camera rot sway s": float(5.0),
		"Camera rot sway d": float(.8),
		
		"Camera bob s": float(8),
		"Camera bob d": float(.85),
		"Camera bob i": Vector3(.2, .2, .2),
		
		"Pos sway": Vector3(.05, .05, 0),
		"Pos sway s": float(14.0),
		"Pos sway d": float(.6),
		
		"Rot sway": Vector3(.035, .035, 0),
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
		"Gun bob rot i": Vector3(.001, .001, .01),
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
		"Magnification": float(1.15),
		"Walkspeed": float(0.7),
		
		"Recoil pos s": float(1.3),
		"Recoil rot s": float(1.3),
		
		"Pos sway": Vector3(.2, .2, 1),
		"Pos sway s": float(1.1),
		"Pos sway d": float(.9),
		
		"Rot sway": Vector3(.4, .4, 0),
		"Rot sway s": float(0.95),
		"Rot sway d": float(.9),
		
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
		
		"Gun bob pos i": Vector3(.4, .4, .1),
		"Gun bob rot i": Vector3(.8, .8, .1),
	},
	"Breath": {
		"Magnification": float(1.1),
		"Breath s": float(2),
		"Breath sway pos i": Vector3(0, 0, 0),
		"Breath sway rot i": Vector3(0, 0, 0),
	},
	"Sprint" : {
		"Magnification": float(0.95),
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
