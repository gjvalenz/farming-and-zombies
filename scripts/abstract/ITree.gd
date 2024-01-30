@tool
extends StaticBody2D
class_name ITree

# Called when the node enters the scene tree for the first time.
func _ready():
	assert($Sprite2D != null)
	assert($HealthComponent != null)
	assert($HurtboxComponent != null)
	assert($CollisionShape2D != null)
	assert($DropItemComponent != null)
	assert($LightOccluder2D != null)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_health_component_on_dead(entity, health_component):
	for d in get_children():
		if d is DropItemComponent:
			d.drop()
	queue_free()
