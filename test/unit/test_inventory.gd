extends "res://addons/gut/test.gd"
const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")

func before_all():
	Inventory.db = SQLite.new()
	Inventory.db.path = "res://test_db.db"
	Inventory.db.open_db()

func after_all():
	Inventory.db.close_db()

func test_get_items():
	Inventory.init()
	Inventory.add_item(1, 1, 1)
	Inventory.add_item(2, 1, 1)
	var inv = Inventory.get_player_items(1)
	assert_eq(inv.size(), 1)
	assert_eq(inv[0].equip_slot, 1)
	assert_eq(inv[0].item_id, 1)

func test_get_item():
	Inventory.init()
	Inventory.add_item(1, 1, 0)
	var item = Inventory.get_player_item(1, 0)
	assert_eq(item.size(), 1)
	assert_eq(item[0].item_id, 1)
  
func test_move_item_to_empty_slot():
	Inventory.init()
	Inventory.add_item(1, 1, 0)
	Inventory.set_player_item_equip_slot(1, 0, 1)
	var item = Inventory.get_player_item(1, 0)
	# no item at equip slot 0
	assert_eq(item.size(), 0)
	# item moved to equip slot 1
	item = Inventory.get_player_item(1,1)
	assert_eq(item.size(), 1)
	assert_eq(item[0].item_id, 1)
  
func test_move_item_to_occupied_slot():
	Inventory.init()
	Inventory.add_item(1, 1, 0)
	Inventory.add_item(1, 2, 1)
	Inventory.set_player_item_equip_slot(1, 0, 1)
	# item 2 is now in slot 0
	var item = Inventory.get_player_item(1, 0)
	assert_eq(item.size(), 1)
	assert_eq(item[0].item_id, 2)
	# item 1 moved to equip slot 1
	item = Inventory.get_player_item(1,1)
	assert_eq(item.size(), 1)
	assert_eq(item[0].item_id, 1)

func test_exchange_inventory():
	Inventory.init()
	var player_id = 1
	var items = [{"item_id": 1, "equip_slot": 0},
				{"item_id": 2, "equip_slot": 1},
				{"item_id": 5, "equip_slot": 2},
				{"item_id": 4, "equip_slot": 3}]
	for item in items:
		Inventory.add_item(player_id, item["item_id"], item["equip_slot"])
	
	var item = Inventory.get_player_item(player_id, 1)
	assert_eq(item[0].item_id, 2)
	
	var new_items = [{"item_id": 1, "equip_slot": 0},
					{"item_id": 5, "equip_slot": 2},
					{"item_id": 4, "equip_slot": 6}]
	Inventory.set_player_items(player_id, new_items)
	
	# Check that items have changed
	item = Inventory.get_player_item(player_id, 1)
	assert_eq(item.size(), 0)
	item = Inventory.get_player_item(player_id, 3)
	assert_eq(item.size(), 0) 
	
	item = Inventory.get_player_item(player_id, 6)
	assert_eq(item[0].item_id, 4)
