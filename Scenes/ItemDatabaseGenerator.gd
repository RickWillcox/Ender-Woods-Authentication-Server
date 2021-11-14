extends Node
class_name ItemDatabaseGenerator

enum { NON_CONSUMABLE = 0, CONSUMABLE}
enum Category {NOT_EQUIPPABLE = 0, HEAD, CHEST, HANDS, LEGS, FEET, MAIN_HAND, OFF_HAND, RING, AMULET}

# items start from id = 1
const FIRST_EQUIPPABLE_ITEM_ID = 1
enum EquippableItemIds { COPPER_HELMET = FIRST_EQUIPPABLE_ITEM_ID,
						COPPER_CHEST,
						COPPER_GLOVES,
						COPPER_LEGGINGS,
						COPPER_BOOTS,
						COPPER_SWORD,
						COPPER_SHIELD,
						COPPER_RING,
						COPPER_AMULET,
						COPPER_PICKAXE,
						COPPER_AXE,
						COPPER_BLANK1,
						COPPER_BLANK2,
						COPPER_BLANK3,
						COPPER_BLANK4,
						COPPER_BLANK5,
						COPPER_BLANK6,
						COPPER_BLANK7,
						COPPER_BLANK8,
						COPPER_BLANK9,

						
						IRON_HELMET,
						IRON_CHEST,
						IRON_GLOVES,
						IRON_LEGGINGS,
						IRON_BOOTS,
						IRON_SWORD,
						IRON_SHIELD,
						IRON_RING,
						IRON_AMULET,
						IRON_PICKAXE,
						IRON_AXE,
						IRON_BLANK1,
						IRON_BLANK2,
						IRON_BLANK3,
						IRON_BLANK4,
						IRON_BLANK5,
						IRON_BLANK6,
						IRON_BLANK7,
						IRON_BLANK8,
						IRON_BLANK9,
						
						BRONZE_HELMET,
						BRONZE_CHEST,
						BRONZE_GLOVES,
						BRONZE_LEGGINGS,
						BRONZE_BOOTS,
						BRONZE_SWORD,
						BRONZE_SHIELD,
						BRONZE_RING,
						BRONZE_AMULET,
						BRONZE_PICKAXE,
						BRONZE_AXE,
						BRONZE_BLANK1,
						BRONZE_BLANK2,
						BRONZE_BLANK3,
						BRONZE_BLANK4,
						BRONZE_BLANK5,
						BRONZE_BLANK6,
						BRONZE_BLANK7,
						BRONZE_BLANK8,
						BRONZE_BLANK9,
								
						SILVER_HELMET,
						SILVER_CHEST,
						SILVER_GLOVES,
						SILVER_LEGGINGS,
						SILVER_BOOTS,
						SILVER_SWORD,
						SILVER_SHIELD,
						SILVER_RING,
						SILVER_AMULET,
						SILVER_PICKAXE,
						SILVER_AXE,
						SILVER_BLANK1,
						SILVER_BLANK2,
						SILVER_BLANK3,
						SILVER_BLANK4,
						SILVER_BLANK5,
						SILVER_BLANK6,
						SILVER_BLANK7,
						SILVER_BLANK8,
						SILVER_BLANK9,
						
