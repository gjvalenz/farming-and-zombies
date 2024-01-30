extends Node2D

var Enemy = preload("res://scenes/objects/Enemy.tscn")

var count = 0
var cap = 0
var enabled = false

func decrease_count(amount) -> void:
	count = max(count-amount, 0)

func enable() -> void:
	enabled = true

func disable() -> void:
	enabled = false
	

func try_spawn_enemy() -> Enemy:
	if count >= cap:
		return null
	if enabled:
		count += 1
		return Enemy.instantiate()
	return null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
