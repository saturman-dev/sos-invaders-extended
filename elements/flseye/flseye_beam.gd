extends Area2D

var dir = 1
var alter = false
var NEO = false
signal warrned
signal fin

@onready var warning := $warning
@onready var laser := $laser
@onready var hitbox := $CollisionShape2D
@onready var warningTime := $warningTime
@onready var laserTime := $laserTime
@onready var attackLoop := $attackLoop

var enragedColor = Color.RED

var warnTickTime = 0.025
var movingTime = 4.0

func _ready() -> void:
	if alter == true:
		altgo()
	else:
		go()

var warned = false

func go() -> void:
	warningTime.start()
	while warned == false:
		warning.visible = true
		if NEO == false:
			Functions.sfx_play("res://sounds/wertueWarning.mp3")
		await get_tree().create_timer(warnTickTime, false).timeout
		warning.visible = false
		await get_tree().create_timer(warnTickTime, false).timeout
		warrned.emit()

var m: Tween
func altgo():
	global_position.y = 120
	scale *= 0.75
	warning.visible = false
	hitbox.disabled = false
	laser.visible = true
	attackLoop.volume_db = 15.0
	attackLoop.play()
	m = create_tween()
	m.tween_property(self, "global_position:x", 420 * dir, movingTime).as_relative()
	await get_tree().create_timer(movingTime * 0.7, false).timeout
	gone()

func _on_warning_time_timeout() -> void:
	await warrned
	Functions.sfx_play("res://sounds/wertueAttack.mp3", -5.0, 0.8)
	attackLoop.play()
	warned = true
	warning.visible = false
	laser.visible = true
	hitbox.disabled = false
	laserTime.start()

func _on_laser_time_timeout() -> void:
	gone()

func gone():
	var looptween = create_tween()
	looptween.tween_property(attackLoop, "pitch_scale", 0.7, laserTime.wait_time/2)
	var lasertween = create_tween()
	lasertween.tween_property(self, "scale:x", 0.0, laserTime.wait_time/2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await lasertween.finished
	attackLoop.stop()
	fin.emit()
	queue_free()

func _process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.has_method("takeDmg"):
			if body.is_invincible == false:
				body.takeDmg()
		if body.has_method("beam_dmg"):
			body.beam_dmg(5.0)
		if body.has_method("explode"):
			Globals.shake_str += 5.0
			body.explode()
