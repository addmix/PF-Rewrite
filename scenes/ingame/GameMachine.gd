extends Node

export var current_state := "Menu"
var states := {}

func _ready() -> void:
	var children = get_children()
	for child in children:
		#connect state's signal
		child.connect("change_state", self, "change_state")
		#add to dictionary
		states[child.name] = child

func change_state(new_state : String) -> void:
	

func _process(delta : float) -> void:
	states[current_state].process(delta)

func _unhandled_input(event) -> void:
	states[current_state].unhandled_input(event)
