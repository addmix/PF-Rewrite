extends Node

onready var character : KinematicBody = get_parent()

var states := {}
var current_state := "Hip"

func _ready() -> void:
	#add all states to the states dictionary
	var children := get_children()
	for i in children:
		states[i.name] = i
		i.character = character
		i.connect("change_state", self, "change_state")

func change_state(new_state : String) -> void:
	#exit old state
	states[current_state].exit()
	#enter new state
	states[new_state].enter()
	#apply new state
	current_state = new_state

func _unhandled_input(event : InputEvent) -> void:
	#equip machine input
	
	#pass input to state
	states[current_state].unhandled_input(event)

func _process(delta : float) -> void:
	#equip machine process
	
	#process current state
	states[current_state].process(delta)
