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

func init() -> void:
	#initializes teams
	Teams = teams.instance()
	add_child(Teams, true)
	
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
	print("Starting countdown")

#connects signals
func connect_signals() -> void:
	connect("game_started", self, "on_game_start")
	connect("game_ended", self, "on_game_ended")
	connect("game_won", self, "on_game_won")
	countdown_timer.connect("timeout", self, "on_countdown_finished")
	game_timer.connect("timeout", self, "on_game_time_finished")
	end_timer.connect("timeout", self, "on_end_time_finished")

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
	print("Game start")
	Spawner.set_spawning(true)

#when game ends
func on_game_end() -> void:
	print("Game end")
	game_timer.stop()
	
	Spawner.set_spawning(false)
	
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
func on_player_died(player : int, cause : int) -> void:
	
	
	pass

#when player scores
func player_scored(player) -> void:
	#update score
	scores[player.team] += 1
	
	#check score
	if scores[player.team] >= options["score"]:
		#emit game ended signal if one team has won
		emit_signal("game_ended")
