class_name DestroyableDecoration
extends Resource

@export var health: float

func _init(p_health: float):
	health = p_health

func damage(source, amount: float):
	health -= amount