						GOLD_HELMET,
						GOLD_CHEST,
						GOLD_GLOVES,
						GOLD_LEGGINGS,
						GOLD_BOOTS,
						GOLD_SWORD,
						GOLD_SHIELD,
						GOLD_RING,
						GOLD_AMULET,
						GOLD_PICKAXE,
						GOLD_AXE,
						GOLD_BLANK1,
						GOLD_BLANK2,
						GOLD_BLANK3,
						GOLD_BLANK4,
						GOLD_BLANK5,
						GOLD_BLANK6,
						GOLD_BLANK7,
						GOLD_BLANK8,
						GOLD_BLANK9,
						}

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
	var file_name : String
	var item_category : int
	var stack_size : int
	var base_modifiers : String
	func _init(_id, _item_name, _item_category, _base_modifiers, _stack_size = 1, _consumable = NON_CONSUMABLE):
		id = _id
		item_name = _item_name
		consumable = _consumable
		base_modifiers = JSON.print(_base_modifiers)
		item_category = _item_category
		stack_size = _stack_size
		file_name = str(id) + "_" + _item_name + ".png"
	static func new_equippable(_id, _item_category, _base_modifiers):
		var _item_name = (EquippableItemIds.keys()[_id - FIRST_EQUIPPABLE_ITEM_ID] as String).to_lower()
		return Item.new(_id, _item_name, _item_category, _base_modifiers)
	static func new_material(_id, _stack_size):
		var _item_name = (MaterialItemIds.keys()[_id - FIRST_MATERIAL_ITEM_ID] as String).to_lower()
		return Item.new(_id, _item_name, Category.NOT_EQUIPPABLE, {}, _stack_size)
	func save():
		var db : MariaDB = DatabaseConnection.db
		var query_s = "INSERT INTO items VALUES (%d, '%s', %d, '%s', %d, %d, '%s');" % \
						[id, item_name, consumable, file_name, item_category, stack_size, base_modifiers]
		var res = db.query(query_s)
		assert(res == OK)
		
		
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

enum ModifierType { PREFIX = 0, SUFFIX = 1}

class ItemModifier:
	var id : int
	var type : int
	var modifiers : String
	var display : String
	var item_category_restrictions : int
	func _init(_id : int, _item_category_restrictions, _display : String, _type : int, _modifiers : Dictionary):
		id = _id
		type = _type
		display = _display
		modifiers = JSON.print(_modifiers)
		item_category_restrictions = _item_category_restrictions
	func save():
		var db : MariaDB = DatabaseConnection.db
		var query_s = "INSERT INTO itemmodifiers VALUES (%d, %d, %d, '%s', '%s');" % \
				[id, item_category_restrictions, type, display, modifiers]
		var res = db.query(query_s)
		assert(res == OK)


