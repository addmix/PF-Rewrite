extends Node

onready var player = get_parent()

signal stateChanged

export var currentState := "State"
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
		states[i.stateName] = i
		#connect node's signals
		i.connect("changeState", self, "changeState")

func _process(delta : float) -> void:
	states[currentState].process(delta)

func _unhandled_input(event : InputEvent) -> void:
	if is_network_master():
		states[currentState].unhandled_input(event)

func changeState(new_state : String) -> void:
	if is_network_master():
		#exit current state
		states[currentState].exit()
		#enter new state from current state
		states[new_state].enter(currentState)
		#emit stateChanged signal
		emit_signal("stateChanged", self, currentState, new_state)
		#assing currentState to new state
		currentState = new_state
#		rpc("syncState", new_state)

puppet func syncState(new_state : String) -> void:
	#exit current state
	states[currentState].exit()
	#enter new state from current state
	states[new_state].enter(currentState)
	#emit stateChanged signal
	emit_signal("stateChanged", self, currentState, new_state)
	#assing currentState to new state
	currentState = new_state
	

func input() -> void:
	pass

func _on_FiremodeMachine_fire() -> void:
	states[currentState].fire()
