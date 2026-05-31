extends CharacterBody2D

var SPEEDMOD := 1.0
var NEO := 0
var bullet_angle := 20

const color = Color("fb00cf")

# FOR DAMAGE
var fullhp = 7.5
var hp = fullhp
@onready var sprite := $AnimatedSprite2D

var givepts = 4
var died = false
var bar2 = 0.4
var expltime = 0.2
var explsize = 3.0
var explstay = 0.2
var unexpltime = 0.3
var afterdead = 2.0
var rot = randf_range(10.0, 30.0)

const bulletScene = preload("res://elements/a3bullet/a_3_bullet.tscn")
const linkerScene = preload("res://elements/bulletLinker/bullet_linker.tscn")

@onready var raycast_left := $RayCastLeft
@onready var raycast_right := $RayCastRight
@onready var hpbar := $hpfull
@onready var expl := $NormTema
@onready var cldown := $cldown
@onready var shotTimer := $shotTimer
@onready var hitbox := $CollisionShape2D

# HPBAR SETUP



var direction := int([-1, 1].pick_random())
var defspeed := 40.0
var speed := defspeed
var yspeed = defyspeed
var defyspeed = 18.0
var raycast = false
var dirChanging := 80.0

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
	global_position.y += yspeed * delta * (1 + (SPEEDMOD - 1) / 10)
	yspeed -= delta * 0.8 * (1 + (SPEEDMOD - 1) / 2) if yspeed > 0.1 else 0.0

func _on_shot_timer_timeout() -> void:
		shot()
		shotTimer.wait_time = randf_range(4.0, 5.5) / SPEEDMOD
		shotTimer.start()

var enabled = true

func _ready() -> void:
	global_position = Vector2(randf_range(51, get_viewport_rect().size.x - 51), -16)
	sprite.material.set_shader_parameter("flash_modifier", 0.0)
	Saves.data["ever_met_a3"] = true
	
	await hpbar.setted_default
	sethp()
	shotTimer.wait_time = 1.0 / SPEEDMOD
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
			PtbonusesManager.ptbonus(givepts * 2, "MADE IN HEAVEN", Color("00ffdc"))
		dmgcldown2.wait_time = 0.5
		dmgcldown2.start()

var dietween: Tween
var dietween2: Tween

func die():
	if died:
		return
	died = true
	Events.enemy_killed.emit()
	remove_from_group("enemies")
	Functions.big_enemy_explosion(self)
	Saves.data["killed_a3s"] += 1
	Functions.checkHeal()
	Saves.data["killed_enemies"] += 1
	if Saves.data["ever_got_trio_bonus"] == false:
		Saves.data["ever_got_trio_bonus"] = true
		Functions.notify("New \"Trio\" bonus added!!", "Go catch it!")
		Functions.add_bonus("trio", global_position)
	else:
		Functions.addRandomBonus(self)
	Functions.sfx_play("res://sounds/A3Dead.mp3", -8.0, randf_range(0.9, 1.1))
	Globals.change_points(givepts * NEO)
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

var dmgtween: Tween
func damageAnimation():
	Functions.def_enemy_explosion(self)
	sprite.material.set_shader_parameter("flash_brightness", 1.0)
	if dmgtween and dmgtween.is_running():
		dmgtween.kill()
	dmgtween = create_tween()
	dmgtween.tween_property(sprite.material, "shader_parameter/flash_brightness", 0.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

var ATween: Tween
var BTween: Tween
var CTween: Tween
var DTween: Tween
var ETween: Tween
var FTween: Tween
var offpos = 3.5
var color2 := Color.BLUE

func shot():
	sprite.play("preshot1")
	await get_tree().create_timer(0.5 / SPEEDMOD, false).timeout
	if died == false:
		sprite.play("preshot2")
		Functions.sfx_play("res://sounds/A3Reload1.mp3", -10.0)
	await get_tree().create_timer(0.5 / SPEEDMOD, false).timeout
	if died == false:
		sprite.play("preshot3")
		Functions.sfx_play("res://sounds/A3Reload2.mp3", -10.0)
	await get_tree().create_timer(0.5 / SPEEDMOD, false).timeout
	sprite.play("def")
	spawn_bullets()
	ATween = create_tween().set_parallel(true)
	ATween.tween_property(self, "position", Vector2(0.0, -offpos), 0.10 / SPEEDMOD).as_relative().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await ATween.finished
	ATween = create_tween().set_parallel(true)
	ATween.tween_property(self, "position", Vector2(0.0, offpos), 0.5 / SPEEDMOD).as_relative().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func spawn_bullets():
	if died == false:
		Functions.sfx_play("res://sounds/A3Fire.mp3", -7.5)
		var bullet = bulletScene.instantiate()
		bullet.global_position += global_position + Vector2(0, 5.0)
		bullet.SPEEDMOD = SPEEDMOD
		var bulletl = bulletScene.instantiate()
		bulletl.global_position += global_position + Vector2(-4.0, 5.0)
		bulletl.SPEEDMOD = SPEEDMOD
		var bulletr = bulletScene.instantiate()
		bulletr.global_position += global_position + Vector2(4.0, 5.0)
		bulletr.SPEEDMOD = SPEEDMOD
		get_parent().add_child(bullet)
		get_parent().add_child(bulletl)
		get_parent().add_child(bulletr)
		bulletl.left()
		bulletr.right()
		
		if NEO > 0:
			var bulletll = bulletScene.instantiate()
			bulletll.global_position += global_position + Vector2(-8.0, 5.0)
			bulletll.SPEEDMOD = SPEEDMOD
			var bulletrr = bulletScene.instantiate()
			bulletrr.global_position += global_position + Vector2(8.0, 5.0)
			bulletrr.SPEEDMOD = SPEEDMOD
			get_parent().add_child(bulletll)
			get_parent().add_child(bulletrr)
			bulletll.lleft()
			bulletrr.rright()
			
			var linker = linkerScene.instantiate()
			var allbullets: Array[Node2D] = [bulletll, bulletl, bullet, bulletr, bulletrr]
			linker.base_width *= SPEEDMOD
			get_parent().add_child(linker)
			linker.tracked_bullets = allbullets
