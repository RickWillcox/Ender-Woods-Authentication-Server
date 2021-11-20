extends Node

var PlayerIDs : Array

#### Maria DB
var db : MariaDB

func _ready():
	db = DatabaseConnection.db
	Logger.info("Tables in database: " + str(db.query("SHOW TABLES;")))
########### Account Functions ##############

func db_create_account(username : String, password : String, salt : String):
	Logger.info("Attempting to create account: username : String: %s | Password{5}: %s, | Salt{5}: %s" % [username, password.left(5), salt.left(5)])
	var res = db.query("INSERT INTO playeraccounts (username, password, salt) VALUES ('%s', '%s', '%s');" % [username, password, salt])
	if res == OK:
		var account_id : int = db.query("SELECT account_id FROM playeraccounts WHERE username='%s' LIMIT 1" % [username])[0].account_id
		# add all basic items into players backpack
		var insert_query : String = "INSERT INTO playerinventories (account_id, item_slot, item_id) VALUES (%s, %d, %d );"
		db.query(insert_query % [account_id, 10, 1])
		db.query(insert_query % [account_id, 11, 2])
		db.query(insert_query % [account_id, 12, 3])
		db.query(insert_query % [account_id, 13, 4])
		db.query(insert_query % [account_id, 14, 61])
		db.query(insert_query % [account_id, 16, 62])
		db.query(insert_query % [account_id, 17, 63])
		db.query(insert_query % [account_id, 18, 64])
		db.query(insert_query % [account_id, 19, 65])
		db.query(insert_query % [account_id, 20, 66])
		db.query(insert_query % [account_id, 21, 67])
		
		var insert_testing : String = "INSERT INTO playerinventories (account_id, item_slot, item_id, amount) VALUES (%s, %d, %d, %d );"
		# add four stacks of copper ore for testing
		db.query(insert_testing % [account_id, 25, 100000, 15])
		db.query(insert_testing % [account_id, 26, 100000, 15])
		db.query(insert_testing % [account_id, 27, 100000, 1])
		db.query(insert_testing % [account_id, 28, 100000, 6])
		db.query(insert_testing % [account_id, 29, 100000, 20])
		
	db_report_error(res)
	return res

func db_delete_account(username : String, password : String):
	var res
	Logger.info("Deleting account: Username: %s | Password{5}: %s" % [username, password.left(5)])
	var user_data = db.query("SELECT * FROM playeraccounts where username = '%s'" % [username])
	if user_data[0]["username"] == username and user_data[0]["password"] == password:
		var acc_id = user_data[0]["account_id"]
		#Delete Account and Inventory
		res = db.query("""
		DELETE FROM playeraccounts WHERE username = '%s'; 
		DELETE FROM playerinventories WHERE account_id = '%d';""" % [username, acc_id])
	db_report_error(res)
	return res

func db_add_auth_token(username : String, auth_token : String):
	var res
	Logger.info("Adding Auth token: Username: %s | Auth Token{10}: %s \n" % [username, str(auth_token).left(10)])
	res = db.query("UPDATE playeraccounts SET auth_token = '%s' WHERE username = '%s';" % [auth_token, username])
	db_report_error(res)
	return res

func db_add_session_token(session_token : int, auth_token : String, world_server_id : int, test_case : bool):
	#player_ID becomes session_token here
	var res
	Logger.info("Adding Session token: Session Token{10}: %s | Auth Token{5}: %s \n" % [str(session_token).left(10), str(auth_token).left(5)])
	res = db.query("UPDATE playeraccounts SET session_token = '%d' WHERE auth_token = '%s';" % [session_token, auth_token])
	db_report_error(res)
	if res == OK and not test_case:
		Logger.info("Session Token Addition Successful Sending Inventory Data to World server for Session Token{10}: %s \n" % [str(session_token).left(10)])
		var inventory_data = db_get_inventory(session_token)
		GameServers.send_updated_inventory_to_client(inventory_data, world_server_id, session_token)
		pass
	else:
		#Send failed to add session token code if needed
		pass
	return res

func dbAddWorldServerID(session_token  : int, world_server_id : int):
	var res
	res = db.query("UPDATE playeraccounts SET world_server_id = %s WHERE session_token = %d" %[world_server_id, session_token])
	db_report_error(res)
	return res

func db_get_username(session_token : int, world_server_id : int):
	GameServers.send_username(db.query("Select username from playeraccounts where session_token = %d" % [session_token])[0]["username"], session_token, world_server_id)
	
########### Inventory ##############

func db_get_inventory(session_token : int):
	var res
	var acc_id : int = db_return_account_data(session_token)[0]["account_id"]
	# Rearrange inventory as a dictionary
	var inventory : Dictionary = {}
	res = db.query("SELECT * FROM playerinventories WHERE account_id = %d" % [acc_id])
	for i in range(res.size()):
		var item_slot = res[i]["item_slot"]
		res[i].erase("item_slot")
		inventory[item_slot] = res[i]
	return inventory
		
func db_get_all_items_database() -> Array:
	return db.query("SELECT * FROM items")

########### Helper Functions ##############
func db_return_account_data(session_token : int):
	return db.query("SELECT * FROM playeraccounts WHERE session_token = '%d'" % [session_token])
	
func db_check_unique_username(username : String):
	db_refresh_player_ids()
	var res : Array = [false, null, null, null, null]
	if PlayerIDs != []:
		for id in PlayerIDs:
			if id["username"] == username:
				res = [true, id["username"], id["password"], id["salt"], id["can_login"]]
				break
	return res

func db_refresh_player_ids():
	var res
	res = db.query("SELECT * FROM playeraccounts;")
	PlayerIDs = res

func db_report_error(err):
	if err != 0:
		Logger.error("Error: " +  str(err))
		return

func db_get_account_id(session_token : int):
	return int(db_return_account_data(session_token)[0]["account_id"])

func db_update_inventory(session_token : int, new_inventory : Dictionary):
	var account_id : int = db_get_account_id(session_token)
	# This currently does no validation on the inventory sent from WorldServer
	db.query("DELETE FROM playerinventories WHERE account_id=%s" % account_id)
	for slot in new_inventory.keys():
		
		# Gracefully handle invalid number of items sent by world. Remove when
		# World implements item stacking
		var amount : int = 1
		if new_inventory[slot].has("amount"):
			amount = new_inventory[slot]["amount"]
			
		db.query("INSERT INTO playerinventories (account_id, item_slot, item_id, amount) VALUES (%s, %d, %d, %d );" \
			% [account_id, slot, new_inventory[slot]["item_id"], amount])

func db_get_recipe_database() -> Dictionary:
	var res = db.query("SELECT * FROM recipes")
	var recipe_db = {}
	# Reconstruct the database as a dictionary with keys being recipe_ids
	for row in res:
		var materials_json = JSON.parse(row["materials"]).result
		var recipe_id = row["recipe_id"]
		row.erase("materials")
		row.erase("recipe_id")
		
		# make the materials dictionary keys ints. In database the keys are strings
		var materials = {}
		for key in materials_json:
			materials[int(key)] = materials_json[key]
			
		row["materials"] = materials
		recipe_db[recipe_id] = row
	return recipe_db
