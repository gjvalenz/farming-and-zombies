extends Node2D
class_name DropItemComponent

signal on_dropped

enum LootMethod { Constant, Uniform }

@export var item_entity: PackedScene
@export var loot_method: LootMethod  = LootMethod.Constant
@export var min_count: int = 0
@export var max_count: int = 0
@export var random_drop_radius: float = 40.0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var grandparent: Node
var true_position

func _ready():
	true_position = global_position
	if get_parent():
		if get_parent().get_parent():
			grandparent = get_parent().get_parent()
	rng.randomize()
	
func get_count() -> int:
	if loot_method == LootMethod.Constant:
		return max(min_count, max_count)
	elif loot_method == LootMethod.Uniform:
		return rng.randi_range(min_count, max_count)
	return -1

func drop():
	if grandparent:
		var count: int = get_count()
		for i in range(0, count):
			var x: float = rng.randf_range(-random_drop_radius, random_drop_radius)
			var y: float = rng.randf_range(-random_drop_radius, random_drop_radius)
			var offset: Vector2 = Vector2(x, y)
			var entity_position = true_position + offset
			var drop: Node = item_entity.instantiate()
			drop.global_position = entity_position
			grandparent.add_child(drop)
			on_dropped.emit()

func _process(delta):
	pass
