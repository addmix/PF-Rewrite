extends Weapon
class_name Gun


#signals
# warning-ignore:unused_signal
signal update_ammo
signal shot_fired

#properties
onready var chamber : int = _data["Misc"]["Chamber"] setget set_chamber, get_chamber
func set_chamber(value : int) -> void:
	chamber = value
	if is_network_master():
		emit_signal("update_ammo", get_chamber(), get_magazine(), get_reserve())
func get_chamber() -> int:
	return chamber

onready var magazine : int = _data["Misc"]["Magazine"] setget set_magazine, get_magazine
func set_magazine(value : int) -> void:
	magazine = value
	if is_network_master():
		emit_signal("update_ammo", get_chamber(), get_magazine(), get_reserve())
func get_magazine() -> int:
	return magazine

onready var reserve : int = _data["Misc"]["Reserve"] setget set_reserve, get_reserve
func set_reserve(value : int) -> void:
	reserve = value
	if is_network_master():
		emit_signal("update_ammo", get_chamber(), get_magazine(), get_reserve())
func get_reserve() -> int:
	return reserve

func update_ammo() -> void:
	emit_signal("update_ammo", get_chamber(), get_magazine(), get_reserve())

func can_reload() -> bool:
	return magazine < _data["Misc"]["Magazine"]

func get_aim() -> Transform:
	return AimMachine.get_aim()

#depreciated
export var _data := {
	"Misc": {
		"Name": "",
		"Ammo type": "",
		"Manufacturer": "",
		"Category": "",
		"Description": "",
		
		"Chamber": int(0),
		"Magazine": int(0),
		"Reserve": int(0),
		
		"Path": "",
	},
	"Ballistics": {
		"Head": float(1.0),
		"Chest": float(1.0),
		"Waist": float(1.0),
		"Hips": float(1.0),
		"BicepL": float(1.0),
		"BicepR": float(1.0),
		"ForearmL": float(1.0),
		"ForearmR": float(1.0),
		"HandL": float(1.0),
		"HandR": float(1.0),
		"ThighL": float(1.0),
		"ThighR": float(1.0),
		"ShinL": float(1.0),
		"ShinR": float(1.0),
		"FootL": float(1.0),
		"FootR": float(1.0),
		
		"Damage": float(0.0),
		
		"Velocity": float(0.0),
		"Velocity variance": float(0.0),
		
		"Firerate": float(0),
		"Firerate variance": float(0),
		
		"Suppression": float(0),
		"Suppression distance": float(0),
		
		"Penetration depth": float(0),
		
		"Projectile count": int(0),
	},
	"Weapon handling": {
		
		#state springs
		
		"Equip s": float(0),
		"Equip d": float(0),
		
		"Equip pos": Vector3(0, 0, 0),
		"Equip rot": Vector3(0, 0, 0),
		
		"Dequip s": float(0),
		"Dequip d": float(0),
		
		"Dequip pos": Vector3(0, 0, 0),
		"Dequip rot": Vector3(0, 0, 0),
		
		"Aim s": float(0),
		"Aim d": float(0),
		
		"Breath s": float(0),
		"Breath d": float(0),
		
		"Air s": float(0),
		"Air d": float(0),
		
		"Sprint s": float(0),
		"Sprint d": float(0),
		
		"Move s": float(0),
		"Move d": float(0),
		
		"Crouch s": float(0),
		"Crouch d": float(0),
		
		"Prone s": float(0),
		"Prone d": float(0),
		
		"Mount s": float(0),
		"Mount d": float(0),
		
		#camera
		
		#rotation
		"Camera rot d": float(0),
		"Camera rot s": float(0),
		
		"Min camera rot": Vector3(0, 0, 0),
		"Max camera rot": Vector3(0, 0, 0),
		"Min camera rot force": Vector3(0, 0, 0),
		"Max camera rot force": Vector3(0, 0, 0),
		
		#translation
		"Camera pos d": float(0),
		"Camera pos s": float(0),
		
		"Min camera pos": Vector3(0, 0, 0),
		"Max camera pos": Vector3(0, 0, 0),
		"Min camera pos force": Vector3(0, 0, 0),
		"Max camera pos force": Vector3(0, 0, 0),
		
		#position
		"Pos": Vector3(0, 0, 0),
		"Rot": Vector3(0, 0, 0),
		
		#total bounds
		"Min pos": Vector3(0, 0, 0),
		"Max pos": Vector3(0, 0, 0),
		"Min rot": Vector3(0, 0, 0),
		"Max rot": Vector3(0, 0, 0),
		
		#recoil
		
		#force
		"Min pos force": Vector3(0, 0, 0),
		"Max pos force": Vector3(0, 0, 0),
		"Min rot force": Vector3(0, 0, 0),
		"Max rot force": Vector3(0, 0, 0),
		
		#recoil spring settings
		"Recoil pos s": float(0),
		"Recoil pos d": float(0),
		
		"Recoil rot s": float(0),
		"Recoil rot d": float(0),
		
		#sway
		"Camera rot sway": Vector3(0, 0, 0),
		"Camera rot sway s": float(0),
		"Camera rot sway d": float(0),
		
		"Camera bob s": float(0),
		"Camera bob d": float(0),
		"Camera bob i": Vector3(0, 0, 0),
		
		"Pos sway": Vector3(0, 0, 0),
		"Pos sway s": float(0),
		"Pos sway d": float(0),
		
		"Rot sway": Vector3(0, 0, 0),
		"Rot sway s": float(0),
		"Rot sway d": float(0),
		
		"Accel sway s": float(0),
		"Accel sway d": float(0),
		"Accel sway pos i": Vector3(0, 0, 0),
		"Accel sway rot i": Vector3(0, 0, 0),
		"Accel sway offset": Vector3(0, 0, 0),
		
		"Breath sway s": float(0),
		"Breath sway pos i": Vector3(0, 0, 0),
		"Breath sway rot i": Vector3(0, 0, 0),
		
		#walk
		"Walkspeed": float(0),
		"Walk s": float(0),
		"Walk d": float(0),
		
		"Gun bob s": float(0),
		"Gun bob pos i": Vector3(0, 0, 0),
		"Gun bob rot i": Vector3(0, 0, 0),
		
		#reload
		"Reload s": float(0),
		"Reload d": float(0),
		
		#camera magnification
		"Magnification": float(0),
		"Spread factor": float(0),
		"Choke": float(0),
		
		#sight change speed
		"Sight swap s": float(0),
		"Sight swap d": float(0),
	},
} setget set_data, get_data

func set_data(data : Dictionary) -> void:
	_data = data

func get_data() -> Dictionary:
	return _data

var _add := {
	#modifier states
	"Equip": {},
	"Dequip": {},
	"Air" : {},
	"Aim" : {},
	"Breath": {},
	"Sprint" : {},
	"Movement" : {},
	"Accel" : {},
	"Reload" : {},
	"Crouch" : {},
	"Prone" : {},
	"Mounted": {},
} setget set_add, get_add

func set_add(add : Dictionary) -> void:
	_add = add

func get_add() -> Dictionary:
	return _add

var _multi := {
	"Equip": {},
	"Dequip": {},
	"Air" : {},
	"Aim" : {},
	"Breath": {},
	"Sprint" : {},
	"Movement" : {},
	"Accel" : {},
	"Reload" : {},
	"Crouch" : {},
	"Prone" : {},
	"Mounted": {},
} setget set_multi, get_multi

func set_multi(multi : Dictionary) -> void:
	_multi = multi

func get_multi() -> Dictionary:
	return _multi
