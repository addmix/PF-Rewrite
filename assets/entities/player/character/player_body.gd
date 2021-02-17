extends Area

var character : Character

func _ready() -> void:
	call_deferred("deferred")

func deferred() -> void:
	get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().connect("loaded", self, "_on_Character_loaded")

func _on_Character_loaded(c : Character) -> void:
	character = c

func hit(bullet) -> void:
	character.hit(bullet, self)
