extends ViewportContainer

onready var viewport : Viewport = $Viewport

func _ready() -> void:
	viewport.size = rect_size
	get_tree().get_root().connect("size_changed", self, "on_size_changed")

func on_size_changed() -> void:
	viewport.size = rect_size
