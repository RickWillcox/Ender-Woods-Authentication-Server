extends Node

var network = NetworkedMultiplayerENet.new()
var max_servers = 5
var port = 1911
var hashed_password
var auth_hashed_password
var salt
func _ready():
	OS.set_window_position(Vector2(0,0))
	StartServer()
		
func StartServer():
	network.create_server(port, max_servers)
	get_tree().set_network_peer(network)
	print("Authentication Server Started\n")
	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")

func _Peer_Connected(gateway_id):
	print("Gateway %d Connected\n" % [gateway_id])
		
func _Peer_Disconnected(gateway_id):
	print("Gateway %d Disconnected\n" % [gateway_id])

remote func AuthenticatePlayer(username, password, player_id):
	print(password)
	PlayerData.dbRefreshPlayerIDs()	
	var token
	print("Authentication request received: %s\n" % [username])
	var gateway_id = get_tree().get_rpc_sender_id()
	var result
	var auth_player_data = PlayerData.dbCheckUniqueUsername(username)
	var username_exists = auth_player_data[0]
	var db_player_username = auth_player_data[1]
	var db_player_password = auth_player_data[2]
	var db_salt = auth_player_data[3]
	var db_can_login = auth_player_data[4]
	
	if db_can_login == str(0):
		print("Username '%s' is banned\n" % [username])
		result = false
	elif username_exists == false:
		print("Username '%s' not found\n" % [username])
		result = false
	else:
		auth_hashed_password = GenerateHashedPassword(password, db_salt)
		if not db_player_password == auth_hashed_password:
			print(db_player_password)
			print(auth_hashed_password)
			print("Incorrect password for username: %s\n" % [username])
			result = false
		else:
			print("Username and Password found in database for: %s\n" % [username])
			result = true
			
			randomize()
			token = str(randi()).sha256_text() + str(OS.get_unix_time())
			var gameserver = "GameServer1"
			GameServers.DistributeLoginToken(token, gameserver)
			PlayerData.dbAddAuthToken(username, token)
		
	
	print("Authentication result sent to gateway | Result: %s | Username %s\n" % [result, username])
	rpc_id(gateway_id, "AuthenticationResults", result, player_id, token)

remote func CreateAccount(username, password, player_id):
	print("Create Account Request: User: %s\n" % [username])
	PlayerData.dbRefreshPlayerIDs()	
	var gateway_id = get_tree().get_rpc_sender_id()
	var result
	var message
	if PlayerData.dbCheckUniqueUsername(username)[0] == true:
		print("Failed to create account username '%s' already exists!\n" % [username])
		result = false
		message = 2
	else:
		result = true
		message = 3
		var salt = GenerateSalt()
		var hashed_password = GenerateHashedPassword(password, salt)
		PlayerData.dbCreateAccount(username, hashed_password, salt, false)
	
	print("Create Account Result for Username: %s | Result: %s | Message: %d\n" %[username,result,message])	
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
	print("Hashing took: " + str((OS.get_system_time_msecs() - start_time)) + "ms\n")
	return hashed_password
