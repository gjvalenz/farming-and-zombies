extends Node2D

var registries: GameRegistry = GameRegistry.new()

var stump = preload("res://resources/items/stump.tres") as Item

var iron = preload("res://resources/items/iron.tres") as Item
	
var STUMP_ITEM = registries.register(GameRegistry.Type.Item, 'faz', 'stump', stump)
var IRON_ITEM = registries.register(GameRegistry.Type.Item, 'faz', 'iron', iron)

func uniform_stump_drop(min: int, max:int) -> Callable:
	return Loot.uniform_loot_count.bind(min, max, STUMP_ITEM)

func constant_stump_drop(count: int) -> Callable:
	return Loot.constant_loot_count.bind(count, STUMP_ITEM)

func constant_stump_iron_drop(count_stump: int, count_iron: int) -> Callable:
	return func ():
		var returns = []
		for x in range(count_stump):
			returns.append(STUMP_ITEM)
		for y in range(count_iron):
			returns.append(IRON_ITEM)
		return returns

var DRIPPING_TREE_LOOT = registries.register(GameRegistry.Type.Loot, 'faz', 'dripping_tree', Loot.new(uniform_stump_drop(1, 5)))
var DEAD_TREE_LOOT = registries.register(GameRegistry.Type.Loot, 'faz', 'dead_tree', Loot.new(uniform_stump_drop(0, 1)))
var FRUIT_TREE_LOOT = registries.register(GameRegistry.Type.Loot, 'faz', 'fruit_tree', Loot.new(uniform_stump_drop(1, 3)))
var PALM_TREE_LOOT = registries.register(GameRegistry.Type.Loot, 'faz', 'palm_tree', Loot.new(constant_stump_drop(2)))
var SNOW_TREE_LOOT = registries.register(GameRegistry.Type.Loot, 'faz', 'snow_tree', Loot.new(constant_stump_drop(2)))

func get_drops(name: String) -> Node2D:
	var entry = registries.get_entry(GameRegistry.map_key(GameRegistry.Type.Loot, 'faz', name))
	return entry

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
