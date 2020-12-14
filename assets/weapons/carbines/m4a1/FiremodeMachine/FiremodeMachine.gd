extends Node

onready var player = get_parent()

export(String) var stateMachine
export(String) var currentState

signal stateChanged
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
		i.connect("changeState", self, "changeState")

func _process(delta):
	states[currentState].process(delta)

func changeState(new_state):
	if is_network_master():
#		print(new_state)
		#add state to state stack
		stateStack.append(currentState)
		#exit current state
		states[currentState].exit()
		#enter new state from current state
		states[new_state].enter(currentState)
		#emit stateChanged signal
		emit_signal("stateChanged", self, currentState, new_state)
		#assing currentState to new state
		currentState = new_state
		rpc("syncState", new_state)

puppet func syncState(new_state : String) -> void:
	#add state to state stack
	stateStack.append(currentState)
	#exit current state
	states[currentState].exit()
	#enter new state from current state
	states[new_state].enter(currentState)
	#emit stateChanged signal
	emit_signal("stateChanged", self, currentState, new_state)
	#assing currentState to new state
	currentState = new_state

func _unhandled_input(event):
	if is_network_master():
		#change firemode
		if Input.is_action_just_pressed("ChangeFiremode"):
			states[currentState].changeFiremode()
			get_tree().set_input_as_handled()
			return
		
		states[currentState].unhandled_input(event)

func _on_Ready_reset():
	states[currentState].onReset()
