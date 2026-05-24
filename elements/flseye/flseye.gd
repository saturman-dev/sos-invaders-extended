extends CharacterBody2D

const color = Color("7200ff")

var stopped = false
var NEO = false
var last_attack = -1

# FOR DAMAGE
var fullhp = 1
var hp = fullhp
var yellwait = 0.7
@onready var timer := $dmgstop
@onready var sprite := $AnimatedSprite2D
var dmgColor = Color.RED
@onready var hpbar := $hpfull/hp
var bar1 = 0.2
var fullsize = 0.0
var undam = 0.3

var givepts = 50
var died = false
var bar2 = 0.4
var expltime = 0.5
var explsize = 1.5
var explstay = 0.4
var unexpltime = 1.5
var afterdead = 2.0
var rot = randf_range(10.0, 30.0)
var enraged = false
var betweenAttacks := 0.5
var failedAttacks := 0
var maxFailedAttacks := 2
var enrageColor := Color.RED

const bulletScene = preload("res://elements/wertue/wertueBeam.tscn")
const laserScene = preload("res://elements/flseye/flseye_laser.tscn")
const beamScene = preload("res://elements/flseye/flseyeBeam.tscn")
const shieldScene = preload("res://elements/flseye/shield.tscn")
const explosionScene = preload("res://elements/explosion/explosion.tscn")
const flbulletScene = preload("res://elements/flseye/flbullet.tscn")

@onready var raycast_left := $RayCastLeft
@onready var raycast_right := $RayCastRight
@onready var hpbar1 := $hpfull
@onready var hpbar2 := $hpfull/hp2
@onready var expl := $NormTema
@onready var cldown := $cldown
@onready var shotTimer := $shotTimer
@onready var enrageEffect := $enrageEffect
@onready var enrageLoop := $ENRAGED
@onready var hitbox := $CollisionShape2D
@onready var square1 := $square1
@onready var square2 := $square2
@onready var dot = $dot
@onready var laserManager := $laserManager
@onready var shieldcd := $shieldCD



var direction := int([-1, 1].pick_random())
var defspeed := 50.0
var speed := defspeed
var yspeed = 7.5
var defyspeed = yspeed
var raycast = false
var dirChanging := 80.0
var dirYup = false
var dotScale := Vector2.ZERO

var current_shield: Object
var current_laser1: Object
var current_laser2: Object

var squarespeed := 180.0
var shake_str := 0.0

func _process(delta: float) -> void:
	square1.rotation_degrees += squarespeed * delta
	square2.rotation_degrees -= squarespeed * delta
	if shake_str > 0.0:
		sprite.position.x = randf_range(-shake_str, shake_str)
		sprite.position.y = randf_range(-shake_str, shake_str)
		shake_str -= delta * 20.0
	if stopped == true:
		return
	if raycast == true:
		speed -= dirChanging * delta
		if speed < -defspeed:
			raycast = false
			speed *= -1
			direction *= -1
	if moving == true:
		global_position.x += direction * speed * delta
		global_position.y += yspeed * delta
	if dirYup == false:
		yspeed -= delta * 2
		if yspeed < -defyspeed:
			dirYup = true
	else:
		yspeed += delta * 2
		if yspeed > defyspeed:
			dirYup = false

func _on_shot_timer_timeout() -> void:
		shot()

var enabled = true
var moving = false

var dmgtween: Tween

func damageAnimation():
	Functions.def_enemy_explosion(self)
	Events.boss_damaged.emit(hp/fullhp)
	sprite.material.set_shader_parameter("flash_modifier", 1.0)
	if dmgtween and dmgtween.is_running():
		dmgtween.kill()
	dmgtween = create_tween()
	dmgtween.tween_property(sprite.material, "shader_parameter/flash_modifier", 0.0, 0.3)

func _ready() -> void:
	sprite.material.set_shader_parameter("flash_modifier", 0.0)
	Events.flseye_shield_broken.connect(func(): shield_broken())
	Saves.data["ever_met_flseye"] = true
	dotScale = dot.scale
	var bar1PreSize = hpbar1.size.x
	hpbar.size.x *= fullhp / 3.5
	hpbar1.size.x = hpbar.size.x + 8.0
	var bar1NewSize = hpbar1.size.x
	hpbar1.position.x -= (bar1NewSize - bar1PreSize) / 2
	hpbar2.size.x = hpbar.size.x
	fullsize = hpbar.size.x
	await get_tree().create_timer(4.0, false).timeout
	Events.boss_animation_finished.emit()
	moving = true
	hitbox.disabled = false
	square1.visible = true
	square2.visible = true
	shotTimer.start()
	shieldcd.start()

