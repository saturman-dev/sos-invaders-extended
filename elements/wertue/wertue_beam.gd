extends Area2D

var NEO = false
signal warrned

@export var tracking_speed := 20.0
var target_pos := Vector2.ZERO

@onready var slabost := $slabost
@onready var warning := $warning
@onready var laser := $laser
@onready var hitbox := $CollisionShape2D
@onready var waitTime := $waitTime
@onready var warningTime := $warningTime
@onready var laserTime := $laserTime
@onready var beamLoop := $beamLoop
@onready var attackLoop := $attackLoop

var wertue = 0
var enragedColor = Color.RED

var warnTickTime = 0.025

func parentConnect(parent: Object):
	wertue = parent

func _ready() -> void:
	beamLoop.play()
	global_position = get_tree().get_first_node_in_group("player").global_position
	while not wertue is Object:
		await get_tree().process_frame
	if wertue.enraged == true:
		slabost.modulate = enragedColor
		warning.modulate = enragedColor
		laser.modulate = enragedColor
		waitTime.wait_time /= 4
		warningTime.wait_time /= 2
		laserTime.wait_time /= 2
	waitTime.start()
	waiting()

var waited = false
var killedBefore = false
var warned = false
var interruption = false
var hitted = false

func waiting():
	while wertue.died == false and waited == false:
		if is_inside_tree() == true:
			await get_tree().process_frame
		else:
			break
	if wertue.died == true:
		waitTime.stop()
		killedBefore = true
		var stoptween = create_tween()
		stoptween.tween_property(slabost, "modulate:a", 0.0, 1.0)
		var looptween = create_tween()
		looptween.tween_property(beamLoop, "pitch_scale", 0.7, 1.0)
		await stoptween.finished
		beamLoop.stop()
		queue_free()

func _on_wait_time_timeout() -> void:
	beamLoop.stop()
	waited = true
	warningTime.start()
	slabost.visible = false
	while wertue.died == false and warned == false:
		warning.visible = true
		if NEO == false:
			Functions.sfx_play("res://sounds/wertueWarning.mp3")
		await get_tree().create_timer(warnTickTime, false).timeout
		warning.visible = false
		await get_tree().create_timer(warnTickTime, false).timeout
		warrned.emit()
	if wertue.died == true:
		PtbonusesManager.ptbonus(wertue.givepts / 2, "INTERRUPTION", Color.WHITE)
		interruption = true
		warning.modulate.a = 1.0
		warningTime.start()
		var warntween = create_tween()
		warntween.tween_property(self, "scale:x", scale.x * 1.5, warningTime.wait_time)
		laserTime.wait_time *= 2
		while warned == false:
			warning.visible = true
			if NEO == false:
				Functions.sfx_play("res://sounds/wertueInterruption.mp3")
			await get_tree().create_timer(warnTickTime, false).timeout
			warning.visible = false
			await get_tree().create_timer(warnTickTime, false).timeout
			warrned.emit()

func _on_warning_time_timeout() -> void:
	await warrned
	if NEO == false:
		Functions.sfx_play("res://sounds/wertueAttack.mp3", -5.0)
	attackLoop.play()
	warned = true
	warning.visible = false
	laser.visible = true
	hitbox.disabled = false
	laserTime.start()
	if interruption == true:
		set_collision_mask_value(3, true)
		Globals.shake_str += 3.0

func _on_laser_time_timeout() -> void:
	var looptween = create_tween()
	looptween.tween_property(attackLoop, "pitch_scale", 0.7, laserTime.wait_time/2)
	var lasertween = create_tween()
	lasertween.tween_property(self, "global_scale:x", 0.0, laserTime.wait_time/2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await lasertween.finished
	attackLoop.stop()
	if wertue:
		if hitted == false:
			if NEO == false:
				wertue.failedAttacks += 1
		else:
			if wertue.enraged == true:
				wertue.unenrage()
			wertue.failedAttacks = 0
		if NEO == false:
			wertue.newShot()
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
	if get_overlapping_bodies().size() > 0:
		hitted = true
	if waited == false:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			target_pos.x = player.global_position.x
			global_position.x = lerp(global_position.x, target_pos.x, tracking_speed * delta)
			target_pos.y = player.global_position.y
			global_position.y = lerp(global_position.y, target_pos.y, tracking_speed * delta)

func turn90():
	rotation_degrees = 90.0
	NEO = true
	beamLoop.volume_db -= 80.0
	attackLoop.volume_db -= 80.0
