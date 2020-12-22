extends Node

var states := {}
export var current_state := "Ready"

func _ready() -> void:
	var children := get_children()
	
	for child in children:
		states[child.name] = child
		child.connect("change_state", self, "change_state")

func _process(delta : float) -> void:
	states[current_state].process(delta)

func _unhandled_input(event : InputEvent) -> void:
	states[current_state].unhandled_input(event)

func change_state(new_state : String) -> void:
	states[current_state].exit()
	states[new_state].enter()
	current_state = new_state


