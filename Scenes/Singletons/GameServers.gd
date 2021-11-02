extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var port = 1912
var max_players = 100

var world_server_dict = {0: null,1: null,2: null,3: null,4: null}


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
	for index in world_server_dict:
		if world_server_dict[index] == null:
			world_server_dict[index] = gameserver_id
			break
	print("peer...connected", world_server_dict)

func _Peer_Disconnected(gameserver_id):
	print("Game Server: " + str(gameserver_id) + " Disconnected")		
	#remove the world server id from the world_server_dict
	for index in world_server_dict:
		if world_server_dict[index] == gameserver_id:
			world_server_dict[index] = null
	
func DistributeLoginToken(token, gameserver_id, world_to_connect_to):
	var gameserver_peer_id = world_server_dict[world_to_connect_to]
	if gameserver_peer_id != null:
		rpc_id(gameserver_peer_id, "ReceiveLoginToken", token)
	else:
		pass
		#send failed message to user
	
	#Store token alongside players account for reference after using remote func ReceivePlayerTokenForDatabase(player_id, token).
	print("Distribute token: ", token)

remote func ReceivePlayerTokenForDatabase(player_id, token):
	#This token will then be matched to the correct entry in the database and
#	player_id will be stored there. From then playerid will be used to make changes/read the database using rpc_get_sender_id() function
#	 that player will then be allowed to make a change / read that data in the database
	PlayerData.dbAddSessionToken(player_id, token)