func generate_item_database():
	db_clear_items()
	
	var items = []
	# Equippable items
	#                                ID                           		CATEGORY		BASE_MODIFIERS
	# COPPER ITEMS
	items.append(Item.new_equippable(EquippableItemIds.COPPER_HELMET, Category.HEAD, {"defense":5}))
	items.append(Item.new_equippable(EquippableItemIds.COPPER_CHEST, Category.CHEST, {"defense":10}))
	items.append(Item.new_equippable(EquippableItemIds.COPPER_GLOVES, Category.HANDS, {"attack":4, "defense":2}))
	items.append(Item.new_equippable(EquippableItemIds.COPPER_LEGGINGS, Category.LEGS, {"defense":8}))
	items.append(Item.new_equippable(EquippableItemIds.COPPER_BOOTS, Category.FEET, {"attack":2, "defense":2}))
	items.append(Item.new_equippable(EquippableItemIds.COPPER_SWORD, Category.MAIN_HAND, {"attack":10}))
	items.append(Item.new_equippable(EquippableItemIds.COPPER_SHIELD, Category.OFF_HAND, {"defense":10}))
	items.append(Item.new_equippable(EquippableItemIds.COPPER_RING, Category.RING, {"defense":4, "attack":4}))
	items.append(Item.new_equippable(EquippableItemIds.COPPER_AMULET, Category.AMULET, {"defense":5, "attack":5}))
	items.append(Item.new_equippable(EquippableItemIds.COPPER_PICKAXE, Category.MAIN_HAND, {"defense":5, "attack":5}))
	items.append(Item.new_equippable(EquippableItemIds.COPPER_AXE, Category.MAIN_HAND, {"defense":5, "attack":5}))
	
	# IRON ITEMS
	items.append(Item.new_equippable(EquippableItemIds.IRON_HELMET, Category.HEAD, {"defense":5}))
	items.append(Item.new_equippable(EquippableItemIds.IRON_CHEST, Category.CHEST, {"defense":10}))
	items.append(Item.new_equippable(EquippableItemIds.IRON_GLOVES, Category.HANDS, {"attack":4, "defense":2}))
	items.append(Item.new_equippable(EquippableItemIds.IRON_LEGGINGS, Category.LEGS, {"defense":8}))
	items.append(Item.new_equippable(EquippableItemIds.IRON_BOOTS, Category.FEET, {"attack":2, "defense":2}))
	items.append(Item.new_equippable(EquippableItemIds.IRON_SWORD, Category.MAIN_HAND, {"attack":10}))
	items.append(Item.new_equippable(EquippableItemIds.IRON_SHIELD, Category.OFF_HAND, {"defense":10}))
	items.append(Item.new_equippable(EquippableItemIds.IRON_RING, Category.RING, {"defense":4, "attack":4}))
	items.append(Item.new_equippable(EquippableItemIds.IRON_AMULET, Category.AMULET, {"defense":5, "attack":5}))
	items.append(Item.new_equippable(EquippableItemIds.IRON_PICKAXE, Category.MAIN_HAND, {"defense":5, "attack":5}))
	items.append(Item.new_equippable(EquippableItemIds.IRON_AXE, Category.MAIN_HAND, {"defense":5, "attack":5}))
	
	# BRONZE ITEMS
	items.append(Item.new_equippable(EquippableItemIds.BRONZE_HELMET, Category.HEAD, {"defense":5}))
	items.append(Item.new_equippable(EquippableItemIds.BRONZE_CHEST, Category.CHEST, {"defense":10}))
	items.append(Item.new_equippable(EquippableItemIds.BRONZE_GLOVES, Category.HANDS, {"attack":4, "defense":2}))
	items.append(Item.new_equippable(EquippableItemIds.BRONZE_LEGGINGS, Category.LEGS, {"defense":8}))
	items.append(Item.new_equippable(EquippableItemIds.BRONZE_BOOTS, Category.FEET, {"attack":2, "defense":2}))
	items.append(Item.new_equippable(EquippableItemIds.BRONZE_SWORD, Category.MAIN_HAND, {"attack":10}))
	items.append(Item.new_equippable(EquippableItemIds.BRONZE_SHIELD, Category.OFF_HAND, {"defense":10}))
	items.append(Item.new_equippable(EquippableItemIds.BRONZE_RING, Category.RING, {"defense":4, "attack":4}))
	items.append(Item.new_equippable(EquippableItemIds.BRONZE_AMULET, Category.AMULET, {"defense":5, "attack":5}))
	items.append(Item.new_equippable(EquippableItemIds.BRONZE_PICKAXE, Category.MAIN_HAND, {"defense":5, "attack":5}))
	items.append(Item.new_equippable(EquippableItemIds.BRONZE_AXE, Category.MAIN_HAND, {"defense":5, "attack":5}))
	
	# SILVER ITEMS
	items.append(Item.new_equippable(EquippableItemIds.SILVER_HELMET, Category.HEAD, {"defense":5}))
	items.append(Item.new_equippable(EquippableItemIds.SILVER_CHEST, Category.CHEST, {"defense":10}))
	items.append(Item.new_equippable(EquippableItemIds.SILVER_GLOVES, Category.HANDS, {"attack":4, "defense":2}))
	items.append(Item.new_equippable(EquippableItemIds.SILVER_LEGGINGS, Category.LEGS, {"defense":8}))
	items.append(Item.new_equippable(EquippableItemIds.SILVER_BOOTS, Category.FEET, {"attack":2, "defense":2}))
	items.append(Item.new_equippable(EquippableItemIds.SILVER_SWORD, Category.MAIN_HAND, {"attack":10}))
	items.append(Item.new_equippable(EquippableItemIds.SILVER_SHIELD, Category.OFF_HAND, {"defense":10}))
	items.append(Item.new_equippable(EquippableItemIds.SILVER_RING, Category.RING, {"defense":4, "attack":4}))
	items.append(Item.new_equippable(EquippableItemIds.SILVER_AMULET, Category.AMULET, {"defense":5, "attack":5}))
	items.append(Item.new_equippable(EquippableItemIds.SILVER_PICKAXE, Category.MAIN_HAND, {"defense":5, "attack":5}))
	items.append(Item.new_equippable(EquippableItemIds.SILVER_AXE, Category.MAIN_HAND, {"defense":5, "attack":5}))
	
	# GOLD ITEMS
	items.append(Item.new_equippable(EquippableItemIds.GOLD_HELMET, Category.HEAD, {"defense":5}))
	items.append(Item.new_equippable(EquippableItemIds.GOLD_CHEST, Category.CHEST, {"defense":10}))
	items.append(Item.new_equippable(EquippableItemIds.GOLD_GLOVES, Category.HANDS, {"attack":4, "defense":2}))
	items.append(Item.new_equippable(EquippableItemIds.GOLD_LEGGINGS, Category.LEGS, {"defense":8}))
	items.append(Item.new_equippable(EquippableItemIds.GOLD_BOOTS, Category.FEET, {"attack":2, "defense":2}))
	items.append(Item.new_equippable(EquippableItemIds.GOLD_SWORD, Category.MAIN_HAND, {"attack":10}))
	items.append(Item.new_equippable(EquippableItemIds.GOLD_SHIELD, Category.OFF_HAND, {"defense":10}))
	items.append(Item.new_equippable(EquippableItemIds.GOLD_RING, Category.RING, {"defense":4, "attack":4}))
	items.append(Item.new_equippable(EquippableItemIds.GOLD_AMULET, Category.AMULET, {"defense":5, "attack":5}))
	items.append(Item.new_equippable(EquippableItemIds.GOLD_PICKAXE, Category.MAIN_HAND, {"defense":5, "attack":5}))
	items.append(Item.new_equippable(EquippableItemIds.GOLD_AXE, Category.MAIN_HAND, {"defense":5, "attack":5}))
	
	
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


	
const FIRST_MODIFIER_ID = 1 # 0 - reserved, means no modifier
enum ItemModifierIds { SHARP = FIRST_MODIFIER_ID,
						BLUNT,
						OF_WISDOM,
						REINFORCED,
						}
						
