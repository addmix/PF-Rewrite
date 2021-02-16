extends Spatial

var scores := []
var game_timer := Timer.new()
var countdown_timer := Timer.new()
var end_timer := Timer.new()

#teams
var teams := preload("res://gamemodes/boilerplates/teams/teams.tscn")
var Teams : Node

#spawning
var spawner := preload("res://gamemodes/boilerplates/playerspawner/playerspawner.tscn")
var Spawner : Node

export var options := {
	"game_time" : 300,
	"countdown_time": .1,
	"end_time": 10,
	"score": 200,
	"teams": 2,
	
}

signal game_started
signal game_ended
signal game_won

signal teams_created

func init() -> void:
	#initializes teams
	Teams = teams.instance()
	add_child(Teams, true)
	
	emit_signal("teams_created")
	
	#initializes player spawner
	Spawner = spawner.instance()
	add_child(Spawner, true)
	Spawner.Gamemode = self
	
	connect_signals()
	
	#sets team count
	Teams.team_count = options["teams"]
	#creates teams
	Teams.initialize_teams()
	#assigns players to teams
	Teams.assign_to_teams_random()
	
	#initialize scores for teams
	init_scores()
	
	init_Players()
	
	#initialize timers
	#countdown timer
	countdown_timer.wait_time = options["countdown_time"]
	countdown_timer.one_shot = true
	add_child(countdown_timer)
	
	#game timer
	game_timer.wait_time = options["game_time"]
	game_timer.one_shot = true
	add_child(game_timer)
	
	#end timer
	end_timer.wait_time = options["end_time"]
	end_timer.one_shot = true
	add_child(end_timer)
	
	#start countdown timer
	countdown_timer.start()
#	print("Starting countdown")

#connects signals
func connect_signals() -> void:
	#game signals
# warning-ignore:return_value_discarded
	connect("game_started", self, "on_game_start")
# warning-ignore:return_value_discarded
	connect("game_ended", self, "on_game_ended")
# warning-ignore:return_value_discarded
	connect("game_won", self, "on_game_won")
	
	#timer signals
# warning-ignore:return_value_discarded
	countdown_timer.connect("timeout", self, "on_countdown_finished")
# warning-ignore:return_value_discarded
	game_timer.connect("timeout", self, "on_game_time_finished")
# warning-ignore:return_value_discarded
	end_timer.connect("timeout", self, "on_end_time_finished")
	
	#player signals
# warning-ignore:return_value_discarded
	Players.connect("player_added", self, "on_Player_added")

func init_scores() -> void:
	for team in Teams.team_count:
		scores.append(0)

func init_Players() -> void:
#	print(Players.players)
	for player in Players.players:
		player.connect("died", self, "on_Player_died")

func on_Player_added(player : Player) -> void:
# warning-ignore:return_value_discarded
	player.connect("died", self, "on_Player_died")

func on_countdown_finished() -> void:
	countdown_timer.queue_free()
	emit_signal("game_started")

func on_game_time_finished() -> void:
	emit_signal("game_ended")

func on_end_time_finished() -> void:
	#removes players from teams, and removes teams
	Teams.denitialize_teams()

#when game starts
func on_game_start() -> void:
	game_timer.start()
#	print("Game start")
	Spawner.set_spawning(true)

#when game ends
func on_game_end() -> void:
#	print("Game end")
	game_timer.stop()
	
	Spawner.set_spawning(false)
	
	#end player control
	
	var highest_team := -1
	var highest_score := -1
	
	#this does not allow stalemates
	#allow that in a future revision
	
	#choose winner
	for team in range(scores.size()):
		#branchless way to get team with highest score
		highest_team = (team * int(scores[team] > highest_score)
		+ team * int(!scores[team] > highest_score)
		)
		#branchless way to get highest score
		highest_score = (scores[team] * int(scores[team] > highest_score)
		+ highest_score * int(!scores[team] > highest_score)
		)
	
	#emits signal that highest team won
	emit_signal("game_won", highest_team)

#when the game is won
func on_game_won(team : int) -> void:
	print("Team " + str(team) + " won")
	
	pass

#when player dies
func on_Player_died(player : Player) -> void:
#	print(player.player_id, " died")
	
	#get killer
	var killer = player.character_instance.damage_stack[0][0]
	
	#if death related to player somehow
	if killer.has_method("get_player"):
		
		if killer.get_player() == player:
			on_suicide(player)
		else:
			on_killed(player)
	
	#no player involved
	else:
		if killer == player.character_instance:
			on_reset(player)
		else:
			on_natural(player)
	
	pass

#when player scores
func player_scored(player : Player) -> void:
	#update score
	scores[player.team] += 1
	
	print(scores)
	
	#check score
	if scores[player.team] >= options["score"]:
		#emit game ended signal if one team has won
		emit_signal("game_ended")
	

func on_reset(player : Player) -> void:
	print(player.player_id, " reset")

func on_suicide(player : Player) -> void:
	print(player.player_id, " committed suicide")
	
	#punish suicide
	scores[player.team] -= 1
	
	print(scores)

func on_killed(player : Player) -> void:
	#get killer
	var killer = player.character_instance.damage_stack[0][0]
	
	print(player.player_id, " was killed by ", killer.player.player_id)
	
	player_scored(killer.player)

func on_natural(player : Player) -> void:
	print(player.player_id, " died from natural causes")
	
	#punish dying from non-enemies
	scores[player.team] -= 1
	
	print(scores)