func _physics_process(_delta: float) -> void:
	if not raycast_left == null:
		if raycast_left.is_colliding() or raycast_right.is_colliding():
			change_direction()

func change_direction():
	if cldown.time_left > 0:
		return
	raycast = true
	cldown.start()

@onready var dmgcldown := $dmgCldown
func periodic_dmg(dmg: float):
	if dmgcldown.time_left <= 0:
		Functions.dmg(self, dmg)
		if hp <= 0:
			Globals.change_points(givepts / 2)
		dmgcldown.wait_time = 1.0
		dmgcldown.start()

@onready var dmgcldown2 := $dmgCldown2
func beam_dmg(dmg: float):
	if dmgcldown2.time_left <= 0:
		Functions.dmg(self, dmg)
		if hp <= 0:
			Globals.change_points(givepts / 2)
		dmgcldown2.wait_time = 0.5
		dmgcldown2.start()

var exploded = false
var explosionsTime = 4.0
var afterExplosionsTime = 2.0
func die():
	shake_str = 0.0
	shieldcd.stop()
	Globals.bgStay = true
	Functions.flash(0.0, 3.0, 0.5)
	Functions.sfx_play("res://sounds/bossPreDeath.mp3", 10.0, randf_range(0.8, 1.0), false, 0.3)
	global_position = Vector2(390.0/2, 70.0)
	moving = false
	square1.visible = false
	square2.visible = false
	dot.visible = false
	if current_laser1:
		current_laser1.queue_free()
	if current_laser2:
		current_laser2.queue_free()
	if current_shield:
		current_shield.queue_free()
	if not hitbox:
		return
	for attack in get_tree().get_nodes_in_group("flseye_attack"):
		attack.queue_free()
	Saves.data["killed_flseyes"] += 1
	Saves.data["killed_enemies"] += 1
	died = true
	hitbox.queue_free()
	raycast_left.queue_free()
	raycast_right.queue_free()
	sprite.play("death")
	await get_tree().create_timer(3.0, false).timeout
	
	# DEATH ANIMATION
	shake()
	explosions()
	await get_tree().create_timer(explosionsTime, false).timeout
	exploded = true
	await get_tree().create_timer(afterExplosionsTime, false).timeout
	
	Functions.particle_explosion(self, global_position, randi_range(25, 40), color, 400, 2.0, 50, 1.5, 5.0, true, 0.4)
	Functions.flash(0.2, 2.0, 0.2, 0.9, Color("7200ff"))
	Functions.checkHeal()
	Globals.bgStay = false
	Globals.change_points(givepts)
	Functions.sfx_play("res://sounds/flseyeDead.mp3", 10.0)
	expl.visible = true
	expl.rotation_degrees = -rot
	FTween = create_tween()
	FTween.tween_property(expl, "rotation_degrees", rot * 2, expltime + explstay + unexpltime).as_relative()
	ATween = create_tween()
	ATween.tween_property(expl, "scale", Vector2(explsize, explsize), expltime).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	BTween = create_tween()
	BTween.tween_property(sprite, "modulate:a", 0.0, expltime)
	await get_tree().create_timer(expltime + explstay, false).timeout
	sprite.visible = false
	ATween = create_tween()
	ATween.tween_property(expl, "scale", Vector2(0.0, 0.0), unexpltime).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(afterdead, false).timeout
	Events.bossfight_end.emit()
	queue_free()

var shakestrength = 10.0
var shaketick = 0.05
func shake():
	var defspritepos = sprite.position
	while sprite:
		sprite.position.x = defspritepos.x + randf_range(-shakestrength, shakestrength)
		sprite.position.y = defspritepos.y + randf_range(-shakestrength, shakestrength)
		await get_tree().create_timer(shaketick, false).timeout

var explosionsTick = 0.4
var explosionPosRange = 80
var explosionScaleRange = 0.7
func explosions():
	while exploded == false:
		var explosion = explosionScene.instantiate()
		var explosionScale = 1.0 + randf_range(-explosionScaleRange, explosionScaleRange)
		explosion.position.x = sprite.position.x + randf_range(-explosionPosRange, explosionPosRange)
		explosion.position.y = sprite.position.y + randf_range(-explosionPosRange, explosionPosRange)
		explosion.scale.x *= explosionScale
		explosion.scale.y *= explosionScale
		explosion.hue = randf_range(-180, 180)
		add_child(explosion)
		Functions.sfx_play("res://sounds/damage.mp3", 0.0, randf_range(0.8, 1.2))
		await get_tree().create_timer(explosionsTick, false).timeout

