extends "res://addons/gut/test.gd"

var characters = 'abcdefghijklmnopqrstuvwxyz'
var numbers = '0123456789'
var test_username 
var test_password 
var test_salt 
var test_auth_token 
var test_session_token
var test_world_server_id
var res
var db

func before_all():
	randomize()
	test_username = generate_word(characters, 25) 
	test_password = generate_word(characters, 25).sha256_text()
	test_salt = generate_word(characters, 25).sha256_text()
	test_auth_token = generate_word(characters, 25).sha256_text()
	test_session_token = generate_word(numbers, 10)
	test_world_server_id = generate_word(numbers, 10)
	db = DatabaseConnection.db
	PlayerData.db_refresh_player_ids()

func test_Account():
	subtest_create_account()
	subtest_AddAuthToken()
	subtest_AddSessionToken()
	subtest_AddWorldServerID()
	subtest_DeleteAccount()


########### Account Tests ##############
func subtest_create_account():
	res = PlayerData.db_create_account(test_username, test_password, test_salt)
	assert_eq(0, res, "Create Account")
	
func subtest_AddAuthToken():
	res = PlayerData.db_add_auth_token(test_username, test_auth_token)
	assert_eq(0, res, "Add Auth Token")

func subtest_AddSessionToken():
	res = PlayerData.db_add_session_token(test_session_token, test_auth_token, test_world_server_id, true)
	assert_eq(0, res, "Add Session Token")

func subtest_AddWorldServerID():
	res = PlayerData.dbAddWorldServerID(test_session_token, test_world_server_id)
	assert_eq(0, res, "Add World Server ID")
	
func subtest_DeleteAccount():
	res = PlayerData.db_delete_account(test_session_token, test_username, test_password, test_salt)
	assert_eq(0, res, "Delete Account")

########### Item / Inventory Tests ##############

#all removed due to not being used anymore
		
#Function to generate a random string of characters for testing purposes	
func generate_word(chars, length):
	var word: String
	var n_char = len(chars)
	for i in range(length):
		word += chars[randi()% n_char]
	return word

