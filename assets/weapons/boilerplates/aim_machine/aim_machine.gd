extends Node

onready var gun = get_parent()

var states := {}
var current_state := "Aim"

func _ready() -> void:
	#add all states to the states dictionary
	var children := get_children()
	for i in children:
		states[i.name] = i
		i.gun = gun
		i.connect("change_state", self, "change_state")

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
		rpc_id(1, "sync_state", new_state)
	

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

func _unhandled_input(event : InputEvent) -> void:
	if is_network_master():
		
		#equip machine input
		
		#pass input to state
		states[current_state].unhandled_input(event)

func _process(delta : float) -> void:
	#equip machine process
	
	#process current state
	states[current_state].process(delta)

func get_aim() -> Transform:
	return states[current_state].get_aim()
