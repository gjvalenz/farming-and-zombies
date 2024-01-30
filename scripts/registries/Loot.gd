extends Node2D
class_name Loot

var generate_loot: Callable
var serial_key: String

static func uniform_loot_count(min: int, max: int, item: Item) -> Array:
	return range(randi_range(min, max)).map(func (p): return item)

static func constant_loot_count(constant: int, item: Item) -> Array:
	return range(constant).map(func (p): return item)

static func weighted_loot_count(weighted: RandomWeightedList, item: Item) -> Array:
	var weight = weighted.get_random()
	return range(weight).map(func (p): return item)

func _init(loot_method: Callable):
	generate_loot = loot_method

func get_drops() -> Array:
	return generate_loot.call()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
