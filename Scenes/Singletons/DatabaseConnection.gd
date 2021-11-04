extends Node

var db: MariaDB
var res 
var ip : String = "127.0.0.1"
var port : int = 3306
var database : String = "playerdata"
var user : String = "admin"
var password : String = "ender"


func dbConnect():
	db = MariaDB.new()
	print("Connecting to Database | IP: %s | port: %d | database: %s | user: %s | pass: %s \n" % [ip,port,database,user,password])
	res = db.connect_db(ip, port, database, user, password)
	if res != OK:
		print("Failed to connect to the database\n")
		return
	print("Connected to '%s' database\n" % [database])

func _ready():
	dbConnect()
	
