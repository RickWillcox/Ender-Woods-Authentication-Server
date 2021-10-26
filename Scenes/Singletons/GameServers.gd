extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var port = 1912
var max_players = 100

var gameserverlist = {}

func _ready():
	StartServer()
	
func _process(_delta):
	if not custom_multiplayer.has_network_peer():
		return;
	custom_multiplayer.poll();

func StartServer():
	network.create_server(port, max_players)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	print("GameServerHub Started")
	
	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")
	
func _Peer_Connected(gameserver_id):
	print("Game Server: " + str(gameserver_id) + " Connected")
	##this is where you would load balance
	gameserverlist["GameServer1"] = gameserver_id
	print("peer...connected", gameserverlist)

func _Peer_Disconnected(gameserver_id):
	print("Game Server: " + str(gameserver_id) + " Disconnected")		
	
func DistributeLoginToken(token, gameserver):
	var gameserver_peer_id = gameserverlist[gameserver]
	rpc_id(gameserver_peer_id, "ReceiveLoginToken", token)
	
	#Store token alongside players account for reference after using remote func ReceivePlayerTokenForDatabase(player_id, token).
	print("Distribute token: ", token)

remote func ReceivePlayerTokenForDatabase(player_id, token):
	#This token will then be matched to the correct entry in the database and
#	player_id will be stored there. From then playerid will be used to make changes/read the database using rpc_get_sender_id() function
#	 that player will then be allowed to make a change / read that data in the database
	print("Player ID: ", player_id)
	print("Session Token: ", token)
	print("-----------------------")
	PlayerData.dbAddSessionToken(player_id, token)

remote func TestAuthUsingPlayerID(player_id, test_data):
	print("Player ID: ", player_id)
	print("Test Data: ", test_data)
	PlayerData.dbReadItem(player_id)
