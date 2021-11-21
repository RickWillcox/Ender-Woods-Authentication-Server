extends "res://addons/gut/test.gd"

var characters = 'abcdefghijklmnopqrstuvwxyz'
var numbers = '0123456789'
var test_username : String
var test_password : String
var test_salt : String 
var test_auth_token : String
var test_session_token : int
var test_world_server_id : int
var res
var db


func before_all():
	randomize()
	test_username = generate_word(characters, 25) 
	test_password = generate_word(characters, 25).sha256_text()
	test_salt = generate_word(characters, 25).sha256_text()
	test_auth_token = generate_word(characters, 25).sha256_text()
	test_session_token = int(generate_word(numbers, 10))
	test_world_server_id = int(generate_word(numbers, 10))
	db = DatabaseConnection.db
	PlayerData.db_refresh_player_ids()


func test_Account():
	subtest_get_recipe_database_columns()
	subtest_get_items_database_columns()
	subtest_get_item_modifiers_columns()
	subtest_create_account()
	subtest_AddAuthToken()
	subtest_AddSessionToken()
	subtest_AddWorldServerID()
	subtest_get_playerinventories_columns()
	subtest_get_playeraccounts_columns()
	subtest_update_inventory()
	subtest_DeleteAccount()

########### Account Tests ##############
func subtest_create_account():
	res = PlayerData.db_create_account(test_username, test_password, test_salt)
	assert_eq(0, res, "Create Account")
	var username_in_db = PlayerData.db.query(("SELECT username FROM playeraccounts where username = '%s'") % [test_username])
	assert_eq(test_username, username_in_db[0]["username"])
	
func subtest_AddAuthToken():
	res = PlayerData.db_add_auth_token(test_username, test_auth_token)
	assert_eq(0, res, "Add Auth Token")
	var auth_token_in_db = PlayerData.db.query(("SELECT auth_token FROM playeraccounts where username = '%s'") % [test_username])
	assert_eq(test_auth_token, auth_token_in_db[0]["auth_token"], "Check Auth Token Exists for user")

func subtest_AddSessionToken():
	res = PlayerData.db_add_session_token(test_session_token, test_auth_token, test_world_server_id, true)
	assert_eq(0, res, "Add Session Token")
	var session_token_in_db = PlayerData.db.query(("SELECT session_token FROM playeraccounts where username = '%s'") % [test_username])
	assert_eq(str(test_session_token), session_token_in_db[0]["session_token"], "Check Session Token Exists for user")

func subtest_AddWorldServerID():
	res = PlayerData.dbAddWorldServerID(test_session_token, test_world_server_id)
	assert_eq(0, res, "Add World Server ID")
	
func subtest_DeleteAccount():
	res = PlayerData.db_delete_account(test_username, test_password)
	assert_eq(0, res, "Delete Account")
	var username_in_db = PlayerData.db.query(("SELECT username FROM playeraccounts where username = '%s'") % [test_username])
	assert_eq([], username_in_db, "Check Account was deleted")

# Item database functions
	
func subtest_get_recipe_database_columns():
	var keys: Array = ["recipe_type", "required_level", "materials", "result_item_id"]
	res = PlayerData.db_get_recipe_database()
	for key in keys:
		assert_true(key in res[0], "recipes: %s column found" % key)

func subtest_get_items_database_columns():
	var keys: Array = ["item_name", "consumable", "file_name", "item_category", "stack_size", "base_modifiers"]
	res = PlayerData.db_get_all_items_database()
	for key in keys:
		assert_true(key in res[0], "items: %s column found" % key)
		
func subtest_get_playerinventories_columns():
	var keys: Array = ["item_slot", "item_id", "amount", "prefix_id", "suffix_id"]
	res = PlayerData.db.query("SELECT * FROM playerinventories")
	for key in keys:
		assert_true(key in res[0], "playerinventories: %s column found" % key)

func subtest_get_playeraccounts_columns():
	var keys: Array = ["username", "password", "salt", "session_token", "auth_token", "can_login", "world_server_id", "experience"]
	res = PlayerData.db.query("SELECT * FROM playeraccounts")
	for key in keys:
		assert_true(key in res[0], "playeraccounts: %s column found" % key)
		
func subtest_get_item_modifiers_columns():
	var keys: Array = ["item_category_restrictions", "type", "display", "modifiers"]
	res = PlayerData.db.query("SELECT *  FROM itemmodifiers")
	for key in keys:
		assert_true(key in res[0], "itemmodifiers: %s column found" % key)

func subtest_update_inventory():
	var account_id : int = PlayerData.db_get_account_id(test_session_token)
	var new_inventory : Dictionary = {
		10:{"account_id":account_id, "amount":1, "item_id":1, "prefix_id":0, "suffix_id":0},
		11:{"account_id":account_id, "amount":1, "item_id":2, "prefix_id":0, "suffix_id":0},
		12:{"account_id":account_id, "amount":15, "item_id":100000, "prefix_id":0, "suffix_id":0}
	}		
	PlayerData.db_update_inventory(test_session_token, new_inventory)
	var res = PlayerData.db.query("SELECT * FROM playerinventories WHERE account_id = '%d'" % [account_id])
	var db_inventory_dict : Dictionary = {}
	for item in res:
		db_inventory_dict[item["item_slot"]] = {
			"account_id" : item["account_id"],
			"amount" : item["amount"],
			"item_id" : item["item_id"],
			"prefix_id" : item["prefix_id"],
			"suffix_id" : item["suffix_id"]
		}
	assert_eq(db_inventory_dict.hash(), new_inventory.hash(), "Update Inventory: Hashes correct")
	
#Function to generate a random string of characters for testing purposes	
func generate_word(chars, length):
	var word: String
	var n_char = len(chars)
	for i in range(length):
		word += chars[randi()% n_char]
	return word

