extends Area2D
class_name InteractionActivatorComponent

signal on_interact

@onready var collision: CollisionShape2D = $CollisionShapeD

func is_on():
	return not collision.disabled

func off():
	collision.disabled = true

func on():
	collision.disabled = false
	
func emit_interact_signal():
	on_interact.emit()

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(collision != null)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
