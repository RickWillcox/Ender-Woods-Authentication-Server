extends "res://addons/gut/test.gd"

var test_username = "asdmadnadsadmaodmnise"
var test_password = "fvmkfvmfkmvkfmvfkmfk"
var test_salt = "dijdvmdimvidmvdmvidim"

func before_all():
	PlayerData.dbConnect()
	PlayerData.dbRefreshPlayerIDs()
	#Delete the test account if it exists
	PlayerData.dbDeleteAccount(test_username, test_password, test_salt)

func after_all():
	pass

func test_CreateAccount():
	PlayerData.dbCreateAccount(test_username, test_password, test_salt)
	PlayerData.dbRefreshPlayerIDs()
	var res = PlayerData.dbCheckUniqueUsername(test_username)
	assert_true(res[0], "Should Pass")

func test_dbDeleteAccount():
	PlayerData.dbDeleteAccount(test_username, test_password, test_salt)
	PlayerData.dbRefreshPlayerIDs()
	var res = PlayerData.dbCheckUniqueUsername(test_username)
	assert_false(res[0], "Should Pass")

