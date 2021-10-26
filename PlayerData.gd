extends Node

var PlayerIDs

#### Maria DB
var db: MariaDB
var res 

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
	res = db.query("DELETE FROM playeraccounts WHERE username = '%s';" % [username])
	dbReportError(res)
	return res

func dbRefreshPlayerIDs():
	PlayerIDs = db.query("SELECT * FROM playeraccounts;")
	dbReportError(res)

func dbAddAuthToken(username, auth_token):
	res = db.query("UPDATE playeraccounts SET auth_token = '%s' where username = '%s';" % [auth_token, username])
	dbReportError(res)

#player_ID becomes session_token here
func dbAddSessionToken(session_token, auth_token):
	res = db.query("UPDATE playeraccounts SET session_token = '%s' where auth_token = '%s';" % [session_token, auth_token])
	dbReportError(res)

func dbCheckUniqueUsername(username):
	var res
	for id in PlayerIDs:
		if id["username"] == username:
			res = [true, id["username"], id["password"], id["salt"]]
			break
		else:
			res = [false, null, null, null]
	return res	

func dbReportError(err):
	if err != OK:
		print("Error: ", err)
		return

###Functions only used for Testing
	
func dbCheckAuthTokenExists(auth_token):
	for id in PlayerIDs:
		if id["auth_token"] == auth_token:
			return true
	return false

func dbCheckSessionTokenExists(session_token):
	for id in PlayerIDs:
		if id["session_token"] == str(session_token):
			return true
	return false



