extends Node

#Maybe move change script to the server interface submodule structure? 
#That way client and auth have the same IDs all the time. 

var none: int = 0
var head: int = 1
var chest: int = 2
var hands: int = 3
var legs: int = 4
var feet: int = 5
var main_hand: int = 6
var off_hand: int = 7
var ring: int = 8
var amulet: int = 9
var consumable: int = 10 
var quest: int = 11

func ItemAllowedInSlot(item_slot, item_category_id):
	var allowed_in_new_slot = false
	if item_slot <= 25:
		allowed_in_new_slot = true
	elif item_slot == 26 and item_category_id == 1:
		allowed_in_new_slot = true
	elif item_slot == 27 and item_category_id == 2:
		allowed_in_new_slot = true
	elif item_slot == 28 and item_category_id == 9:
		allowed_in_new_slot = true
	elif item_slot == 29 and item_category_id == 6:
		allowed_in_new_slot = true
	elif item_slot == 30 and item_category_id == 7:
		allowed_in_new_slot = true
	elif item_slot == 31 and item_category_id == 3:
		allowed_in_new_slot = true
	elif item_slot == 32 and item_category_id == 8:
		allowed_in_new_slot = true
	elif item_slot == 33 and item_category_id == 8:
		allowed_in_new_slot = true
	elif item_slot == 34 and item_category_id == 4:
		allowed_in_new_slot = true
	elif item_slot == 35 and item_category_id == 5:
		allowed_in_new_slot = true
	return allowed_in_new_slot


