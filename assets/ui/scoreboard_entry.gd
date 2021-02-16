extends HBoxContainer

var player

var player_name := "Player"
var player_id := 0
var kills := 0
var deaths := 0
var assists := 0
var kdr := 0.0
var score := 0.0

onready var _name : Label = $name
onready var _kills : Label = $kills
onready var _deaths : Label = $deaths
onready var _assists : Label = $assists
onready var _kdr : Label = $kdr
onready var _score : Label = $score

func _ready():
	set_network_master(1)

func set_name(new_name : String) -> void:
	_name.text = new_name

func set_kills(k : int) -> void:
	kills = k
	_kills.text = str(k)
	update_kdr()

func update_kills() -> void:
	kills = player.kills
	_kills.text = str(kills)
	update_kdr()
	Server.Scoreboard.update_kills()

func set_deaths(d : int) -> void:
	deaths = d
	_deaths.text = str(d)
	update_kdr()

func update_deaths() -> void:
	deaths = player.deaths
	_deaths.text = str(deaths)
	update_kdr()
	Server.Scoreboard.update_deaths()

func set_assists(a : int) -> void:
	assists = a
	_assists.text = str(a)

func update_assists() -> void:
	assists = player.assists
	_assists.text = str(assists)
	Server.Scoreboard.update_assists()

func set_kdr(k : float) -> void:
	kdr = k
	_kdr.text = str(k)

func update_kdr() -> void:
	if deaths == 0:
		kdr = float(kills)
		_kdr.text = str(kdr)
	else:
		kdr = float(kills) / float(deaths)
		_kdr.text = str(kdr)
	Server.Scoreboard.update_kdr()

func set_score(s : float) -> void:
	score = s
	_score.text = str(s)

func update_score() -> void:
	score = player.score
	_score.text = str(score)
	Server.Scoreboard.update_score()
