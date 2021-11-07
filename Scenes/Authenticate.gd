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
	# free memory used by the script
	$ItemDatabaseGenerator.queue_free()
	
	StartServer()
		
func StartServer():
	network.create_server(port, max_servers)
	get_tree().set_network_peer(network)
	Logger.info("Authentication Server Started")
	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")

func _Peer_Connected(gateway_id):
	Logger.info("Gateway %d Connected" % [gateway_id])
		
func _Peer_Disconnected(gateway_id):
	Logger.info("Gateway %d Disconnected" % [gateway_id])

remote func AuthenticatePlayer(username, password, player_id):
	PlayerData.dbRefreshPlayerIDs()	
	var token
	Logger.info("Authentication request received: %s" % [username])
	var gateway_id = get_tree().get_rpc_sender_id()
	var result
	var auth_player_data = PlayerData.dbCheckUniqueUsername(username)
	var username_exists = auth_player_data[0]
	var db_player_username = auth_player_data[1]
	var db_player_password = auth_player_data[2]
	var db_salt = auth_player_data[3]
	var db_can_login = auth_player_data[4]
	
	if db_can_login == 0:
		print("Username '%s' is banned\n" % [username])

		result = false
	elif username_exists == false:
		Logger.info("Username '%s' not found" % [username])
		result = false
	else:
		auth_hashed_password = GenerateHashedPassword(password, db_salt)
		if not db_player_password == auth_hashed_password:
			Logger.warn("Incorrect password for username: %s" % [username])
			result = false
		else:
			Logger.warn("Username and Password found in database for: %s" % [username])
			result = true
			
			randomize()
			token = str(randi()).sha256_text() + str(OS.get_unix_time())
			var gameserver = "GameServer1"
			GameServers.DistributeLoginToken(token, gameserver)
			PlayerData.dbAddAuthToken(username, token)
		
	
	Logger.info("Authentication result sent to gateway | Result: %s | Username %s" % [result, username])
	rpc_id(gateway_id, "AuthenticationResults", result, player_id, token)

remote func CreateAccount(username, password, player_id):
	Logger.info("Create Account Request: User: %s" % [username])
	PlayerData.dbRefreshPlayerIDs()	
	var gateway_id = get_tree().get_rpc_sender_id()
	var result
	var message
	if PlayerData.dbCheckUniqueUsername(username)[0] == true:
		Logger.warn("Failed to create account username '%s' already exists!" % [username])
		result = false
		message = 2
	else:
		result = true
		message = 3
		var salt = GenerateSalt()
		var hashed_password = GenerateHashedPassword(password, salt)
		PlayerData.dbCreateAccount(username, hashed_password, salt, false)
	
	Logger.info("Create Account Result for Username: %s | Result: %s | Message: %d" %[username,result,message])
	rpc_id(gateway_id, "CreateAccountResults", result, player_id, message)

func GenerateSalt():
	randomize()
	var salt = str(randi()).sha256_text()
	return salt

func GenerateHashedPassword(password, salt):
	var start_time = OS.get_system_time_msecs()
	var hashed_password = password
	var rounds = pow(2,18) #262,144 times
	while rounds > 0:
		hashed_password = (hashed_password + salt).sha256_text()
		rounds -= 1
	var time_taken = OS.get_system_time_msecs() - start_time
	Logger.info("Hashing took: " + str(time_taken) + "ms")
	return hashed_password
