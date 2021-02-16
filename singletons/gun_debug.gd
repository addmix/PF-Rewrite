extends Node

var weapon_instance : Spatial

export var update := false setget set_update

func _ready() -> void:
	set_weapon("M4A1")

# warning-ignore:unused_argument
func set_update(value : bool) -> void:
	update_data()
#	update = false

export var weapon : String setget set_weapon
func set_weapon(new : String) -> void:
	weapon = new
	if Weapons.models.has(new):
		weapon_instance = Weapons.models[new].instance()
		data = weapon_instance.data
		modifiers = weapon_instance.modifiers
		accuracy = data["Weapon handling"]
		equip = modifiers["Equip"]
		dequip = modifiers["Dequip"]
		air = modifiers["Air"]
		aim = modifiers["Aim"]
		sprint = modifiers["Sprint"]
		movement = modifiers["Movement"]
		accel = modifiers["Accel"]
		reload = modifiers["Reload"]
		crouch = modifiers["Crouch"]
		prone = modifiers["Prone"]
		mounted = modifiers["Mounted"]

func update_data() -> void:
	get_tree().call_group(weapon, "update_data", data, modifiers)

func _exit_tree() -> void:
	#save data
	pass

export var accuracy : Dictionary

export var equip := {}
export var dequip := {}
export var air := {}
export var aim := {}
export var sprint := {}
export var movement := {}
export var accel := {}
export var reload := {}
export var crouch := {}
export var prone := {}
export var mounted := {}

export var data := {}
export var modifiers := {}
