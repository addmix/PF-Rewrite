extends Node

onready var player = get_parent()

export(String) var current_state = "Auto"

signal state_changed
# warning-ignore:unused_signal
signal fire

var gunMachine

var stateStack := []
var states := {}

func _ready() -> void:
	set_process(false)
	initialize_states()
	call_deferred("set_process", true)
	call_deferred("getGunMachine")

func getGunMachine():
	gunMachine = get_parent().get_node("GunMachine")

func initialize_states() -> void:
	#gets all descendants
	var descendants : Array = NodeUtils.get_child_recursive(self)
	
	#go through all descendants
	for i in descendants:
		#create dictionary entry with name as key
		states[i.stateName] = i
		#connect node's signals
		i.connect("change_state", self, "change_state")

func _physics_process(delta : float) -> void:
	states[current_state].process(delta)

func change_state(new_state : String) -> void:
	#add state to state stack
	stateStack.append(current_state)
	#exit current state
	states[current_state].exit()
	#enter new state from current state
	states[new_state].enter(current_state)
	#emit state_changed signal
	emit_signal("state_changed", self, current_state, new_state)
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
		#add state to state stack
		stateStack.append(current_state)
		#exit current state
		states[current_state].exit()
		#enter new state from current state
		states[new_state].enter(current_state)
		#emit state_changed signal
		emit_signal("state_changed", self, current_state, new_state)
		#assing current_state to new state
		current_state = new_state
	

func _unhandled_input(event : InputEvent) -> void:
	if is_network_master():
		#change firemode
		if Input.is_action_just_pressed("change_firemode"):
			if get_tree().is_network_server():
				states[current_state].changeFiremode()
				get_tree().set_input_as_handled()
				rpc("puppet_change_firemode")
				return
			else:
				rpc_id(1, "puppet_change_firemode")
				return
		
		states[current_state].unhandled_input(event)

remote func puppet_change_firemode() -> void:
	if get_tree().is_network_server():
		rpc("puppet_change_firemode")
	else:
		if is_network_master():
			pass
		else:
			states[current_state].changeFiremode()
			get_tree().set_input_as_handled()

func _on_Ready_reset():
	states[current_state].onReset()
