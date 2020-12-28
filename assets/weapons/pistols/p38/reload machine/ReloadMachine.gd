extends Node

var states := {}
export var current_state := "Ready"

func _ready() -> void:
	var children := get_children()
	
	for child in children:
		states[child.name] = child
		child.connect("change_state", self, "change_state")

func change_state(new_state : String) -> void:
	print(new_state)
	states[current_state].exit()
	states[new_state].enter()
	current_state = new_state
	if is_network_master():
		rpc("sync_state", new_state)

puppet func sync_state(new_state : String) -> void:
	states[current_state].exit()
	states[new_state].enter()
	current_state = new_state

func _process(delta : float) -> void:
	states[current_state].process(delta)

func _unhandled_input(event : InputEvent) -> void:
	if is_network_master():
		if event.is_action_pressed("reload") and get_parent().can_reload():
			if states[current_state].stopped:
				states[current_state].resume()
				get_tree().set_input_as_handled()

func interrupt_reload() -> void:
	pass

func _on_AnimationPlayer_animation_finished(anim_name : String) -> void:
	states[current_state].anim_finished(anim_name)
