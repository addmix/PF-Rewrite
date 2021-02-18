extends Node

onready var player = get_parent()

signal state_changed

export var current_state := "Ready"
var states := {}

func _ready() -> void:
	set_process(false)
	initialize_states()
	call_deferred("set_process", true)

func initialize_states() -> void:
	#gets all descendants
	var descendants : Array = get_children()
	
	#go through all descendants
	for i in descendants:
		#create dictionary entry with name as key
		states[i.name] = i
		#connect node's signals
		i.connect("change_state", self, "change_state")

func _physics_process(delta : float) -> void:
	states[current_state].process(delta)

remote var puppet_shooting = false
var shooting = false

func _unhandled_input(event : InputEvent) -> void:
	if is_network_master():
		states[current_state].unhandled_input(event)

func change_state(new_state : String) -> void:
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
		rpc_id(1, "sync_state", new_state)

remote func sync_state(new_state : String) -> void:
	if get_tree().is_network_server():
		#anticheat
		rpc("sync_state", new_state)
	if is_network_master():
		return
	
	if current_state != new_state:
		#exit current state
		states[current_state].exit()
		#enter new state from current state
		states[new_state].enter(current_state)
		#emit state_changed signal
		emit_signal("state_changed", self, current_state, new_state)
		#assing current_state to new state
		current_state = new_state
	
