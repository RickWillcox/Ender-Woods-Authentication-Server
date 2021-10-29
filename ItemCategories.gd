extends Node

#Maybe move change script to the server interface submodule structure? That why client and auth have the same IDs all the time. 

var head: int 
var chest: int 
var hands: int 
var legs: int 
var feet: int 
var main_hand: int 
var off_hand: int 
var ring: int 
var amulet: int 
var consumable: int 
var quest: int 



func _ready():
	var db = DatabaseConnection.db
#	var res = db.query("SELECT * FROM itemcategories")
#	head = int(res[0]["equip_id"])
#	chest = int(res[1]["equip_id"])
#	hands = int(res[2]["equip_id"])
#	legs = int(res[3]["equip_id"])
#	feet = int(res[4]["equip_id"])
#	main_hand = int(res[5]["equip_id"])
#	off_hand = int(res[6]["equip_id"])
#	ring = int(res[7]["equip_id"])
#	amulet = int(res[8]["equip_id"])
#	consumable = int(res[9]["equip_id"])
#	quest = int(res[10]["equip_id"])
#	print("Item Categories Populated")
	
