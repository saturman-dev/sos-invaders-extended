extends CharacterBody2D

const color = Color("00ffdc")

var SPEEDMOD := 1.0
var NEO := 0

# FOR DAMAGE
var fullhp = 25.0
var hp = fullhp
@onready var sprite := $AnimatedSprite2D
@onready var hpbar := $hpfull

var givepts = 7
var died = false
var expltime = 0.2
var explsize = 3.0
var explstay = 0.2
var unexpltime = 0.3
var afterdead = 2.0
var rot = randf_range(10.0, 30.0)
var enraged = false
var betweenAttacks := 0.5
var failedAttacks := 0
var maxFailedAttacks := 2
var enrageColor := Color.RED

const bulletScene = preload("res://elements/wertue/wertueBeam.tscn")

@onready var raycast_left := $RayCastLeft
@onready var raycast_right := $RayCastRight
@onready var expl := $NormTema
@onready var cldown := $cldown
@onready var shotTimer := $shotTimer
@onready var wingRight := $wingRight
@onready var wingLeft := $wingLeft
@onready var enrageEffect := $enrageEffect
@onready var enrageLoop := $ENRAGED
@onready var hitbox := $CollisionShape2D



var direction := int([-1, 1].pick_random())
var defspeed := 25.0
var speed := defspeed
var yspeed = defyspeed
var defyspeed = 13.5
var raycast = false
var dirChanging := 40.0

func _process(delta: float) -> void:
	if global_position.y < 15:
		yspeed = defyspeed * 5
	else:
		yspeed = defyspeed
	if raycast == true:
		speed -= dirChanging * delta
		if speed < -defspeed:
			raycast = false
			speed *= -1
			direction *= -1
	global_position.x += direction * speed * delta * SPEEDMOD
	global_position.y += yspeed * delta * (1 + (SPEEDMOD - 1) / 4)
	yspeed -= delta * 0.8 * (1 + (SPEEDMOD - 1) / 8) if yspeed > 0.1 else 0.0

func _on_shot_timer_timeout() -> void:
		shot()

var enabled = true

var dmgtween: Tween

func damageAnimation():
	Functions.def_enemy_explosion(self)
	sprite.material.set_shader_parameter("flash_brightness", 1.0)
	if dmgtween and dmgtween.is_running():
		dmgtween.kill()
	dmgtween = create_tween()
	dmgtween.tween_property(sprite.material, "shader_parameter/flash_brightness", 0.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func _ready() -> void:
	global_position = Vector2(randf_range(54, get_viewport_rect().size.x - 55), -26)
	Saves.data["ever_met_wertue"] = true
	wingLeft.left()
	
	await hpbar.setted_default
	sethp()
	shotTimer.wait_time /= SPEEDMOD
	shotTimer.start()

func sethp():
	hp = fullhp
	hpbar.set_hp(fullhp)

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
			PtbonusesManager.ptbonus(givepts, "EXPLODED", Color("18ff3b"))
		dmgcldown.wait_time = 1.0
		dmgcldown.start()

@onready var dmgcldown2 := $dmgCldown2
func beam_dmg(dmg: float):
	if dmgcldown2.time_left <= 0:
		Functions.dmg(self, dmg)
		if hp <= 0:
			PtbonusesManager.ptbonus(givepts, "MADE IN HEAVEN", Color("00ffdc"))
			PtbonusesManager.ptbonus(givepts, "FRIENDLY BEAMING", Color("1873fe"))
		dmgcldown2.wait_time = 0.5
		dmgcldown2.start()

var dietween: Tween
var dietween2: Tween

func die():
	if died:
		return
	died = true
	enrageLoop.stop()
	remove_from_group("enemies")
	Events.enemy_killed.emit()
	Functions.big_enemy_explosion(self)
	Saves.data["killed_wertues"] += 1
	Functions.checkHeal()
	Saves.data["killed_enemies"] += 1
	wingLeft.die()
	wingRight.die()
	if Saves.data["ever_got_speed_bonus"] == false:
		Saves.data["ever_got_speed_bonus"] = true
		Functions.notify("New \"Speed\" bonus added!!", "Go catch it!")
		Functions.add_bonus("speed", global_position)
	else:
		Functions.addRandomBonus(self, 2.0)
	Functions.sfx_play("res://sounds/wertueDead.mp3", -5.0, randf_range(0.9, 1.1))
	Globals.change_points(givepts * (1 + NEO))
	hitbox.queue_free()
	raycast_left.queue_free()
	raycast_right.queue_free()
	expl.visible = true
	dietween = create_tween()
	dietween.tween_property(expl, "rotation_degrees", rot * 2, expltime + explstay + unexpltime).as_relative()
	dietween.parallel().tween_property(expl, "scale", Vector2(explsize, explsize), expltime).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	dietween.parallel().tween_property(sprite, "scale", Vector2.ZERO, expltime)
	await get_tree().create_timer(expltime + explstay).timeout
	sprite.visible = false
	dietween2 = create_tween()
	dietween2.tween_property(expl, "scale", Vector2(0.0, 0.0), unexpltime).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(afterdead, false).timeout
	queue_free()


var ATween: Tween
var BTween: Tween
var CTween: Tween
var DTween: Tween
var ETween: Tween
var FTween: Tween
var offpos = 3.5
var color2 := Color.BLUE

func shot():
	if died == false:
		var bullet = bulletScene.instantiate()
		get_parent().add_child(bullet)
		bullet.parentConnect(self)
		bullet.NEO2 = NEO
		bullet.SPEEDMOD = SPEEDMOD
		if NEO > 0:
			var bullet2 = bulletScene.instantiate()
			get_parent().add_child(bullet2)
			bullet2.parentConnect(self)
			bullet2.turn90()
			bullet2.NEO = NEO
			bullet2.NEO2 = NEO
			bullet2.SPEEDMOD = SPEEDMOD

func newShot():
	if failedAttacks >= maxFailedAttacks:
		enrage()
	await get_tree().create_timer(betweenAttacks / SPEEDMOD, false).timeout
	shot()

func enrage():
	if enraged == true or died == true:
		return
	Functions.sfx_play("res://sounds/ENRAGE.mp3", -5.0, 0.8)
	PtbonusesManager.ptbonus(givepts / 2, "ENRAGED", Color.RED)
	enrageLoop.play()
	enraged = true
	enrageEffect.visible = true
	enrageEffect.scale = Vector2(1.0, 1.0)
	enrageEffect.modulate.a = 1.0
	var etween1 = create_tween()
	var etween2 = create_tween()
	etween1.tween_property(enrageEffect, "scale", Vector2(5.0, 5.0), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	etween2.tween_property(enrageEffect, "modulate:a", 0.0, 1.0)
	sprite.material.set_shader_parameter("rage_intensity", 1.0)
	wingLeft.material.set_shader_parameter("rage_intensity", 1.0)
	wingRight.material.set_shader_parameter("rage_intensity", 1.0)

func unenrage():
	enrageLoop.stop()
	enraged = false
	if not sprite:
		return
	var unetween = create_tween()
	if not unetween or not sprite:
		return
	unetween.tween_property(sprite.material, "shader_parameter/rage_intensity", 0.0, 0.5)
	unetween.parallel().tween_property(wingLeft.material, "shader_parameter/rage_intensity", 0.0, 0.5)
	unetween.parallel().tween_property(wingRight.material, "shader_parameter/rage_intensity", 0.0, 0.5)
