extends Node2D
class_name VelocityActionableComponent

@export var actor: Node2D
@export var speed: float

signal on_velocity_changed
signal on_velocity_stopped

var movement_enabled: bool = true

var old_velocity: Vector2 = Vector2(0.0, 0.0)
var strategy = null

# Called when the node enters the scene tree for the first time.
func _ready():
	for c in get_children():
		strategy = c


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not movement_enabled:
		return
	var velocity_unit = strategy.strategize()
	var new_velocity = speed * velocity_unit
	if new_velocity.distance_squared_to(Vector2(0.0, 0.0)) == 0:
		if old_velocity != new_velocity:
			on_velocity_stopped.emit()
	else:
		if old_velocity != new_velocity:
			on_velocity_changed.emit(new_velocity)
	actor.velocity = new_velocity
	old_velocity = new_velocity
