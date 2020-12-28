extends Node

signal equipped
signal dequipped

var states := {}
export var current_state : String = "Inactive"

var EquipPositionSpring : Physics.V3Spring
var EquipRotationSpring : Physics.V3Spring

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
	EquipPositionSpring = Physics.V3Spring.new(Vector3(0, -1.5, 0), Vector3.ZERO, Vector3.ZERO, get_parent().data["Weapon handling"]["Equip translation damping"], get_parent().data["Weapon handling"]["Equip translation speed"])
	EquipRotationSpring = Physics.V3Spring.new(Vector3(0, -1.5, 0), Vector3.ZERO, Vector3.ZERO, get_parent().data["Weapon handling"]["Equip rotation damping"], get_parent().data["Weapon handling"]["Equip rotation speed"])


func _connect_signals() -> void:
	connect("equipped", self, "equipped")
	connect("dequipped", self, "dequipped")

func equipped() -> void:
	change_state("Idle")

func dequipped() -> void:
	change_state("Inactive")

func change_state(new_state : String) -> void:
	#exit current state
	states[current_state].exit()
	
	#enter new state
	states[new_state].enter()
	
	current_state = new_state
	
	if is_network_master():
		rpc("syncState", new_state)

puppet func syncState(new_state : String) -> void:
	#exit current state
	states[current_state].exit()
	#enter new state from current state
	states[new_state].enter()
	#assing currentState to new state
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
