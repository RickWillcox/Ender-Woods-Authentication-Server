extends Node

var PlayerIDs

#### Maria DB
var res 
var res1
var res2
var res3
var db : MariaDB

func _ready():
	db = DatabaseConnection.db
	print(db.query("SHOW TABLES;"))
########### Account Functions ##############

func dbCreateAccount(username, password, salt, test_case):
	print("Attempting to create account: Username: %s | Password{5}: %s, | Salt{5}: %s" % [username, password.left(5), salt.left(5)])
	res = db.query("INSERT INTO playeraccounts (username, password, salt) VALUES ('%s', '%s', '%s');" % [username, password, salt])
	if res == OK:
		var account_id = db.query("SELECT account_id FROM playeraccounts WHERE username='%s' LIMIT 1" % [username])[0].account_id
		# add all basic items into players backpack
		db.query("INSERT INTO playerinventories (account_id, item_slot, item_id) VALUES (%s, %d, %d );" % [account_id, 10, 1])
		db.query("INSERT INTO playerinventories (account_id, item_slot, item_id) VALUES (%s, %d, %d );" % [account_id, 11, 2])
		db.query("INSERT INTO playerinventories (account_id, item_slot, item_id) VALUES (%s, %d, %d );" % [account_id, 12, 3])
		db.query("INSERT INTO playerinventories (account_id, item_slot, item_id) VALUES (%s, %d, %d );" % [account_id, 13, 4])
		db.query("INSERT INTO playerinventories (account_id, item_slot, item_id) VALUES (%s, %d, %d );" % [account_id, 14, 5])
		db.query("INSERT INTO playerinventories (account_id, item_slot, item_id) VALUES (%s, %d, %d );" % [account_id, 15, 6])
		db.query("INSERT INTO playerinventories (account_id, item_slot, item_id) VALUES (%s, %d, %d );" % [account_id, 16, 7])
		db.query("INSERT INTO playerinventories (account_id, item_slot, item_id) VALUES (%s, %d, %d );" % [account_id, 17, 8])
		db.query("INSERT INTO playerinventories (account_id, item_slot, item_id) VALUES (%s, %d, %d );" % [account_id, 18, 9])
		db.query("INSERT INTO playerinventories (account_id, item_slot, item_id) VALUES (%s, %d, %d );" % [account_id, 19, 10])
		
		# some duplicates for testing
		db.query("INSERT INTO playerinventories (account_id, item_slot, item_id) VALUES (%s, %d, %d );" % [account_id, 20, 2])
		db.query("INSERT INTO playerinventories (account_id, item_slot, item_id) VALUES (%s, %d, %d );" % [account_id, 21, 3])
	dbReportError(res)
	return res

func dbDeleteAccount(session_token, username, password, salt):
	print("Attempting to delete account: Username: %s | Password{5}: %s, | Salt{5}: %s" % [username, password.left(5), salt.left(5)])
	var user_data = dbReturnAccountData(session_token)
	if user_data[0]["username"] == username and user_data[0]["password"] == password and user_data[0]["salt"] == salt:
		var acc_id = int(user_data[0]["account_id"])
		#Delete Account and Inventory
		res = db.query("""
		DELETE FROM playeraccounts WHERE username = '%s'; 
		DELETE FROM playerinventories WHERE account_id = '%d';""" % [username, acc_id])
	dbReportError(res)
	return res

func dbAddAuthToken(username, auth_token):
	print("Adding Auth token: Username: %s | Auth Token{10}: %s \n" % [username, str(auth_token).left(10)])
	res = db.query("UPDATE playeraccounts SET auth_token = '%s' WHERE username = '%s';" % [auth_token, username])
	dbReportError(res)
	return res

func dbAddSessionToken(session_token, auth_token, world_server_id, test_case):
	#player_ID becomes session_token here
	print("Adding Session token: Session Token{10}: %s | Auth Token{5}: %s \n" % [str(session_token).left(10), str(auth_token).left(5)])
	res = db.query("UPDATE playeraccounts SET session_token = '%s' WHERE auth_token = '%s';" % [session_token, auth_token])
	dbReportError(res)
	if res == OK and not test_case:
		print("Session Token Addition Successful Sending Inventory Data to World server for Session Token{10}: %s \n" % [str(session_token).left(10)])
		var inventory_data = dbGetInventory(session_token)
		GameServers.SendUpdatedInventoryToClient(inventory_data, world_server_id, session_token)
		pass
	else:
		#Send failed to add session token code if needed
		pass
	return res

func dbAddWorldServerID(session_token, world_server_id):
	res = db.query("UPDATE playeraccounts SET world_server_id = %s WHERE session_token = %s" %[world_server_id, session_token])
	dbReportError(res)
	return res
	
########### Inventory ##############

func dbGetInventory(session_token):
	var acc_id = int(dbReturnAccountData(session_token)[0]["account_id"])
	# Rearrange inventory as a dictionary
	var inventory = {}
	res = db.query("SELECT * FROM playerinventories WHERE account_id = %d" % [acc_id])
	for i in range(res.size()):
		inventory[int(res[i]["item_slot"])] = { "item_id": int(res[i]["item_id"]), 
												"amount" : int(res[i]["amount"])}
	print(inventory)
	return inventory
		
func dbGetAllItemsInDatabase() -> Array:
	return db.query("SELECT * FROM items")

########### Helper Functions ##############
func dbReturnAccountData(session_token):
	return db.query("SELECT * FROM playeraccounts WHERE session_token = '%s'" % [session_token])

func dbReturnAccountIDUsingUsername(username):
	res = db.query("SELECT account_id FROM playeraccounts WHERE username = '%s'" % [username])
	return res
	
func dbCheckUniqueUsername(username):
	var res = [false, null, null, null, null]
	for id in PlayerIDs:
		if id["username"] == username:
			res = [true, id["username"], id["password"], id["salt"], id["can_login"]]
			break
	return res

func dbRefreshPlayerIDs():
	res = db.query("SELECT * FROM playeraccounts;")
	PlayerIDs = res

func dbReportError(err):
	if err != 0:
		print("Error: ", err, "\n")
		return

func dbGetAccountID(session_token):
	return int(dbReturnAccountData(session_token)[0]["account_id"])

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

func db_update_inventory(session_token : int, new_inventory : Dictionary):
	var account_id = dbGetAccountID(session_token)
	# This currently does no validation on the inventory sent from WorldServer
	db.query("DELETE FROM playerinventories WHERE account_id=%s" % account_id)
	for slot in new_inventory.keys():
		
		# Gracefully handle invalid number of items sent by world. Remove when
		# World implements item stacking
		var amount = 1
		if new_inventory[slot].has("amount"):
			amount = new_inventory[slot]["amount"]
			
		db.query("INSERT INTO playerinventories (account_id, item_slot, item_id, amount) VALUES (%s, %d, %d, %d );" \
			% [account_id, slot, new_inventory[slot]["item_id"], amount])
