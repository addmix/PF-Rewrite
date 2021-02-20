extends StaticBody

var DamageLabel : PackedScene = preload("res://assets/entities/damage_label/damage_label.tscn")
onready var label = DamageLabel.instance()

func _on_Skeleton_hit(projectile : Projectile, part : BodyPart) -> void:
	var damage := calculate_damage(projectile, part)
	create_damage_label(damage, part.get_global_transform().origin)

func calculate_damage(projectile : Projectile, part : BodyPart) -> float:
	var damage : float = projectile.weapon.data["Ballistics"]["Damage"] * projectile.weapon.data["Ballistics"][part.name]
	return damage

func create_damage_label(damage : float, position : Vector3) -> void:
	label.set_text(str(damage))
	$"/root".add_child(label)
	label.transform.origin = position
	label = DamageLabel.instance()

func _exit_tree() -> void:
	if label:
		label.free()
#	if DamageLabel:
#		DamageLabel.free()
