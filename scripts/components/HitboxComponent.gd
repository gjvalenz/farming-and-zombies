extends Area2D
class_name HitboxComponent

signal on_start
signal on_end
signal on_hit

@export var true_owner: Node2D
@export var damage: float
@export var kind: String


var executing: bool = false
var time_active: float = 0.0
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(collision_shape != null)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if executing:
		if time_active <= 0.0:
			off()
			executing = false
			on_end.emit()
		else:
			time_active -= delta

func is_on():
	return not collision_shape.disabled

func off():
	collision_shape.disabled = true

func on():
	collision_shape.disabled = false
	
func enable_for_time(time: float):
	executing = true
	time_active = time
	on()
	on_start.emit()
	
func reposition(location: Vector2):
	position = location

func emit_hit_signal():
	on_hit.emit()
