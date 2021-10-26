extends Node

#const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
##var db
#var db_path = "user://PlayerLoginData.db"
var PlayerIDs

#### Maria DB
var db: MariaDB
var res 

func _ready():
#	dbRefreshDatabase()	
	pass

func dbConnect():
	db = MariaDB.new()
	print("Connecting to Database")
	res = db.connect_db("127.0.0.1", 3306, "PlayerData", "root", "root")
	if res != OK:
		print("Failed to connect to the database")
		return
	print("Connected\n")

func dbCreateAccount(username, password, salt):
	print("Attempting to create account")
	res = db.query("INSERT INTO playeraccounts (username, password, salt) VALUES ('%s', '%s', '%s');" % [username, password, salt])
	dbReportError(res)
	print("Res: ", res)
	return res

func dbDeleteAccount(username, password, salt):
	print("Attempting to delete account")
	res = db.query("DELETE FROM playeraccounts WHERE username = '" + str(username) + "';")
	dbReportError(res)
	return res

func dbCheckUniqueUsername(username):
	var res
	for i in range (0, PlayerIDs.size()):
		if PlayerIDs[i]["username"] == username:
			return [true, username, PlayerIDs[i]["password"], PlayerIDs[i]["salt"]]
		else:
			res = [false, null, null, null]
	return res

func dbRefreshPlayerIDs():
	print("Refreshing PlayerIDs")
	PlayerIDs = db.query("SELECT * FROM playeraccounts;")
	dbReportError(res)

func dbAddAuthToken(username, auth_token):
	print("Print Adding Auth token")
	res = db.query("UPDATE playeraccounts SET auth_token = '%s' where username = '%s'" % [auth_token, username])
	dbReportError(res)

#player_ID becomes session_token here
func dbAddSessionToken(player_id, auth_token):
	print("Adding Session Token")
	res = db.query("UPDATE playeraccounts SET session_token = '%s' where auth_token = '%s'" % [player_id, auth_token])
	dbReportError(res)
	
#func dbReadItem(player_id):
#	db = SQLite.new()
#	db.path = db_path
#	db.open_db()
#	db.query("select ID from PlayerLoginData where session_token = '" + str(player_id) + "'")
#	var result = db.query_result[0]["ID"]
#	print(result)
#	db.query("Select * from Inventory where player_id = '" + str(result) + "'")
#	var inven = db.query_result
#	print(inven)

func dbReportError(err):
	if err != OK:
		print("Failed to insert data into hello_world! Error: %d", err)
		return

