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
	print("Game Server: %d Connected" % [gameserver_id])
	##this is where you would load balance
	gameserverlist["GameServer1"] = gameserver_id
	print("Player Connected ", gameserverlist)

func _Peer_Disconnected(gameserver_id):
	print("Game Server: %d Disconnected" % [gameserver_id])		
	
func DistributeLoginToken(token, gameserver):
	var gameserver_peer_id = gameserverlist[gameserver]
	rpc_id(gameserver_peer_id, "ReceiveLoginToken", token)
	
	#Store token alongside players account for reference after using remote func ReceivePlayerTokenForDatabase(player_id, token).
	print("Distribute token: ", token)

remote func ReceivePlayerTokenForDatabase(player_id, token):
	#This token will then be matched to the correct entry in the database and
#	player_id will be stored there. From then playerid will be used to make changes/read the database using rpc_get_sender_id() function
#	 that player will then be allowed to make a change / read that data in the database
	var world_server_id = get_tree().get_rpc_sender_id()
	print("Received Player Auth token, PlayerID: %s | Auth Token: %s" % [player_id, token])
	PlayerData.dbAddSessionToken(player_id, token, world_server_id, false)
	
func SendUpdatedInventoryToClient(inventory_data, world_server_id, session_token):
	rpc_id(world_server_id, "ReceivePlayerInventory", inventory_data, session_token)

remote func GetAllItemsFromDatabase():
	var res = PlayerData.dbGetAllItemsInDatabase()
	# Rearrange item data as a dictionary so that Client and WorldServer can easily get item data using item_id
	var item_db = {}
	for row in res:
		item_db[int(row.item_id)] = row
	SendAllItemDataToWorldServers(item_db)

func SendAllItemDataToWorldServers(all_item_data):
	print(all_item_data)
	rpc_id(0, "ReceiveItemData", all_item_data)	

remote func update_inventory(session_token, inventory):
	print(["Update new inventory: ", inventory.left(20), " | Session Token: ", session_token])
	PlayerData.db_update_inventory(session_token, inventory)
