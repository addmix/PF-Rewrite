extends PopupDialog

var entry = preload("res://assets/ui/scoreboard_entry.tscn")
var entries := {}

onready var team1 = $"MarginContainer/VBoxContainer/Players/Team1"
onready var team2 = $"MarginContainer/VBoxContainer/Players/Team2"

onready var total1 = $"MarginContainer/VBoxContainer/Totals/Team1Total"
onready var total2 = $"MarginContainer/VBoxContainer/Totals/Team2Total"

func _ready() -> void:
	total1.set_name("")
	total2.set_name("")

func update_scoreboard() -> void:
	_connect_signals()

func _connect_signals() -> void:
	Server.GamemodeInstance.Teams.connect("player_added_to_team", self, "add_to_team")
	Server.GamemodeInstance.Teams.connect("player_removed_from_team", self, "remove_from_team")

func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("toggle_scoreboard"):
		get_tree().set_input_as_handled()
		if visible:
			hide()
		else:
			popup_centered()

func add_to_team(player, team : int) -> void:
	var instance = entry.instance()
	#do shit
	instance.player = player
	instance.player_name = player.player_name
	instance.player_id = player.player_id
	
	player.connect("update_kills", instance, "update_kills")
	player.connect("update_deaths", instance, "update_deaths")
	player.connect("update_assists", instance, "update_assists")
	player.connect("update_score", instance, "update_score")
	
	entries[player.player_id] = instance
	
	match team:
		0:
			team1.add_child(instance)
		1:
			team2.add_child(instance)
		_:
			pass

func remove_from_team(player) -> void:
	#remove from scoreboard
	entries[player.player_id].queue_free()
	#remove from dictionary
	entries.erase(player.player_id)

func update_kills() -> void:
	total1.set_kills(get_kills(team1))
	total2.set_kills(get_kills(team2))

func get_kills(team) -> int:
	var children = team.get_children()
	
	var total := 0
	
	for i in range(children.size() - 2):
		total += children[i + 2].kills
	
	return total

func update_deaths() -> void:
	total1.set_deaths(get_deaths(team1))
	total2.set_deaths(get_deaths(team2))

func get_deaths(team) -> int:
	var children = team.get_children()
	
	var total := 0
	
	for i in range(children.size() - 2):
		total += children[i + 2].deaths
	
	return total

func update_assists() -> void:
	total1.set_assists(get_assists(team1))
	total2.set_assists(get_assists(team2))

func get_assists(team) -> int:
	var children = team.get_children()
	
	var total := 0
	
	for i in range(children.size() - 2):
		total += children[i + 2].assists
	
	return total

func update_kdr() -> void:
	pass

func update_score() -> void:
	total1.set_score(get_score(team1))
	total2.set_score(get_score(team2))

func get_score(team) -> float:
	var children = team.get_children()
	
	var total := 0.0
	
	for i in range(children.size() - 2):
		total += children[i + 2].score
	
	return total
