extends Node

enum { NON_CONSUMABLE = 0, CONSUMABLE}
enum Category {NOT_EQUIPPABLE = 0, HEAD, CHEST, HANDS, LEGS, FEET, MAIN_HAND, OFF_HAND, RING, AMULET}

# items start from id = 1
const FIRST_EQUIPPABLE_ITEM_ID = 1
enum EquippableItemIds { SILVER_HELMET = FIRST_EQUIPPABLE_ITEM_ID,
						SILVER_CHEST,
						SILVER_GLOVES,
						SILVER_LEGGINGS,
						SILVER_BOOTS,
						SILVER_SWORD,
						SILVER_SHIELD,
						GOLD_RING,
						DIAMOND_RING,
						GOLD_AMULET}

# Leave 100000 free ids for equippable items. This is done so that when new items
# are added we dont need to fix player inventory table
const FIRST_MATERIAL_ITEM_ID = 100000
enum MaterialItemIds { COPPER_ORE = FIRST_MATERIAL_ITEM_ID,
						TIN_ORE,
						IRON_ORE,
						COAL,
						SILVER_ORE,
						GOLD_ORE}

class Item:
	var id : int
	var item_name : String
	var consumable : int
	var attack : int
	var defense : int
	var file_name : String
	var item_category : int
	var stack_size : int
	func _init(_id, _item_name, _attack, _defense, _item_category, _stack_size = 1, _consumable = NON_CONSUMABLE):
		id = _id
		item_name = _item_name
		consumable = _consumable
		attack = _attack
		defense = _defense
		item_category = _item_category
		stack_size = _stack_size
		file_name = str(id) + "_" + _item_name + ".png"
	static func new_equippable(_id, _attack, _defense, _item_category):
		var _item_name = (EquippableItemIds.keys()[_id - FIRST_EQUIPPABLE_ITEM_ID] as String).to_lower()
		return Item.new(_id, _item_name, _attack, _defense, _item_category)
	static func new_material(_id, _stack_size):
		var _item_name = (MaterialItemIds.keys()[_id - FIRST_MATERIAL_ITEM_ID] as String).to_lower()
		return Item.new(_id, _item_name, 0, 0, Category.NOT_EQUIPPABLE, _stack_size)
	func save():
		PlayerData.db_add_item(id, item_name, consumable, attack, defense, file_name, item_category, stack_size)

func generate_item_database():
	PlayerData.db_clear_items()
	
	var items = []
	# Equippable items
	#                                ID                           ATTACK DEFENSE 	CATEGORY
	items.append(Item.new_equippable(EquippableItemIds.SILVER_HELMET,	0,		5,	Category.HEAD))
	items.append(Item.new_equippable(EquippableItemIds.SILVER_CHEST,	0,		10,	Category.CHEST))
	items.append(Item.new_equippable(EquippableItemIds.SILVER_GLOVES,	4,		2,	Category.HANDS))
	items.append(Item.new_equippable(EquippableItemIds.SILVER_LEGGINGS,	0,		8,	Category.LEGS))
	items.append(Item.new_equippable(EquippableItemIds.SILVER_BOOTS,	2,		2,	Category.FEET))
	items.append(Item.new_equippable(EquippableItemIds.SILVER_SWORD,	10,		0,	Category.MAIN_HAND))
	items.append(Item.new_equippable(EquippableItemIds.SILVER_SHIELD,	0,		10,	Category.OFF_HAND))
	items.append(Item.new_equippable(EquippableItemIds.GOLD_RING,		4,		4,	Category.RING))
	items.append(Item.new_equippable(EquippableItemIds.DIAMOND_RING,	6,		6,	Category.RING))
	items.append(Item.new_equippable(EquippableItemIds.GOLD_AMULET,		5,		5,	Category.AMULET))
	
	# Materials
	#                             ID                       stack_size
	items.append(Item.new_material(MaterialItemIds.COPPER_ORE, 20))
	items.append(Item.new_material(MaterialItemIds.TIN_ORE, 20))
	items.append(Item.new_material(MaterialItemIds.IRON_ORE, 20))
	items.append(Item.new_material(MaterialItemIds.COAL, 40))
	items.append(Item.new_material(MaterialItemIds.SILVER_ORE, 20))
	items.append(Item.new_material(MaterialItemIds.GOLD_ORE, 20))
	
	# save items into database
	for item in items:
		(item as Item).save()
