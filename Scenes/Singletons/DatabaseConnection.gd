extends Node

var db: MariaDB
var res 
var ip : String = "127.0.0.1"
var port : int = 3306
var database : String = "playerdata"
var user : String = "root"
var password : String = "rootroot"


func dbConnect():
	db = MariaDB.new()
	Logger.info("Connecting to Database | IP: %s | port: %d | database: %s | user: %s | pass: %s" % [ip,port,database,user,password])
	res = db.connect_db(ip, port, database, user, password)
	if res != OK:
		Logger.error("Failed to connect to the database")
		# Server cannot start without database connection
		assert(false)
		return
	Logger.info("Connected to '%s' database" % [database])

func _ready():
	dbConnect()
	
