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
	PlayerData.dbRefreshPlayerIDs()

func test_Account():
	subtest_CreateAccount()
	subtest_AddAuthToken()
	subtest_AddSessionToken()
	subtest_AddItemSlots()
	subtest_AddNewItem()
	subtext_ChangeItemSlot()
	subtest_AddWorldServerID()
#	subtest_DeleteAccount()
	subtext_ItemAllowedInSlot()


########### Account Tests ##############
func subtest_CreateAccount():
	res = PlayerData.dbCreateAccount(test_username, test_password, test_salt, true)
	assert_eq(0, res, "Create Account")
	
func subtest_AddAuthToken():
	res = PlayerData.dbAddAuthToken(test_username, test_auth_token)
	assert_eq(0, res, "Add Auth Token")

func subtest_AddSessionToken():
	res = PlayerData.dbAddSessionToken(test_session_token, test_auth_token, test_world_server_id)
	assert_eq(0, res, "Add Session Token")

func subtest_AddWorldServerID():
	res = PlayerData.dbAddWorldServerID(test_session_token, test_world_server_id)
	assert_eq(0, res, "Add World Server ID")
	
func subtest_DeleteAccount():
	res = PlayerData.dbDeleteAccount(test_session_token, test_username, test_password, test_salt)
	assert_eq(0, res, "Delete Account")

########### Item / Inventory Tests ##############

func subtest_AddItemSlots():
	res = PlayerData.dbAddItemSlots(test_username)
	assert_eq(0, res, "Add Item Slots")

func subtest_AddNewItem():
	for i in range(25):
		var random_item_id : int = randi() % 9 + 1
		res = PlayerData.dbAddNewItem(test_session_token, random_item_id)
	assert_eq(0, res, "Add New item")
	
func subtext_ChangeItemSlot():
	res = PlayerData.dbChangeItemSlot(test_session_token, 1, 2)
	assert_eq(0, res[0], "Add Item Slots 1")
	assert_eq(0, res[1], "Add Item Slots 2")
			
func subtext_ItemAllowedInSlot(): #item_slot > item_id
	assert_true(ItemCategories.ItemAllowedInSlot(1, 8), "Valid: item 8 into slot 1")
	assert_true(ItemCategories.ItemAllowedInSlot(26, 1), "Valid: item 1 into slot 26")
	assert_false(ItemCategories.ItemAllowedInSlot(29, 9), "INVALID: item 9 into slot 29")
	assert_false(ItemCategories.ItemAllowedInSlot(29, 9), "INVALID: item 4 into slot 35")
	
	
func generate_word(chars, length):
	var word: String
	var n_char = len(chars)
	for i in range(length):
		word += chars[randi()% n_char]
	return word