var ATween: Tween
var BTween: Tween
var CTween: Tween
var DTween: Tween
var ETween: Tween
var FTween: Tween
var offpos = 3.5
var color2 := Color.BLUE

var attack_bag: Array = []
func shot():
	if died == true:
		return
	if attack_bag.is_empty():
		attack_bag = [0, 1, 2, 3]
		attack_bag.shuffle()
		if attack_bag[0] == last_attack:
			var first = attack_bag.pop_front()
			attack_bag.append(first)
	
	var random = attack_bag.pop_front()
	if random == 0:
		attackLaser()
	if random == 1:
		attackBeams()
	if random == 2:
		attackMovingBeams()
	if random == 3:
		attackCircle()

var laserBulletCount := 4
var laserBulletRange := 170.0
var laserBulletSlightRange := 5.0
var laserBulletYoffset := 50.0
var laserBulletXoffset := 20.0

var laserAttackTime = 1.5
var laserAttackFadeTime = 0.5
var laserAttackUPFadeTime = 0.1
var laserSize = 3.0
var laser_right: Tween
var laser_left: Tween
var laser_fade1: Tween
var laser_fade2: Tween
var dotTween: Tween
func attackLaser():
	last_attack = 0
	dot.scale = Vector2.ZERO
	dot.position.y = -29.0
	var laser1 = laserScene.instantiate()
	var laser2 = laserScene.instantiate()
	laser1.position = dot.position
	laser2.position = dot.position
	laser1.global_scale = Vector2(laserSize, laserSize)
	laser2.global_scale = Vector2(laserSize, laserSize)
	current_laser1 = laser1
	current_laser2 = laser2
	sprite.play("laserAttack")
	Functions.sfx_play("res://sounds/flseyeCharge.mp3", 0.0, randf_range(0.9, 1.1))
	await sprite.animation_finished
	if died == true:
		return
	dot.visible = true
	dotTween = create_tween()
	dotTween.tween_property(dot, "scale", dotScale, laserAttackUPFadeTime).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await dotTween.finished
	if died == true:
		return
	laserManager.add_child(laser1)
	laserManager.add_child(laser2)
	Functions.sfx_play("res://sounds/flseyeShot.mp3", 0.0, randf_range(0.95, 1.1))
	laser_right = create_tween()
	laser_left = create_tween()
	laser_right.tween_property(laser1, "rotation_degrees", 180, laserAttackTime).as_relative().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	laser_left.tween_property(laser2, "rotation_degrees", -180, laserAttackTime).as_relative().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(laserAttackTime / 3.0, false).timeout
	if died == true:
		return
	sprite.play("laserAttackCon1")
	dot.position.y = -17.0
	laser1.position = dot.position
	laser2.position = dot.position
	await get_tree().create_timer(laserAttackTime / 3.0, false).timeout
	if died == true:
		return
	sprite.play("laserAttackCon2")
	dot.position.y = 0.0
	laser1.position = dot.position
	laser2.position = dot.position
	await laser_left.finished
	if died == true:
		return
	laser1.audio.stop()
	laser2.audio.stop()
	if died == true:
		return
	Functions.sfx_play("res://sounds/flseyeShot.mp3", 0.0, randf_range(0.8, 0.95))
	for i in range(laserBulletCount):
		var bullet = flbulletScene.instantiate()
		var bullet2 = flbulletScene.instantiate()
		var first_pos = laserBulletRange / laserBulletCount
		bullet.direction = Vector2.LEFT
		bullet.global_position = Vector2(global_position.x - laserBulletXoffset + randf_range(-laserBulletSlightRange, laserBulletSlightRange), global_position.y + laserBulletYoffset + first_pos * i + randf_range(-laserBulletSlightRange, laserBulletSlightRange))
		bullet2.global_position = Vector2(global_position.x + laserBulletXoffset + randf_range(-laserBulletSlightRange, laserBulletSlightRange), global_position.y + laserBulletYoffset + first_pos * i + randf_range(-laserBulletSlightRange, laserBulletSlightRange))
		bullet.global_rotation_degrees = 180
		get_parent().add_child(bullet)
		get_parent().add_child(bullet2)
	sprite.play("laserAttackFin")
	laser_fade1 = create_tween().set_parallel(true)
	laser_fade2 = create_tween().set_parallel(true)
	laser_fade1.tween_property(laser1, "modulate:a", 0.0, laserAttackFadeTime)
	laser_fade2.tween_property(laser2, "modulate:a", 0.0, laserAttackFadeTime)
	dotTween = create_tween()
	dotTween.tween_property(dot, "scale", Vector2(0.0, 0.0), laserAttackFadeTime).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await laser_fade2.finished
	if died == true:
		return
	laser1.queue_free()
	laser2.queue_free()
	dot.visible = false
	shotTimer.start()

