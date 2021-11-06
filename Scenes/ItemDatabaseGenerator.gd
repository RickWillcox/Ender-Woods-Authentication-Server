extends Node
class_name ItemDatabaseGenerator

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
						GOLD_ORE,
						COPPER_BAR,
						BRONZE_BAR,
						IRON_BAR,
						SILVER_BAR,
						GOLD_BAR}

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
		var db : MariaDB = DatabaseConnection.db
		var query_s = "INSERT INTO items VALUES (%d, '%s', %d, %d, %d, '%s', %d, %d);" % \
						[id, item_name, consumable, attack, defense, file_name, item_category, stack_size]
		var res = db.query(query_s)
		assert(res == OK)

func generate_item_database():
	db_clear_items()
	
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
	
	items.append(Item.new_material(MaterialItemIds.COPPER_BAR, 20))
	items.append(Item.new_material(MaterialItemIds.BRONZE_BAR, 20))
	items.append(Item.new_material(MaterialItemIds.IRON_BAR, 20))
	items.append(Item.new_material(MaterialItemIds.SILVER_BAR, 20))
	items.append(Item.new_material(MaterialItemIds.GOLD_BAR, 20))
	
	# save items into database
	for item in items:
		(item as Item).save()
		
enum RecipeType { SMELTING, BLACKSMITHING }
enum RecipeId { SMELT_COPPER,
				SMELT_BRONZE,
				SMELT_IRON
				SMELT_SILVER,
				SMELT_GOLD }

class Recipe:
	var id : int
	var type : int
	var required_level : int
	var materials : String
	var result_item_id : int
	func _init(_id : int, _type : int, _required_level : int, _materials : Dictionary, _result_item_id : int):
		id = _id
		type = _type
		required_level = required_level
		materials = JSON.print(_materials)
		result_item_id = _result_item_id
	static func new_smelting(_id : int, _required_level : int, _materials : Dictionary, _result_item_id : int):
		return Recipe.new(_id, RecipeType.SMELTING, _required_level, _materials, _result_item_id)
	func save():
		var db : MariaDB = DatabaseConnection.db
		var query_s = "INSERT INTO recipes VALUES (%d, %d, %d, '%s', %d);" % \
				[id, type, required_level, materials, result_item_id]
		var res = db.query(query_s)
		assert(res == OK)

func generate_recipe_database():
	db_clear_recipes()
	var recipes = []
	
	recipes.append(Recipe.new_smelting(RecipeId.SMELT_COPPER, 0, { MaterialItemIds.COPPER_ORE: 2 }, MaterialItemIds.COPPER_BAR))
	recipes.append(Recipe.new_smelting(RecipeId.SMELT_BRONZE, 0, { MaterialItemIds.COPPER_ORE: 1, MaterialItemIds.TIN_ORE: 1 }, MaterialItemIds.BRONZE_BAR))
	recipes.append(Recipe.new_smelting(RecipeId.SMELT_IRON, 0, { MaterialItemIds.IRON_ORE: 2, MaterialItemIds.COAL : 1 }, MaterialItemIds.IRON_BAR))
	recipes.append(Recipe.new_smelting(RecipeId.SMELT_SILVER, 0, { MaterialItemIds.SILVER_ORE: 2, MaterialItemIds.COAL : 1 }, MaterialItemIds.SILVER_BAR))
	recipes.append(Recipe.new_smelting(RecipeId.SMELT_GOLD, 0, { MaterialItemIds.GOLD_ORE: 2, MaterialItemIds.COAL : 1 }, MaterialItemIds.GOLD_BAR))
	
	for recipe in recipes:
		(recipe as Recipe).save()

# Helper functions
func db_clear_items():
	var db : MariaDB = DatabaseConnection.db
	var res = db.query("DELETE FROM items;")
	assert(res == OK)

func db_clear_recipes():
	var db : MariaDB = DatabaseConnection.db
	var res = db.query("DELETE FROM recipes;")
	assert(res == OK)
