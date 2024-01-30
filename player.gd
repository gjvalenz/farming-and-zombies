extends CharacterBody2D
class_name Player

enum Facing { Down, Left, Right, Up }

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D
@onready var light: PointLight2D = $PointLight2D
@onready var hitbox: HitboxComponent = $HitboxComponent
@onready var velocity_brain: VelocityActionableComponent = $VelocityActionableComponent
@onready var shape: CollisionShape2D = $CollisionShape2D
var facing: Facing = Facing.Down

var god_mode = false
var inventory: Dictionary

func _ready():
	anim.animation = "default"
	hitbox.off()
	
func _physics_process(delta):
	move_and_slide()

func _process(delta):
	velocity = Vector2.ZERO
	if Input.is_action_just_pressed("speed_up"):
		if not god_mode:
			shape.disabled = true
			velocity_brain.speed *= 6
		else:
			shape.disabled = false
			velocity_brain.speed /= 6
		god_mode = !god_mode
	if Input.is_action_just_pressed("light"):
		light.enabled = !light.enabled
	if Input.is_action_just_pressed("chop"):
		hitbox.enable_for_time(0.5)
	if Input.is_action_just_pressed("zoom_out"):
		camera.zoom /= 2.0
	elif Input.is_action_just_pressed("zoom_in"):
		camera.zoom *= 2.0

func light_on() -> void:
	light.enabled = true

func light_off() -> void:
	light.enabled = false

func _on_pickup_box_component_on_received(item_name: String):
	if item_name in inventory:
		inventory[item_name] += 1
	else:
		inventory[item_name] = 1
	print(JSON.stringify(inventory))

func _on_velocity_actionable_component_on_velocity_changed(vel: Vector2):
	if vel.x > 0:
		facing = Facing.Right
		anim.play("right")
	elif vel.x < 0:
		facing = Facing.Left
		#
		anim.play("left")
	elif vel.y < 0:
		facing = Facing.Up
		#
		anim.play("up")
	elif vel.y > 0:
		facing = Facing.Down
		anim.play("down")
	else:
		anim.play("default")


func _on_velocity_actionable_component_on_velocity_stopped():
	anim.pause()
	anim.frame = 1


func _on_hitbox_component_on_start():
	velocity_brain.movement_enabled = false
	if facing == Facing.Right:
		hitbox.reposition(Vector2(10, 0))
	elif facing == Facing.Left:
		hitbox.reposition(Vector2(-10, 0))
	elif facing == Facing.Up:
		hitbox.reposition(Vector2(0, -10))
	else:
		hitbox.reposition(Vector2(0, 10))


func _on_hitbox_component_on_end():
	velocity_brain.movement_enabled = true


func _on_hitbox_component_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body is Chunk:
		var coords = body.get_coords_for_body_rid(body_rid)
		body.handle_drops(coords)
		body.erase_cell(1, coords)
