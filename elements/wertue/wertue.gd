extends CharacterBody2D

const color = Color("00ffdc")

var NEO = false

# FOR DAMAGE
var fullhp = 10.0
var hp = fullhp
var yellwait = 0.7
@onready var timer := $dmgstop
@onready var sprite := $AnimatedSprite2D
var dmgColor = Color.RED
@onready var hpbar := $hpfull/hp
var bar1 = 0.2
var fullsize = 0.0
var undam = 0.3

var givepts = 7
var died = false
var bar2 = 0.4
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
@onready var hpbar1 := $hpfull
@onready var hpbar2 := $hpfull/hp2
@onready var expl := $NormTema
@onready var cldown := $cldown
@onready var shotTimer := $shotTimer
@onready var wingRight := $wingRight
@onready var wingLeft := $wingLeft
@onready var circle := $AnimatedSprite2D/circle
@onready var enrageEffect := $enrageEffect
@onready var enrageLoop := $ENRAGED
@onready var hitbox := $CollisionShape2D



var direction := int([-1, 1].pick_random())
var defspeed := 25.0
var speed := defspeed
var yspeed = 15.0
var raycast = false
var dirChanging := 40.0

func _process(delta: float) -> void:
	if raycast == true:
		speed -= dirChanging * delta
		if speed < -defspeed:
			raycast = false
			speed *= -1
			direction *= -1
	global_position.x += direction * speed * delta
	global_position.y += yspeed * delta
	yspeed -= delta * 0.8 if yspeed > 0.1 else 0.0

func _on_shot_timer_timeout() -> void:
		shot()

var enabled = true

var CrTween: Tween

func damageAnimation():
	Functions.def_enemy_explosion(self)
	if CrTween and CrTween.is_running():
		CrTween.kill()
	circle.visible = true
	circle.modulate.a = 1.0
	CrTween = create_tween()
	CrTween.tween_property(circle, "modulate:a", 0.0, 0.35)

func _ready() -> void:
	Saves.data["ever_met_wertue"] = true
	wingLeft.left()
	var bar1PreSize = hpbar1.size.x
	hpbar.size.x *= fullhp / 3.5
	hpbar1.size.x = hpbar.size.x + 8.0
	var bar1NewSize = hpbar1.size.x
	hpbar1.position.x -= (bar1NewSize - bar1PreSize) / 2
	hpbar2.size.x = hpbar.size.x
	fullsize = hpbar.size.x

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

func die():
	remove_from_group("enemies")
	if not hitbox:
		return
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
	died = true
	Globals.change_points(givepts)
	hitbox.queue_free()
	raycast_left.queue_free()
	raycast_right.queue_free()
	CTween = create_tween()
	CTween.tween_property(hpbar, "size:x", (fullsize / fullhp) * hp, bar1 * 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	ETween = create_tween()
	ETween.tween_property(hpbar2, "size:x", (fullsize / fullhp) * hp, bar2 * 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
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
		if NEO == true:
			var bullet2 = bulletScene.instantiate()
			get_parent().add_child(bullet2)
			bullet2.parentConnect(self)
			bullet.turn90()

func newShot():
	if failedAttacks >= maxFailedAttacks:
		enrage()
	await get_tree().create_timer(betweenAttacks, false).timeout
	shot()

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
	wingLeft.modulate = enrageColor
	wingRight.modulate = enrageColor

func unenrage():
	enrageLoop.stop()
	enraged = false
	sprite.modulate = Color.WHITE
	wingLeft.modulate = Color.WHITE
	wingRight.modulate = Color.WHITE
