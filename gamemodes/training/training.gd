extends Spatial


#signals
signal teams_created
signal game_started
signal game_ended
signal game_won


#variables
var game_timer := Timer.new()
var countdown_timer := Timer.new()
var end_timer := Timer.new()


#nodes
#teams
var teams := preload("res://gamemodes/boilerplates/teams/teams.tscn")
var Teams : Node

#spawning
var spawner := preload("res://gamemodes/boilerplates/playerspawner/playerspawner.tscn")
var Spawner : Node

#UI plugin
#var plugin := preload("res://gamemodes/teamdeathmatch/tdm_ui_plugin.tscn")
#var Plugin : MarginContainer


func init() -> void:
	#initializes teams
	Teams = teams.instance()
	add_child(Teams, true)
	
	emit_signal("teams_created")
	
	#initializes player spawner
	Spawner = spawner.instance()
	Spawner.Gamemode = self
	add_child(Spawner, true)
	
	#sets team count
	Teams.team_count = Server.game_settings["teams"]
	#creates teams
	Teams.initialize_teams()
	#assigns players to teams
	Teams.assign_to_teams_random()
	
	init_Players()
	
	#initializes UI plugin
#	Plugin = plugin.instance()
#	$"/root".add_child(Plugin, true)
	
	connect_signals()

#connects signals
func connect_signals() -> void:
	var _err : int
	#game signals
	_err = connect("game_started", self, "on_game_start")
	_err = connect("game_ended", self, "on_game_ended")
	_err = connect("game_won", self, "on_game_won")
	
	#player signals
	_err = Players.connect("player_added", self, "on_Player_added")
	
	#ui signals
#	_err = connect("score_updated", Plugin, "on_score_updated")

func init_Players() -> void:
#	print(Players.players)
	for player in Players.players:
		Players.players[player].connect("died", self, "on_Player_died")

func on_Player_added(player : Player) -> void:
# warning-ignore:return_value_discarded
	player.connect("died", self, "on_Player_died")

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
	
	
	#emits signal that highest team won
	emit_signal("game_won", highest_team)

#when the game is won
func on_game_won(team : int) -> void:
	print("Team " + str(team) + " won")
	
	pass

#when player dies
func on_Player_died(player : Player) -> void:
#	print(player.player_id, " died")
	if !player.character_instance.damage_stack.size() > 0:
		return
	
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

func on_reset(player : Player) -> void:
	print(player.player_id, " reset")

func on_suicide(player : Player) -> void:
	print(player.player_id, " committed suicide")

func on_killed(player : Player) -> void:
	#get killer
	var killer = player.character_instance.damage_stack[0][0]
	
	print(player.player_id, " was killed by ", killer.player.player_id)

func on_natural(player : Player) -> void:
	print(player.player_id, " died from natural causes")
