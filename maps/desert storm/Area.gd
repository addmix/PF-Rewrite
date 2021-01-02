extends Area



func _on_Area_body_entered(body):
	print(body)
	print(body.has_method("damage"))
	if body.has_method("damage"):
		body.damage(self, 100.0)
