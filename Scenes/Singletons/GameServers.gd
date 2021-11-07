extends Node

var network : NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
var gateway_api : MultiplayerAPI = MultiplayerAPI.new()
var port : int = 1912
var max_players : int = 100

var gameserverlist : Dictionary = {}

func _ready():
	start_server()
	
func _process(_delta):
	if not custom_multiplayer.has_network_peer():
		return;
	custom_multiplayer.poll();

func start_server():
	network.create_server(port, max_players)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	Logger.info("GameServerHub Started")
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")
	
func _peer_connected(gameserver_id : int):
	Logger.info("Game Server: %d Connected" % [gameserver_id])
	##this is where you would load balance
	gameserverlist["GameServer1"] = gameserver_id
	Logger.info("Gameserver list "+ str(gameserverlist))

func _peer_disconnected(gameserver_id : int):
	Logger.info("Game Server: %d Disconnected" % [gameserver_id])
	
func distribute_login_token(token : String, gameserver : String, username : String):
	var gameserver_peer_id : int = gameserverlist[gameserver]
	rpc_id(gameserver_peer_id, "ReceiveLoginToken", token)
	#Store token alongside players account for reference after using remote func ReceivePlayerTokenForDatabase(player_id, token).
	Logger.info("Distribute token: Username: %s | Token: %s| GameServer: %s" % [username, token, gameserver])

remote func ReceivePlayerTokenForDatabase(player_id : int, token : String):
	#This token will then be matched to the correct entry in the database and
#	player_id will be stored there. From then playerid will be used to make changes/read the database using rpc_get_sender_id() function
#	 that player will then be allowed to make a change / read that data in the database
	var world_server_id : int = get_tree().get_rpc_sender_id()
	Logger.info("Received Player Auth token, PlayerID: %s | Auth Token: %s" % [player_id, token])
	PlayerData.db_add_session_token(player_id, token, world_server_id, false)
	
func send_updated_inventory_to_client(inventory_data : Dictionary, world_server_id : int, session_token : int):
	rpc_id(world_server_id, "ReceivePlayerInventory", inventory_data, session_token)

remote func GetAllItemsFromDatabase():
	var res : Array = PlayerData.db_get_all_items_database()
	# Rearrange item data as a dictionary so that Client and WorldServer can easily get item data using item_id
	var item_db : Dictionary = {}
	for row in res:
		item_db[row.item_id] = row
	send_all_item_data_to_world_servers(item_db)

func send_all_item_data_to_world_servers(all_item_data : Dictionary):
	rpc_id(0, "ReceiveItemData", all_item_data)	

remote func update_inventory(session_token : int, inventory : Dictionary):
	PlayerData.db_update_inventory(session_token, inventory)
