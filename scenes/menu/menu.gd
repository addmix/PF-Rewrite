extends Control

onready var singleplayerPopup = $Singleplayer
onready var multiplayerPopup = $Multiplayer
onready var optionsPopup = $Options
onready var creditsPopup = $Credits
onready var quitPopup = $Quit
onready var loginPopup = $Login

#func _ready():
#	loginPopup.popup_centered()

func _on_Singleplayer_pressed():
	singleplayerPopup.popup_centered()

func _on_Multiplayer_pressed():
	multiplayerPopup.popup_centered()
	multiplayerPopup._connect_servers()

func _on_Options_pressed():
	optionsPopup.popup_centered()

func _on_Credits_pressed():
	creditsPopup.popup_centered()

func _on_Quit_pressed():
	quitPopup.popup_centered()
