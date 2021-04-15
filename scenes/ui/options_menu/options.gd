extends Popup

var setting_scene : PackedScene = preload("res://scenes/ui/options_menu/option.tscn")

var FLOAT : PackedScene = preload("res://scenes/ui/types/float.tscn")
var BOOL : PackedScene = preload("res://scenes/ui/types/bool.tscn")
var COLOR : PackedScene = preload("res://scenes/ui/types/color.tscn")
var VECTOR2 : PackedScene = preload("res://scenes/ui/types/vector2.tscn")
var VECTOR3 : PackedScene = preload("res://scenes/ui/types/vector3.tscn")

onready var gameplay : Control = $VBox/TabContainer/Gameplay/Gameplay
onready var graphics : Control = $VBox/TabContainer/Graphics/Graphics
onready var controls : Control = $VBox/TabContainer/Controls/Controls
onready var audio : Control = $VBox/TabContainer/Audio/Audio

var nodes := []

func _ready() -> void:
	call_deferred("load_settings")

func load_settings() -> void:
	for category in displayed_settings.keys():
		for setting in displayed_settings[category].keys():
			var setting_instance : HBoxContainer = setting_scene.instance()
			
			var string : String = category + "/" + setting
			setting_instance.name = string
			setting_instance.set_text(displayed_settings[category][setting]["name"])
			setting_instance.setting = string
			nodes.append(setting_instance)
			var type : int = typeof(ProjectSettings.get_setting(string))
			
			var decision : PackedScene
			match type:
				TYPE_BOOL:
					decision = BOOL
				TYPE_INT:
					decision = FLOAT
				TYPE_REAL:
					decision = FLOAT
				TYPE_VECTOR2:
					decision = VECTOR2
				TYPE_VECTOR3:
					decision = VECTOR3
				TYPE_COLOR:
					decision = COLOR
			
			var type_instance = decision.instance()
			
			var keys : Array = displayed_settings[category][setting].keys()
			
			if keys.has("min"):
				type_instance.set_min(displayed_settings[category][setting]["min"])
			if keys.has("max"):
				type_instance.set_max(displayed_settings[category][setting]["max"])
			if keys.has("step"):
				type_instance.set_step(displayed_settings[category][setting]["step"])
			if keys.has("options"):
				type_instance.set_options(displayed_settings[category][setting]["options"])
			
			setting_instance.type = type_instance
			setting_instance.add_child(type_instance)
			
			var tab : Control
			match category:
				"gameplay":
					tab = gameplay
				"graphics":
					tab = graphics
				"controls":
					tab = controls
				"audio":
					tab = audio
			
			tab.add_child(setting_instance)

const displayed_settings := {
	"gameplay": {
		"hitmarker/color": {
			"name": "Hitmarker Color",
		},
		"hitmarker/size": {
			"name": "Hitmarker Size",
			"min": Vector2(0, 0),
		},
		"hitmarker/spacing": {
			"name": "Hitmarker Spacing",
			"min": 0.0,
			"step": 1.0,
		},
	},
	"controls": {
		"invert_x": {
			"name": "Invert X",
		},
		"invert_y": {
			"name": "Invert Y",
		},
		"mouse/sensitivity": {
			"name": "Mouse Sensitivity",
			"min": Vector2(0, 0),
			"step": 0.01,
		},
	},
	"graphics": {},
	
	"audio": {
		"volume/master_volume": {
			"name": "Master",
			"min": 0.0,
			"max": 1.5,
			"step": .01,
		},
		"volume/music_volume": {
			"name": "Music",
			"min": 0.0,
			"max": 1.5,
			"step": .01,
		},
		"volume/ambient_volume": {
			"name": "Ambient",
			"min": 0.0,
			"max": 1.5,
			"step": .01,
		},
		"volume/sfx_volume": {
			"name": "Sound Effects",
			"min": 0.0,
			"max": 1.5,
			"step": .01,
		},
		"volume/hitmarker_volume": {
			"name": "Hitmarker",
			"min": 0.0,
			"max": 1.5,
			"step": .01,
		},
		"volume/voice_emit_volume": {
			"name": "Voice Emit Volume",
			"min": 0.0,
			"max": 1.5,
			"step": .01,
		},
		"volume/voice_recieve_volume": {
			"name": "Voice Recieve Volume",
			"min": 0.0,
			"max": 1.5,
			"step": .01,
		},
	},
}

#ui logic

onready var revert_confirmation : ConfirmationDialog = $RevertConfirmation

func _on_Apply_pressed() -> void:
	for node in nodes:
		ProjectSettings.set_setting(node.setting, node.get_value())
# warning-ignore:return_value_discarded
	ProjectSettings.save()
	
	Settings.load_settings()
	
	hide()

func _on_Revert_pressed() -> void:
	revert_confirmation.popup_centered()

func _on_RevertConfirmation_confirmed() -> void:
	for node in nodes:
		var revert = ProjectSettings.property_get_revert(node.setting)
		ProjectSettings.set_setting(node.setting, revert)
		node.set_value(revert)
# warning-ignore:return_value_discarded
	ProjectSettings.save()

func _on_Cancel_pressed() -> void:
	#if unapplied changes
	#popup
	#else
	hide()


func _unhandled_input(event : InputEvent) -> void:
	if visible:
		get_tree().set_input_as_handled()
