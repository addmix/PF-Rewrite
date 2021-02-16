extends Node

signal player_added_to_team
signal player_removed_from_team

func _ready() -> void:
# warning-ignore:return_value_discarded
	Players.connect("player_added", self, "on_Player_added")
# warning-ignore:return_value_discarded
	Players.connect("player_removed", self, "on_Player_removed")

func on_Player_added(player : Player) -> void:
#	print("Player ", player.player_id, " added")
	assign_to_team(player, get_team_with_least_players())

func on_Player_removed(player : Player) -> void:
	remove_from_team(player)

#number of teams
var team_count := 2
#holds all the team's arrays
var teams := []

#creates teams
func initialize_teams() -> void:
	#adds an array for each team into the teams array
# warning-ignore:unused_variable
	for i in range(team_count):
		teams.append([])

#removes teams
func denitialize_teams() -> void:
	#remove players from teams
# warning-ignore:unused_variable
	var players = get_tree().get_nodes_in_group("players")
	for player in Players.players:
		remove_from_team(player)
	
	#remove teams
	teams = []

#assigns player to team
func assign_to_team(player : Player, team : int) -> void:
	#sets player's team
	player.team = team
	#adds player to team group
	player.add_to_group("Team" + str(player.team))
	#adds player to array
	teams[team].append(player)
	
	emit_signal("player_added_to_team", player, team)

#removes player from team
func remove_from_team(player : Player) -> void:
	#remove from team array
	teams[player.team].erase(player)
	#remove player from their team's group
	player.remove_from_group("Team" + str(player.team))
	#sets player's team to null
	player.team = -1
	
	emit_signal("player_removed_from_team", player)

#team balance algorithms

#assigns players to teams by looping through the teams
func assign_to_teams() -> void:
	var players = get_tree().get_nodes_in_group("players")
	
	var index := 0
	for player in players:
		assign_to_team(player, index % team_count)
		index += 1

#will assign players to teams randomly while keeping the teams even
func assign_to_teams_random() -> void:
	var players = get_tree().get_nodes_in_group("players")
	
	var index := 0
	while players.size() > 0:
		#gets random player from list and adds them to team
		assign_to_team(players[randi() % players.size()], index % team_count)
		index += 1

#gets team with least amount of players
func get_team_with_least_players() -> int:
	var team := 0
	
	for i in range(teams.size()):
		team = i * int(teams[i].size() < teams[team].size()) + team * int(!teams[i].size() < teams[team].size())
	
	return team

#gets team with lowest score
