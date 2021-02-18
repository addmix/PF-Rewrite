extends Node

# warning-ignore:unused_signal
signal equipped
# warning-ignore:unused_signal
signal dequipped

var states := {}
export var current_state : String = "Inactive"

var EquipPosSpring : V3Spring
var EquipRotSpring : V3Spring

func _ready() -> void:
	
	#add states to machine
	var children := get_children()
	for child in children:
		states[child.name] = child
		#connect all children's change state signal
		child.connect("change_state", self, "change_state")
	
	init_springs()

func init_springs() -> void:
	EquipPosSpring = V3Spring.new(get_parent().data["Weapon handling"]["Equip pos"], Vector3.ZERO, Vector3.ZERO, get_parent().data["Weapon handling"]["Equip d"], get_parent().data["Weapon handling"]["Equip s"])
	EquipRotSpring = V3Spring.new(get_parent().data["Weapon handling"]["Equip pos"], Vector3.ZERO, Vector3.ZERO, get_parent().data["Weapon handling"]["Equip d"], get_parent().data["Weapon handling"]["Equip s"])

func change_state(new_state : String) -> void:
	#exit current state
	states[current_state].exit()
	#enter new state from current state
	states[new_state].enter()
	#assing current_state to new state
	current_state = new_state
	if get_tree().is_network_server():
		rpc("sync_state", new_state)
	elif is_network_master():
		rpc_id(1, "syncState", new_state)
	

remote func sync_state(new_state : String) -> void:
	if get_tree().is_network_server():
		#anticheat
		rpc("sync_state", new_state)
	
	if current_state != new_state:
		#exit current state
		states[current_state].exit()
		#enter new state from current state
		states[new_state].enter()
		#assing current_state to new state
		current_state = new_state


func _physics_process(delta : float) -> void:
	states[current_state].process(delta)

func _unhandled_input(event : InputEvent) -> void:
	if is_network_master():
		#these are inputs we want to be disabled when the gun isnt ready
	#	if current_state != "Idle":
	#		if event.is_action_pressed("shoot"):
	#			get_tree().set_input_as_handled()
	#			return
	#		if event.is_action_pressed("reload"):
	#			get_tree().set_input_as_handled()
	#			return
		
		#pass inputs to current state
		states[current_state].unhandled_input(event)
