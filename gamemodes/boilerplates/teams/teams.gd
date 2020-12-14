extends Node

#number of teams
var team_count := 2
#holds all the team's arrays
var teams := []

#creates teams
func initialize_teams() -> void:
	#adds an array for each team into the teams array
	for i in range(team_count):
		teams.append([])

#removes teams
func denitialize_teams() -> void:
	#remove players from teams
	var players = get_tree().get_nodes_in_group("players")
	for player in players:
		#remove player from their team's group
		player.remove_from_group("Team" + str(player.team))
		#sets player's team to null
		player.team = null
	
	#remove teams
	teams = []

#team balance algorithms

#assigns players to teams by looping through the teams
func assign_to_teams() -> void:
	var players = get_tree().get_nodes_in_group("players")
	
	var index := 0
	#for each player
	for player in players:
		#sets player's team
		player.team = index % team_count
		#adds player to team group
		player.add_to_group("Team" + str(player.team))
		
		index += 1

#will assign players to teams randomly while keeping the teams even
func assign_to_teams_random() -> void:
	var players = get_tree().get_nodes_in_group("players")
	
	var index := 0
	while players.size() > 0:
		#gets random player from list
		var player = players[randi() % players.size()]
		
		#sets player's team
		player.team = index % team_count
		#adds player to team group
		player.add_to_group("Team" + str(player.team))
		
		index += 1
