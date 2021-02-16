extends Projectile
class_name Bullet

#when instanced
func _init() -> void:
	add_to_group("Bullets")
