extends Area2D
class_name InteractionReceiverComponent

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_entered(activator: Node):
	if activator is InteractionActivatorComponent:
		activator.emit_interact_signal()
		for c in get_children():
			if c is IInteraction:
				c.activate(activator.get_parent())
	pass # Replace with function body.
