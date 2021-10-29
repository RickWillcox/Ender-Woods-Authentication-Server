extends Node

var db: MariaDB
var res 

func dbConnect():
	db = MariaDB.new()
	print("Connecting to Database")
	res = db.connect_db("127.0.0.1", 3306, "playerdata", "admin", "root")
	if res != OK:
		print("Failed to connect to the database")
		return
	print("Connected\n")

func _ready():
	dbConnect()
	
