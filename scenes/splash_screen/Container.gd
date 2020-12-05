extends Container

func _ready() -> void:
	var _err := get_tree().get_root().connect("size_changed", self, "resize")
	resize()

func resize() -> void:
	#position area
	var safe_area_size : Vector2 = OS.get_window_safe_area().size
	$ColorRect.rect_size = safe_area_size
	var text_min_dimension := min(safe_area_size.x, safe_area_size.y)
	$TextureRect.rect_size = Vector2(text_min_dimension, text_min_dimension)
	$TextureRect.rect_position = Vector2(safe_area_size.x / 2 - text_min_dimension / 2, 0)
