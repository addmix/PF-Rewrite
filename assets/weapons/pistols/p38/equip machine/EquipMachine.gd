extends Node

# warning-ignore:unused_signal
signal equipped
# warning-ignore:unused_signal
signal dequipped

var states := {}
export var current_state : String = "Inactive"

var EquipPositionSpring : V3Spring
var EquipRotationSpring : V3Spring

func _ready() -> void:
	_connect_signals()
	#add states to machine
	var children := get_children()
	for child in children:
		states[child.name] = child
		#connect all children's change state signal
		child.connect("change_state", self, "change_state")
	
	init_springs()

func init_springs() -> void:
	EquipPositionSpring = V3Spring.new(Vector3(0, -1.5, 0), Vector3.ZERO, Vector3.ZERO, get_parent().data["Weapon handling"]["Equip translation damping"], get_parent().data["Weapon handling"]["Equip translation speed"])
	EquipRotationSpring = V3Spring.new(Vector3(0, -1.5, 0), Vector3.ZERO, Vector3.ZERO, get_parent().data["Weapon handling"]["Equip rotation damping"], get_parent().data["Weapon handling"]["Equip rotation speed"])


func _connect_signals() -> void:
# warning-ignore:return_value_discarded
	connect("equipped", self, "equipped")
# warning-ignore:return_value_discarded
	connect("dequipped", self, "dequipped")

func equipped() -> void:
	change_state("Idle")

func dequipped() -> void:
	change_state("Inactive")

func change_state(new_state : String) -> void:
	if !is_inside_tree():
		return
	if is_network_master():
		rpc("sync_state", new_state)
	#exit current state
	states[current_state].exit()
	
	#enter new state
	states[new_state].enter()
	
	current_state = new_state
	

puppet func sync_state(new_state : String) -> void:
	states[current_state].exit()
	states[new_state].enter()
	current_state = new_state

func _process(delta : float) -> void:
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
