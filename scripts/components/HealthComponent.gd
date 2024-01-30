extends Node2D
class_name HealthComponent

signal on_damaged
signal on_dead
signal on_healed

@export var max_health: float
@export var current_health: float

func _ready():
	if current_health == null or current_health == 0.0:
		current_health = max_health

func damage(entity, amount: float):
	current_health = max(current_health-amount, 0.0)
	on_damaged.emit(entity, self, amount)
	if current_health == 0.0:
		on_dead.emit(entity, self)

func heal(entity, amount: float):
	current_health = max(current_health+amount, max_health)
	on_healed.emit(entity, self, amount)
