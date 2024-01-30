extends CanvasModulate
class_name DayNightCycleComponent

@export var day_color: Color
@export var night_color: Color
@export var day_stall_time: float
@export var night_stall_time: float
@export var cycle_scale: float
@export var start_day: bool

enum TimeDay { Day, Night }

var d_stall_time: float = 0.0
var n_stall_time: float = 0.0
var counter: float = 0.0
var mode: TimeDay
var paused: bool = true
var flip: bool = false

var first_emit: bool = true

signal on_night
signal on_day

# Called when the node enters the scene tree for the first time.
func _ready():
	if start_day:
		mode = TimeDay.Day
		counter = 0.0
		color = day_color
	else:
		mode = TimeDay.Night
		counter = 1.0
		color = night_color
		flip = true
	n_stall_time = night_stall_time
	d_stall_time = day_stall_time

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if first_emit:
		if mode == TimeDay.Day:
			on_day.emit()
		else:
			on_night.emit()
		first_emit = false
	if paused:
		if mode == TimeDay.Day:
			d_stall_time -= delta
			if d_stall_time <= 0.0:
				flip = !flip
				paused = false
				d_stall_time = day_stall_time
		else:
			n_stall_time -= delta
			if n_stall_time <= 0.0:
				flip = !flip
				paused = false
				n_stall_time = night_stall_time
		return
	var before_counter = counter
	counter += (1.0 if flip else -1.0) * cycle_scale * delta
	counter = min(max(counter, 0.0), 1.0)
	if before_counter < 0.5 and counter >= 0.5:
		on_night.emit()
	if before_counter >= 0.5 and counter < 0.5:
		on_day.emit()
	color = day_color.lerp(night_color, counter)
	if counter == 0.0:
		paused = true
		mode = TimeDay.Day
	if counter == 1.0:
		paused = true
		mode = TimeDay.Night
