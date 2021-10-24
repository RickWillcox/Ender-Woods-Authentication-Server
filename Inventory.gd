
extends Node
const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
var db

var table_name = "inventory"
var table_schema = \
"""CREATE TABLE inventory(\n
player_id INT NOT NULL,\n
item_id INT NOT NULL,\n
equip_slot INT NOT NULL\n
);"""

func open_db():
	db.open_db()
  
func query(query_text):
	db.query(query_text)
	return db.query_result
  
func close_db():
	db.close_db()
	
func prepare(path):
	db = SQLite.new()
	db.path = path

func init():
	open_db()
	query("DROP TABLE " + table_name)
	query(table_schema)

func get_player_items(player_id):
	return query(get_all_player_items_query(player_id))

func get_all_player_items_query(player_id):
	return "SELECT * FROM " + table_name + " WHERE player_id=%d" % player_id 
	
func get_player_item(player_id, equip_slot):
	return query(get_player_item_query(player_id, equip_slot))
  
func get_player_item_query(player_id, equip_slot):
	var string = "SELECT item_id FROM " + table_name + " WHERE (player_id=%d AND equip_slot=%d) LIMIT 1"
	return string % [player_id, equip_slot]

func set_player_item_equip_slot(player_id, from, to):
	return query(set_player_item_equip_slot_query(player_id, from, to))

func set_player_item_equip_slot_query(player_id, from, to):
	var string = "UPDATE {table} SET equip_slot = CASE WHEN equip_slot={from} THEN {to} WHEN equip_slot={to} THEN {from} END " \
	+ " WHERE player_id={player_id} AND (equip_slot={from} OR equip_slot={to});"
	return string.format({"table": table_name, "player_id": str(player_id), "from": str(from), "to" : str(to) })

func delete_player_items_query(player_id):
	var string = "DELETE FROM %s WHERE player_id=%d;"
	return string % [table_name, player_id]
	  
func add_item(player_id, item_id, equip_slot):
	query(add_item_query(player_id, item_id, equip_slot))
	
func add_item_query(player_id, item_id, equip_slot):
	var string = "INSERT INTO %s (player_id, item_id, equip_slot) VALUES (%d, %d, %d);"
	return string % [table_name, player_id, item_id, equip_slot]

func set_player_items(player_id, new_inventory):
	query(delete_player_items_query(player_id))
	for item in new_inventory:
		query(add_item_query(player_id, item["item_id"], item["equip_slot"]))

func finalize():
	close_db()
