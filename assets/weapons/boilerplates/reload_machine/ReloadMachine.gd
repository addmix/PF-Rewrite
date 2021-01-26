extends Node

onready var player = get_parent()

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
	if is_network_master():
		#exit current state
		states[current_state].exit()
		#enter new state from current state
		states[new_state].enter(current_state)
		#emit state_changed signal
		emit_signal("state_changed", self, current_state, new_state)
		#assing current_state to new state
		current_state = new_state
		if is_network_master():
			rpc("syncState", new_state)

puppet func sync_state(new_state : String) -> void:
	#exit current state
	states[current_state].exit()
	#enter new state from current state
	states[new_state].enter(current_state)
	#emit state_changed signal
	emit_signal("state_changed", self, current_state, new_state)
	#assing current_state to new state
	current_state = new_state

func _unhandled_input(event : InputEvent) -> void:
	if is_network_master():
		if event.is_action_pressed("reload") and get_parent().can_reload():
			get_tree().set_input_as_handled()
			if states[current_state].stopped:
				states[current_state].resume()

func _on_AnimationPlayer_animation_finished(anim_name : String) -> void:
	states[current_state].anim_finished(anim_name)
