extends Control

@onready var edit: LineEdit = $LineEdit
const world_path: String = "res://world.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func swap_with_seed(seed: int):
	var node: Node = preload(world_path).instantiate()
	node.seed = seed
	var current_scene: Node = get_tree().current_scene
	get_tree().get_root().add_child(node)
	get_tree().current_scene = node
	current_scene.queue_free()

func _on_button_pressed():
	var seed: int = 0
	if (edit.text != ""):
		if (edit.text.is_valid_int()):
			seed = edit.text.to_int()
		else:
			seed = edit.text.hash()
	else:
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		seed = rng.randi()
	swap_with_seed(seed)
