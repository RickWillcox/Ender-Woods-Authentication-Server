extends Node

var network = NetworkedMultiplayerENet.new()
var max_servers = 5
var port = 1911
var hashed_password
var auth_hashed_password
var salt
func _ready():
	OS.set_window_position(Vector2(0,0))
	OS.set_window_size(Vector2(0,0))

	
	# Generate item database
	$ItemDatabaseGenerator.generate_item_database()
	$ItemDatabaseGenerator.generate_recipe_database()
	$ItemDatabaseGenerator.generate_itemmodifier_database()
	
	# free memory used by the script
	$ItemDatabaseGenerator.queue_free()
	
	start_server()
		
func start_server():
	network.create_server(port, max_servers)
	get_tree().set_network_peer(network)
	Logger.info("Authentication Server Started")
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")

func _peer_connected(gateway_id : int):
	Logger.info("Gateway %d Connected" % [gateway_id])
		
func _peer_disconnected(gateway_id : int):
	Logger.info("Gateway %d Disconnected" % [gateway_id])

remote func auththenicate_player(username : String, password : String, player_id : int):
	PlayerData.db_refresh_player_ids()	
	var token : String = "notoken"
	Logger.info("Authentication request received: %s" % [username])
	var gateway_id : int = get_tree().get_rpc_sender_id()
	var result : bool
	var auth_player_data : Array = PlayerData.db_check_unique_username(username)
	var username_exists = auth_player_data[0]
	var db_player_username = auth_player_data[1]
	var db_player_password = auth_player_data[2]
	var db_salt = auth_player_data[3]
	var db_can_login = auth_player_data[4]
	
	if db_can_login == 0:
		Logger.info("Username '%s' is banned\n" % [username])
		result = false
	elif username_exists == false:
		Logger.info("Username '%s' not found" % [username])
		result = false
	else:
		auth_hashed_password = generate_hashed_password(password, db_salt)
		if not db_player_password == auth_hashed_password:
			Logger.warn("Incorrect password for username: %s" % [username])
			result = false
		else:
			Logger.info("Username and Password found in database for: %s" % [username])
			result = true
			randomize()
			token = str(randi()).sha256_text() + str(OS.get_unix_time())
			var gameserver : String = "GameServer1"
			GameServers.distribute_login_token(token, gameserver, username)
			PlayerData.db_add_auth_token(username, token)
		
	Logger.info("Authentication result sent to gateway | Result: %s | Username %s" % [result, username])
	rpc_id(gateway_id, "authentication_results", result, player_id, token)

remote func create_account(username : String, password : String, player_id : int):
	Logger.info("Create Account Request: User: %s" % [username])
	PlayerData.db_refresh_player_ids()	
	var gateway_id : int = get_tree().get_rpc_sender_id()
	var result : bool
	var message : int
	if PlayerData.db_check_unique_username(username)[0] == true:
		Logger.warn("Failed to create account username '%s' already exists!" % [username])
		result = false
		message = 2
	else:
		result = true
		message = 3
		var salt : String= generate_salt()
		var hashed_password : String= generate_hashed_password(password, salt)
		PlayerData.db_create_account(username, hashed_password, salt)
	
	Logger.info("Create Account Result for Username: %s | Result: %s | Message: %d" %[username, result, message])
	rpc_id(gateway_id, "create_account_results", result, player_id, message)

func generate_salt():
	randomize()
	var salt : String = str(randi()).sha256_text()
	return salt

func generate_hashed_password(password : String, salt : String):
	var start_time : int = OS.get_system_time_msecs()
	var hashed_password : String = password
	var rounds : int = pow(2,18) #262,144 times
	while rounds > 0:
		hashed_password = (hashed_password + salt).sha256_text()
		rounds -= 1
	var time_taken : int = OS.get_system_time_msecs() - start_time
	Logger.info("Hashing took: " + str(time_taken) + "ms")
	return hashed_password
