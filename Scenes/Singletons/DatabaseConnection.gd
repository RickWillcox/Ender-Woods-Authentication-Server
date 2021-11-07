extends Node

var db: MariaDB
var res : int 
var ip : String = "127.0.0.1"
var port : int = 3306
var database : String = "playerdata"
var user : String = "root"
var password : String = "rootroot"


func db_connect():
	db = MariaDB.new()
	Logger.info("Connecting to Database | IP: %s | Port: %d | Database: %s | User: %s | Pass: %s" % [ip, port, database, user, password])
	res = db.connect_db(ip, port, database, user, password)
	if res != OK:
		Logger.error("Failed to connect to the database")
		# Server cannot start without database connection
		assert(false)
		return
	Logger.info("Connected to '%s' database" % [database])

func _ready():
	db_connect()
	
