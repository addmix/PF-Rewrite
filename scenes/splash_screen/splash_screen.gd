extends Node2D

func _ready() -> void:
# warning-ignore:return_value_discarded
	$AnimationPlayer.connect("animation_finished", self, "on_animation_finished")
	
	#load menu
	var menu = load("res://scenes/menu/menu.tscn").instance()
	$"/root".call_deferred("add_child", menu, true)
	#play animation
	$AnimationPlayer.play("fade_out")

func on_animation_finished(_anim : String) -> void:
	queue_free()
