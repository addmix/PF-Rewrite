extends Control

onready var GamemodePopup : PopupDialog = $Margin/GamemodeSelect

onready var MultiplayerPopup : Popup = $Margin/Multiplayer
onready var OptionsPopup : Popup = $Margin/Options
onready var CreditsPopup : PopupDialog = $Margin/Credits
onready var QuitPopup : PopupDialog = $Margin/Quit
onready var LoginPopup : PopupDialog = $Margin/Login

#func _ready():
#	LoginPopup.popup_centered()

func _on_Singleplayer_pressed():
	GamemodePopup.popup_centered()

func _on_Multiplayer_pressed():
	MultiplayerPopup.popup_centered()
	MultiplayerPopup._connect_servers()

func _on_Options_pressed():
	OptionsPopup.popup_centered()

func _on_Credits_pressed():
	CreditsPopup.popup_centered()

func _on_Quit_pressed():
	QuitPopup.popup_centered()
