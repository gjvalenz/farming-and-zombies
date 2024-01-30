extends CharacterBody2D
class_name Enemy

@export var target: Node2D
@export var speed: float = 50.0
@onready var nav: NavigationAgent2D = $NavigationAgent2D

func _ready():
	make_path()

func _physics_process(delta):
	velocity = speed * to_local(nav.get_next_path_position()).normalized()
	move_and_slide()

func despawn():
	queue_free()

func _process(delta):
	if target.global_position.distance_to(self.global_position) >= 2.75 * Chunk.CHUNK_DISTANCE_PX:
		EnemySpawner.decrease_count(1)
		despawn()

func make_path():
	nav.target_position = target.global_position

func _on_timer_timeout():
	make_path()
