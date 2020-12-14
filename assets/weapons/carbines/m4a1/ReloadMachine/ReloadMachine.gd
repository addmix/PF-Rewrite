extends Node

onready var player = get_parent()

export(String) var stateMachine
export(String) var currentState

signal stateChanged

onready var gunMachine = get_parent().get_node("GunMachine")

var stateStack := []
var states := {}

func _ready() -> void:
	set_process(false)
	initialize_states()
	call_deferred("set_process", true)

func interrupt_reload():
	get_parent().animationPlayer.stop(true)
	states[currentState].stop()

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
	if Input.is_action_just_pressed("Shoot"):
		interrupt_reload()
	states[currentState].process(delta)

func changeState(new_state):
	if is_network_master():
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

master func _unhandled_input(event):
	if is_network_master():
		if event.is_action_pressed("Reload") and get_parent().can_reload():
			get_tree().set_input_as_handled()
			if states[currentState].stopped:
				states[currentState].resume()

func _on_AnimationPlayer_animation_finished(anim_name : String) -> void:
	states[currentState].anim_finished(anim_name)
