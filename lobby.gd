extends Control

@export var max_players = 4
var lobby_code: String
var players = {}

@onready var player_list: ItemList = $PlayerList
@onready var start_button: Button = $Start_Button
@onready var lobby_code_label: Label = $LobbyCode
@onready var difficulty_label: Label = $DifficultyLabel
@onready var player_list_lable: Label = $PlayerList/PlayerID


func _ready():
	if multiplayer.is_server():
		lobby_code_label.text = "" + NetworkManager.lobby_code
	print("Lobby code:", NetworkManager.lobby_code)
	NetworkManager.lobby_updated.connect(_update_lobby_display)

	if !multiplayer.is_server():
		var player_name = "Player" + str(randi() % 1000)
		NetworkManager.join_lobby.rpc(player_name)

	if NetworkManager:
		lobby_code_label.text = "Lobby Code: " + NetworkManager.lobby_code
		print("Lobby code:", NetworkManager.lobby_code)
		NetworkManager.lobby_updated.connect(_update_lobby_display)
	else:
		print("Error: NetworkManager is null")

func _update_lobby_display():
	player_list_lable.text = "Players in Lobby:\n"
	
	for name in NetworkManager.player_list.values():
		player_list_lable.text += name + "\n"
		
	if multiplayer.is_server():
		start_button.disabled = !(NetworkManager.player_list.size() >= 2 and NetworkManager.player_list.size() <= 4)


func _on_start_button_pressed():
	if multiplayer.is_server() and NetworkManager.player_list.size() >= 2:
		print("Game Starting!")
		NetworkManager.start_game.rpc()
