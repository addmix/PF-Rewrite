extends MarginContainer

onready var container : VBoxContainer = $VBoxContainer
var bar : PackedScene = preload("res://gamemodes/teamdeathmatch/team_bar.tscn")
var bars := []

func _ready() -> void:
	for team in Server.GamemodeInstance.Teams.teams:
		var instance : ProgressBar = bar.instance()
		instance.max_value = Server.GamemodeInstance.options["score"]
		instance.name = str(team)
		container.add_child(instance)
		
		bars.append(instance)

func on_score_updated(scores : Array) -> void:
	for score in scores.size():
		bars[score].value = scores[score]
