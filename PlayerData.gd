extends Node

var PlayerIDs

#### Maria DB
var res 
var res1
var res2
var db

func _ready():
	db = DatabaseConnection.db
	res = db.query("SELECT * FROM playeraccounts;")
	print(res)
########### Account Functions ##############

func dbCreateAccount(username, password, salt, test_case):
	print("Attempting to create account")
	res = db.query("INSERT INTO playeraccounts (username, password, salt) VALUES ('%s', '%s', '%s');" % [username, password, salt])
	if res == OK and not test_case:
		dbAddItemSlots(username)
		pass
	dbReportError(res)
	return res

func dbDeleteAccount(session_token, username, password, salt):
	print("Attempting to delete account")
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
	res = db.query("UPDATE playeraccounts SET auth_token = '%s' WHERE username = '%s';" % [auth_token, username])
	dbReportError(res)
	return res

func dbAddSessionToken(session_token, auth_token, world_server_id, test_case):
	#player_ID becomes session_token here
	res = db.query("UPDATE playeraccounts SET session_token = '%s' WHERE auth_token = '%s';" % [session_token, auth_token])
	dbReportError(res)
	if res == OK and not test_case:
		var inventory_data = dbGetInventory(session_token, world_server_id)
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

func dbGetInventory(session_token, world_server_id):
	var acc_id = int(dbReturnAccountData(session_token)[0]["account_id"])
	var inventory = []
	res = db.query("SELECT item_slot, item_id FROM playerinventories WHERE account_id = %d" % [acc_id])
	for i in range(res.size()):
		inventory.append([res[i]["item_slot"], res[i]["item_id"]])
	print(inventory)
	return [inventory, world_server_id]
	
func dbAddItemSlots(username):
	var acc_id = int(dbReturnAccountIDUsingUsername(username)[0]["account_id"])
	for i in range(1, 36):
			res = db.query("INSERT INTO playerinventories (account_id, item_slot, item_id) VALUES ('%d', '%d', %s);" % [acc_id, i, 0])
	return res

func dbAddNewItem(session_token, item_id):
	var acc_id = dbGetAccountID(session_token)
	res = (db.query("SELECT item_category_id FROM items WHERE item_id = %d" % [item_id]))[0]["item_category_id"]
	var item_category = res
	res = db.query("SELECT * FROM playerinventories WHERE account_id = %d AND item_id = 0 AND item_slot < 26" % [acc_id])
	if res == null:
		print("Inventory is Full")
		return 
	#res[0] is the first non occupied item slot
	var first_free_slot = int(res[0]["item_slot"])
	if ItemCategories.ItemAllowedInSlot(first_free_slot, item_category):
		return db.query("UPDATE playerinventories SET item_id = %d WHERE account_id = %d and item_slot = %d" % [item_id, acc_id, first_free_slot])
		

func dbChangeItemSlot(session_token, old_slot_number, new_slot_number):
	#change this later with better swap query
	#you are always holding item a and swapping to item b
	var acc_id = dbGetAccountID(session_token)
	print(acc_id)
	var item_a = db.query("SELECT item_id FROM playerinventories WHERE account_id = %d AND item_slot = %d;" % [acc_id, old_slot_number])[0]["item_id"]
	var item_b = db.query("SELECT item_id FROM playerinventories WHERE account_id = %d AND item_slot = %d;" % [acc_id, new_slot_number])[0]["item_id"]
	if ItemCategories.ItemAllowedInSlot(old_slot_number, item_b):
		if ItemCategories.ItemAllowedInSlot(new_slot_number, item_a):
			res1 = db.query("UPDATE playerinventories SET item_id = %s WHERE item_slot = %d" % [item_a, new_slot_number])
			res2 = db.query("UPDATE playerinventories SET item_id = %s WHERE item_slot = %d" % [item_b, old_slot_number])
			return [res1, res2]
	#add failed to swap code here (invalid swap)

func dbGetAllItemsInDatabase():
	res1 = db.query("SELECT * FROM items")
	res2 = db.query("SELECT * FROM itemcategories")
	GameServers.SendAllItemDataToWorldServers(res1, res2)

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
		print("Error: ", err)
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
