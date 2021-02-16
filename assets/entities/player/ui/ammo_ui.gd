extends Panel

onready var label : Label = $HBoxContainer/Magazine

func _on_Character_update_ammo(chamber : int, magazine : int, reserve : int) -> void:
	label.text = str(magazine + chamber) + "/" + str(reserve)
