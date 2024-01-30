@tool
extends Area2D
class_name ItemEntity

@export var item_name: String
var can_pickup: bool = false
@onready var timer = $Timer
var item_key: String

signal on_picked_up

# Called when the node enters the scene tree for the first time.
func _ready():
	assert($Sprite2D != null)
	assert($CollisionShape2D != null)
	assert($Timer != null)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func unload() -> JSON:
	return JSON.new()

func _on_area_entered(area):
	if area is PickupBoxComponent and can_pickup:
		area.receive(item_key)
		die()

func _on_timer_timeout():
	die()

func die():
	queue_free()

func _on_tangible_timer_timeout():
	can_pickup = true
