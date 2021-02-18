extends Node

onready var player = get_parent()

# warning-ignore:unused_signal
signal change_state

onready var gunMachine = get_parent().get_node("GunMachine")

export var current_state := "Ready"
var states := {}

func _ready() -> void:
	set_process(false)
	initialize_states()
	call_deferred("set_process", true)

func interrupt_reload() -> void:
	get_parent()._AnimationPlayer.stop(true)
	get_parent()._AnimationPlayer.play("Ready", .3)
	
	states[current_state].stop()

func initialize_states() -> void:
	#gets all descendants
	var descendants : Array = NodeUtils.get_child_recursive(self)
	
	#go through all descendants
	for i in descendants:
		#create dictionary entry with name as key
		states[i.name] = i
		#connect node's signals
		i.connect("change_state", self, "change_state")

func _physics_process(delta : float) -> void:
	if Input.is_action_just_pressed("shoot"):
		interrupt_reload()
	states[current_state].process(delta)

func change_state(new_state : String) -> void:
	#exit current state
	states[current_state].exit()
	#enter new state from current state
	states[new_state].enter(current_state)
	#assing current_state to new state
	current_state = new_state
	if get_tree().is_network_server():
		rpc("sync_state", new_state)
	elif is_network_master():
		rpc_id(1, "sync_state", new_state)

remote func sync_state(new_state : String) -> void:
	if get_tree().is_network_server():
		rpc("sync_state", new_state)
	
	if current_state != new_state:
		
		#exit current state
		states[current_state].exit()
		#enter new state from current state
		states[new_state].enter(current_state)
		#assing current_state to new state
		current_state = new_state
	

func _unhandled_input(event : InputEvent) -> void:
	if is_network_master():
		if event.is_action_pressed("reload") and get_parent().can_reload():
			get_tree().set_input_as_handled()
			if get_tree().is_network_server():
				rpc("input", event)
			else:
				rpc_id(1, "input", event)
			
			if states[current_state].stopped:
				states[current_state].resume()

remote func input(event : InputEvent) -> void:
	if get_tree().is_network_server():
		#anticheat
		rpc("input", event)
	
	if event.is_action_pressed("reload") and get_parent().can_reload():
		if states[current_state].stopped:
			states[current_state].resume()

remote func resume() -> void:
	if !is_network_master():
		states[current_state].resume()

func _on_AnimationPlayer_animation_finished(anim_name : String) -> void:
	states[current_state].anim_finished(anim_name)
