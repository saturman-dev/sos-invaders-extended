extends Control

@onready var red := $barRed
@onready var yell := $barYell
@onready var label := $Label
@onready var yellwait := $yellwait
@onready var afterdead := $afterdead
@onready var add := $barAdd
var defred = 0
var tween: Tween
var ytween: Tween
var defcolor := Color.RED
var defaddsize: float

func _ready() -> void:
	defaddsize = add.size.x
	shieldown()
	Events.flseye_shield_made.connect(func(): shieldup())
	Events.flseye_shield_broken.connect(func(): shieldown())
	Events.boss_damaged.connect(func(health_percent): damage(health_percent))
	defred = red.size.x
	defcolor = red.color
	add.color = Color.SKY_BLUE

func damage(health_percent: float):
	if yellwait.is_stopped() == false:
		yellwait.stop()
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(red, "size:x", defred * health_percent, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	yellwait.start()
	if health_percent <= 0:
		ytween = create_tween()
		ytween.tween_property(yell, "size:x", red.size.x, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		var labelPos = label.position
		afterdead.start()
		while afterdead.time_left > 0.0:
			label.position.x = labelPos.x + randf_range(-10.0, 10.0)
			label.position.y = labelPos.y + randf_range(-5.0, 5.0)
			await get_tree().process_frame
		queue_free()

func _on_yellwait_timeout() -> void:
	ytween = create_tween()
	ytween.tween_property(yell, "size:x", red.size.x, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

var atween: Tween

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if atween and atween.is_running():
		atween.kill()
	atween = create_tween()
	atween.tween_property(self, "modulate:a", 0.25, 0.1)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if atween and atween.is_running():
		atween.kill()
	atween = create_tween()
	atween.tween_property(self, "modulate:a", 1.0, 0.3)

func shieldup():
	red.color = Color.SKY_BLUE

func shieldown():
	red.color = defcolor
	add.size.x = 0.0
	var s = create_tween()
	s.tween_property(add, "size:x", defaddsize, 10.0)
