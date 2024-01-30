extends Node
class_name GameRegistry

var contexts: Dictionary = {}

enum Type { Material, Item, Loot }

static func map_key(type: Type, name_space: String, name: String) -> String:
	var key = name_space + '.'
	match type:
		Type.Material:
			key += 'material.'
		Type.Item:
			key += 'item.'
		Type.Loot:
			key += 'loot.'
		_:
			assert(false, "Improper registry key entry!")
	key +=  name
	return key


func check_object(type: Type, object) -> void:
	match type:
		#Type.Material:
		#	assert(object is GameMaterial, "Object is not item")
		Type.Item:
			assert(object is Item, "Object is not item")
		Type.Loot:
			assert(object is Loot, "Object is not loot")
		_:
			assert(false, "Improper registry key entry!")


func register(type: Type, name_space: String, name: String, object):
	check_object(type, object)
	var key = map_key(type, name_space, name)
	contexts[key] = object
	object.serial_key = key
	return contexts[key]

func get_entry(serial_key: String):
	if serial_key in contexts:
		return contexts[serial_key]
	else:
		return null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
