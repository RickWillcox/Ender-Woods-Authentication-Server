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

func dbCreateAccount(username, password, salt, test_case):
	print("Attempting to create account")
	res = db.query("INSERT INTO playeraccounts (username, password, salt) VALUES ('%s', '%s', '%s');" % [username, password, salt])
	if res == OK and not test_case:
		dbAddItemSlots(username)
		pass
	dbReportError(res)
	return res

func dbAddItemSlots(username):
	var acc_id = int(dbReturnAccountData(username)[0]["account_id"])
	print("ACC ID ", acc_id)
	for i in range(1, 36):
			res = db.query("INSERT INTO playerinventories (account_id, item_slot) VALUES ('%d', '%d');" % [acc_id, i])
	return res

func dbDeleteAccount(username, password, salt):
	print("Attempting to delete account")
	var user_data = dbReturnAccountData(username)
	if user_data[0]["username"] == username and user_data[0]["password"] == password and user_data[0]["salt"] == salt:
		var acc_id = int(user_data[0]["account_id"])
		#Delete Account and Inventory
		res = db.query("""
		DELETE FROM playeraccounts WHERE username = '%s'; 
		DELETE FROM playerinventories WHERE account_id = '%d';""" % [username, acc_id])
	dbReportError(res)
	return res

func dbRefreshPlayerIDs():
	PlayerIDs = db.query("SELECT * FROM playeraccounts;")
	dbReportError(res)

func dbAddAuthToken(username, auth_token):
	res = db.query("UPDATE playeraccounts SET auth_token = '%s' where username = '%s';" % [auth_token, username])
	dbReportError(res)
	return res

#player_ID becomes session_token here
func dbAddSessionToken(session_token, auth_token):
	res = db.query("UPDATE playeraccounts SET session_token = '%s' where auth_token = '%s';" % [session_token, auth_token])
	dbReportError(res)
	return res

func dbCheckUniqueUsername(username):
	var res = [false, null, null, null, null]
	for id in PlayerIDs:
		if id["username"] == username:
			res = [true, id["username"], id["password"], id["salt"], id["can_login"]]
			break
	return res

func dbReturnAccountData(username):
	return db.query("SELECT * FROM playeraccounts WHERE username = '%s'" % [username])

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



