extends Node

var PlayerIDs

#### Maria DB
var res 
var res1
var res2
var res3
var db

func _ready():
	db = DatabaseConnection.db
	CreateTablesInDB()
########### Account Functions ##############

func dbCreateAccount(username, password, salt, test_case):
	print("Attempting to create account")
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

	###Create the database tables
func CreateTablesInDB():
	var item_table_array = [
		"('silver_helmet',0,0,5,'1_silver_helmet.png','head',1)",
		"('silver_chest',0,0,10,'2_silver_chest.png','chest',2)",
		"('silver_gloves',0,4,2,'3_silver_gloves.png','hands',3)",
		"('Silver_leggings',0,0,8,'4_silver_leggings.png','legs',4)",
		"('silver_boots',0,2,2,'5_silver_boots.png','feet',5)",
		"('silver_shield',0,0,10,'7_silver_shield.png','off_hand',7)",
		"('silver_sword',0,10,0,'6_silver_sword.png','main_hand',6)",
		"('silver_shield',0,0,10,'7_silver_shield.png','off_hand',7)",
		"('gold_ring',0,4,4,'8_gold_ring.png','ring',8)",
		"('diamond_ring',0,6,6,'9_diamond_ring.png','ring',8)",
		"('gold_amulet',0,5,5,'10_gold_amulet.png','amulet',9)",
		"('silver_axe',0,12,0,'11_silver_axe.png','main_hand',6)",
		"('no_item',0,0,0,'12_no_item.png','not_an_item',0)"
	]

	db.query("""
	CREATE TABLE IF NOT EXISTS `playeraccounts` (
  `account_id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(25) NOT NULL DEFAULT '',
  `password` varchar(64) NOT NULL DEFAULT '',
  `salt` varchar(64) NOT NULL DEFAULT '0',
  `session_token` varchar(10) DEFAULT NULL,
  `auth_token` varchar(74) DEFAULT NULL,
  `can_login` tinyint(1) DEFAULT 1,
  `world_server_id` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`account_id`),
  UNIQUE KEY `ID` (`account_id`),
  UNIQUE KEY `username` (`username`));
	""")


	var player_inventories_exists = db.query("SELECT * FROM playerinventories")
	if typeof(player_inventories_exists) == TYPE_ARRAY:
		player_inventories_exists = 0
		
	db.query("""
	CREATE TABLE IF NOT EXISTS`playerinventories` (
  `account_id` int(11) NOT NULL,
  `item_slot` int(11) NOT NULL,
  `item_id` int(11) DEFAULT NULL);
		""")

	#item table could not be found, add items (stops duplicate items)
	var items_table_exists = db.query("SELECT * FROM items")
	if typeof(items_table_exists) == TYPE_ARRAY:
		items_table_exists = 0
		
	db.query("""
	CREATE TABLE IF NOT EXISTS `items` (
  `item_id` int(11) NOT NULL AUTO_INCREMENT,
  `item_name` varchar(100) NOT NULL,
  `consumable` tinyint(4) NOT NULL,
  `attack` int(11) DEFAULT NULL,
  `defence` int(11) DEFAULT NULL,
  `file_name` varchar(100) DEFAULT NULL,
  `item_category` varchar(100) NOT NULL,
  `item_category_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`item_id`));
	""")
	
	if items_table_exists == 1146:
		for item in item_table_array:
			db.query("INSERT INTO playerdata.items (item_name,consumable,attack,defence,file_name,item_category,item_category_id) VALUES %s;" % [item])
	
	#add the shaka account with password 1 for easy testing, since username is unique it will fail if shaka is already in there so no checks needed
	res = db.query("INSERT INTO playerdata.playeraccounts (username,password,salt,session_token,auth_token,can_login,world_server_id) VALUES %s;" % ["('shaka','fb51a1bffda8a2b81e8330733e7cea4a232af1fb83e31d06b9b6df5ccc6771a5','3579de75a1579d26c15548512d5e4e930654d8ffc0f9b45b26a7989c5ef71b0c','2041156026','fe01b92c8f8df01450806c065c2545fd371831f6d0709adef399a9a0d6a9cb4a1635905938',1,NULL)"])
	
	#add base inventory in so they can login without errors
	if player_inventories_exists == 1146:
		for i in range (1,36):
			db.query("INSERT INTO playerdata.playerinventories (account_id,item_slot,item_id) VALUES (1, %d, 0);" % [i])
		