var afterBeamsTime = 1.5
var beamsAttackSpawnSpeed = 0.5
var beamsAttackSpawnSpeedRange = 0.3
func attackBeams():
	last_attack = 1
	sprite.play("beamsAttack")
	await sprite.animation_finished
	if died == true:
		return
	var beam1 = beamScene.instantiate()
	var beam2 = beamScene.instantiate()
	var beam3 = beamScene.instantiate()
	beam1.global_position = Vector2(randf_range(25.0, 365.0), 0.0)
	beam2.global_position = Vector2(randf_range(25.0, 365.0), 0.0)
	beam3.global_position = Vector2(randf_range(25.0, 365.0), 0.0)
	get_parent().add_child(beam1)
	await get_tree().create_timer(beamsAttackSpawnSpeed + randf_range(-beamsAttackSpawnSpeedRange, beamsAttackSpawnSpeedRange), false).timeout
	if died == true:
		return
	get_parent().add_child(beam2)
	await get_tree().create_timer(beamsAttackSpawnSpeed + randf_range(-beamsAttackSpawnSpeedRange, beamsAttackSpawnSpeedRange), false).timeout
	if died == true:
		return
	get_parent().add_child(beam3)
	sprite.play("laserAttackFin")
	await get_tree().create_timer(afterBeamsTime, false).timeout
	if died == true:
		return
	shotTimer.start()

func attackMovingBeams():
	sprite.play("blink")
	last_attack = 3
	var beam1 = beamScene.instantiate()
	var beam2 = beamScene.instantiate()
	beam1.global_position = Vector2(-30.0, 0.0)
	beam1.alter = true
	beam2.global_position = Vector2(420.0, 0.0)
	beam2.alter = true
	beam2.dir = -1
	get_parent().add_child(beam1)
	get_parent().add_child(beam2)
	await beam2.fin
	if died == true:
		return
	shotTimer.start()

var circleCount := 12
var betweenCircles := 0.4
var circleSpeed := 80.0
var sqt: Tween
func attackCircle():
	stopped = true
	if sqt and sqt.is_running():
		sqt.kill()
	Functions.sfx_play("res://sounds/flseyeCharge1.mp3", 7.0, randf_range(0.9, 1.1))
	sqt = create_tween()
	sqt.tween_property(self, "squarespeed", 720, 1.0)
	await sqt.finished
	if died == true:
		return
	attackCircle0()
	await get_tree().create_timer(betweenCircles, false).timeout
	if died == true:
		return
	attackCircle0()
	await get_tree().create_timer(betweenCircles, false).timeout
	if died == true:
		return
	attackCircle0()
	sqt = create_tween()
	sqt.tween_property(self, "squarespeed", 180, 1.0)
	stopped = false
	await get_tree().create_timer(betweenCircles, false).timeout
	shotTimer.start()

func attackCircle0():
	shake_str = 10.0
	Functions.sfx_play("res://sounds/flseyeShot.mp3", 0.0, randf_range(0.9, 1.1))
	var angle_step = TAU / circleCount
	for i in range(circleCount):
		var current_angle = i * angle_step
		var bullet = flbulletScene.instantiate()
		bullet.global_position = global_position
		bullet.global_rotation = current_angle
		bullet.direction = Vector2.RIGHT.rotated(current_angle)
		bullet.speed = circleSpeed
		get_parent().add_child(bullet)

func _on_dmgstop_timeout() -> void:
	ETween = create_tween()
	ETween.tween_property(hpbar2, "size:x", (fullsize / fullhp) * hp, bar2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func enrage():
	if enraged == true:
		return
	Functions.sfx_play("res://sounds/ENRAGE.mp3", -5.0, 0.8)
	enrageLoop.play()
	enraged = true
	enrageEffect.visible = true
	enrageEffect.scale = Vector2(1.0, 1.0)
	enrageEffect.modulate.a = 1.0
	var etween1 = create_tween()
	var etween2 = create_tween()
	etween1.tween_property(enrageEffect, "scale", Vector2(5.0, 5.0), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	etween2.tween_property(enrageEffect, "modulate:a", 0.0, 1.0)
	sprite.modulate = enrageColor

func unenrage():
	enrageLoop.stop()
	enraged = false
	sprite.modulate = Color.WHITE

func shield_broken():
	shieldcd.start()

func _on_shield_cd_timeout() -> void:
	var Shield = shieldScene.instantiate()
	add_child(Shield)
	current_shield = Shield
