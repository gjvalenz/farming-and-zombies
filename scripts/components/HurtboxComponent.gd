extends Area2D
class_name HurtboxComponent

@export var health: HealthComponent
@export var accepts: Array[String]
@export var ignores: Array[String]

var picky: bool = false
var whitelist: bool = false
var blacklist: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if accepts.size() > 0:
		whitelist = true
	if ignores.size() > 0:
		blacklist = true
	picky = blacklist or whitelist
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_entered(hb):
	if not hb is HitboxComponent:
		return
	hb.emit_hit_signal()
	if not picky:
		health.damage(hb.true_owner, hb.damage)
		return
	if whitelist and hb.kind in accepts:
		health.damage(hb.true_owner, hb.damage)
		return
	if blacklist and hb.kind not in ignores:
		health.damage(hb.true_owner, hb.damage)