enum ItemCategoryRestrictions { NONE = 0,
								WEAPON_ONLY, # Weapons only
								WEARABLE_ONLY } # Only stuff like armor, rings

func generate_itemmodifier_database():
	db_clear_itemmodifiers()
	
									
	var item_modifier_definitions = [
		# ID					# TYPE				# Item category restrictions		#Display	# modifier effect
		[ItemModifierIds.SHARP, ModifierType.PREFIX, ItemCategoryRestrictions.WEAPON_ONLY, "Sharp", {"attack" : 1}],
		[ItemModifierIds.BLUNT, ModifierType.PREFIX, ItemCategoryRestrictions.WEAPON_ONLY, "Blunt", {"attack" : -1}],
		[ItemModifierIds.OF_WISDOM, ModifierType.SUFFIX, ItemCategoryRestrictions.NONE, "of Wisdom", {"wisdom": 1}],
		[ItemModifierIds.REINFORCED, ModifierType.PREFIX, ItemCategoryRestrictions.WEARABLE_ONLY, "Reinforced", {"defense":2}]
	]
	
	for item_modifier in item_modifier_definitions:
		ItemModifier.new(item_modifier[0], item_modifier[2], item_modifier[3], item_modifier[1], item_modifier[4]).save()
	
	
	
# Helper functions
func db_clear_items():
	var db : MariaDB = DatabaseConnection.db
	var res = db.query("DELETE FROM items;")
	assert(res == OK)

func db_clear_recipes():
	var db : MariaDB = DatabaseConnection.db
	var res = db.query("DELETE FROM recipes;")
	assert(res == OK)
	
func db_clear_itemmodifiers():
	var db : MariaDB = DatabaseConnection.db
	assert(db.query("DELETE FROM itemmodifiers;") == OK)
