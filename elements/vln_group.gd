extends Node2D

var SPEEDMOD := 1.0
var NEO := 0

@onready var cldown := $cldown
@onready var shotTimer := $shotTimer

const rowstep = 15.0
var direction := int([-1, 1].pick_random())
var speed := 30.0
var yspeed = defyspeed
var defyspeed = 10.0
var amnt = 0

func _ready() -> void:
	global_position = Vector2(randf_range(70, get_viewport_rect().size.x - 70), -13)
	amnt = randi_range(0, 5)
	if amnt == 3 or amnt == 4:
		$villain1.queue_free()
	if amnt == 0 or amnt == 1 or amnt == 2:
		$villain1.queue_free()
		$villain4.queue_free()

func _process(delta: float) -> void:
	if global_position.y < 15:
		yspeed = defyspeed * 5
	else:
		yspeed = defyspeed
	var ySPEEDMOD = 1 + ((SPEEDMOD - 1) / 5)
	global_position.x += direction * speed * delta * SPEEDMOD
	global_position.y += yspeed * delta * ySPEEDMOD
	yspeed -= delta * 1.0 if yspeed > 0.1 else 0.0

func set_neo(NEO2: int):
	shotTimer.wait_time /= (1 + (SPEEDMOD - 1) * 2)
	shotTimer.start()
	for child in get_children():
		if "NEO" in child:
			Functions.set_neo(child, NEO2)

func change_direction():
	if cldown.time_left > 0:
		return
	direction = -1 if direction == 1 else 1
	global_position.y += rowstep
	cldown.start()

func _on_shot_timer_timeout() -> void:
	shot()

func shot():
	var avln = get_children()
	var tvln = []
	for child in avln:
		if child.has_method("shot"):
			tvln.append(child)
	if tvln.size() > 0:
		tvln.pick_random().shot()
