extends Node

@export var port: int = 12345  # Default port for hosting
@export var max_players: int = 4  # Max number of players in a lobby

var peer = null 
var selected_difficulty: String
var lobby_code: String = ""  # Store the randomly generated lobby code
var player_list = {}

signal lobby_updated 

func host_game():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, max_players)
	
	if error != OK:
		print("Failed to start server:", error)
		return false 
		
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	
	lobby_code = str(randi() % 90000 + 10000)
	
	print("Hosting started on port", port, "with lobby code:", lobby_code)
	return true 
	
	
func join_game(ip_address: String):
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip_address, port)
	
	if error != OK:
		print("Failed to join server:", error)
		return false
	
	multiplayer.multiplayer_peer = peer
	return true
	
@rpc("any_peer", "reliable")
func join_lobby(player_name : String):
	var peer_id = multiplayer.get_remote_sender()
	
	if multiplayer.is_server():
		player_list[peer_id] = player_name
		print(player_name, "joined the lobby")
		
		update_lobby.rpc(player_list)
	
	
@rpc("authority", "reliable")
func update_lobby(updated_list):
	player_list = updated_list
	lobby_updated.emit()
	
func _on_player_connected(id):
		print("Player connected" , id)
	
	
func _on_player_disconnected(id):
		print("Player disconnected" , id)
	
	
	 
