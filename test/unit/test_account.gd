extends "res://addons/gut/test.gd"

var characters = 'abcdefghijklmnopqrstuvwxyz'
var numbers = '0123456789'
var test_username 
var test_password 
var test_salt 
var test_auth_token 
var test_session_token = "00000000000000"

func before_all():
	randomize()
	test_username = generate_word(characters, 25) 
	test_password = generate_word(characters, 25).sha256_text()
	test_salt = generate_word(characters, 25).sha256_text()
	test_auth_token = generate_word(characters, 25).sha256_text()
	print("Auth Token test: ", test_auth_token)
	PlayerData.dbConnect()
	PlayerData.dbRefreshPlayerIDs()

func test_Account():
	subtest_CreateAccount()
	subtest_AddAuthToken()
	subtest_AddSessionToken()
	subtest_DeleteAccount()
	
func subtest_CreateAccount():
	PlayerData.dbCreateAccount(test_username, test_password, test_salt)
	PlayerData.dbRefreshPlayerIDs()
	var res = PlayerData.dbCheckUniqueUsername(test_username)
	assert_true(res[0], "Create Account")
	
func subtest_AddAuthToken():
	PlayerData.dbAddAuthToken(test_username, test_auth_token)
	PlayerData.dbRefreshPlayerIDs()
	var res = PlayerData.dbCheckAuthTokenExists(test_auth_token)
	assert_true(res, "Add Auth Token")

func subtest_AddSessionToken():
	PlayerData.dbAddSessionToken(test_session_token, test_auth_token)
	PlayerData.dbRefreshPlayerIDs()
	var res = PlayerData.dbCheckSessionTokenExists(test_session_token)
	assert_true(res, "Add Session Token")

func subtest_DeleteAccount():
	PlayerData.dbDeleteAccount(test_username, test_password, test_salt)
	PlayerData.dbRefreshPlayerIDs()
	var res = PlayerData.dbCheckUniqueUsername(test_username)
	assert_false(res[0], "Delete Account")
	
func generate_word(chars, length):
	var word: String
	var n_char = len(chars)
	for i in range(length):
		word += chars[randi()% n_char]
	return word

