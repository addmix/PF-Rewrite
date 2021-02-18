extends AudioStreamPlayer

signal color_changed
signal size_changed
signal spacing_changed

onready var color : Color = ProjectSettings.get_setting("gameplay/hitmarker/color") setget set_color
onready var size : Vector2 = ProjectSettings.get_setting("gameplay/hitmarker/size") setget set_size
onready var spacing : float = ProjectSettings.get_setting("gameplay/hitmarker/spacing") setget set_spacing

func set_color(c : Color) -> void:
	color = c
	emit_signal("color_changed")

func set_size(s : Vector2) -> void:
	size = s
	emit_signal("size_changed")

func set_spacing(s : float) -> void:
	spacing = s
	emit_signal("spacing_changed")

onready var tabs := [ColorRect.new(), ColorRect.new(), ColorRect.new(), ColorRect.new()]

func _ready() -> void:
	for rect in tabs:
		$Control/Panel.add_child(rect)
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	update_color()
	update_size()
	update_spacing()

func update_color() -> void:
	for rect in tabs:
		rect.color = color

func update_size() -> void:
	for rect in tabs:
		rect.rect_size = size

func update_spacing() -> void:
	for rect in tabs.size():
		var x : float= 90.0 * rect
		tabs[rect].rect_position = Vector2(spacing, -size.y / 2).rotated(deg2rad(x))
		tabs[rect].rect_rotation = x
		
		

func _on_AudioStreamPlayer_finished() -> void:
	queue_free()
