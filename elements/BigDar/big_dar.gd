extends CharacterBody2D

const color = Color("18ff3b")

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

var givepts = 2
var died = false
var bar2 = 0.4
var expltime = 0.2
var explsize = 3.0
var explstay = 0.2
var unexpltime = 0.3
var afterdead = 2.0
var rot = randf_range(10.0, 30.0)
var bonus_blocked = false

const bulletScene = preload("res://elements/bobm/bobm.tscn")

@onready var raycast_left := $RayCastLeft
@onready var raycast_right := $RayCastRight
@onready var hpbar1 := $hpfull
@onready var hpbar2 := $hpfull/hp2
@onready var expl := $Slabovat
@onready var cldown := $cldown
@onready var shotTimer := $shotTimer
@onready var hitbox := $CollisionShape2D



var direction := int([-1, 1].pick_random())
var speed := 20.0
var yspeed = 15.0

func _process(delta: float) -> void:
	global_position.x += direction * speed * delta
	global_position.y += yspeed * delta
	yspeed -= delta * 1.0 if yspeed > 0.1 else 0.0

func _on_shot_timer_timeout() -> void:
		shot()
		shotTimer.wait_time = randf_range(5.0, 7.5)
		shotTimer.start()

var enabled = true

func _ready() -> void:
	sprite.material.set_shader_parameter("flash_modifier", 0.0)
	Saves.data["ever_met_bigdar"] = true
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
	direction = -1 if direction == 1 else 1
	cldown.start()

@onready var dmgcldown := $dmgCldown
func periodic_dmg(dmg: float):
	if dmgcldown.time_left <= 0:
		if Saves.data["ever_got_splash_bonus"] == false:
			Saves.data["ever_got_splash_bonus"] = true
			Functions.notify("New \"Splash\" bonus added!!", "Go catch it!")
			Functions.add_bonus("splash", global_position)
			bonus_blocked = true
		Functions.dmg(self, fullhp)
		PtbonusesManager.ptbonus(givepts, "EXPLODED", Color("18ff3b"))
		PtbonusesManager.ptbonus(givepts/2, "SELFHARM", Color("d03e79"))

@onready var dmgcldown2 := $dmgCldown2
func beam_dmg(dmg: float):
	if dmgcldown2.time_left <= 0:
		Functions.dmg(self, dmg)
		if hp <= 0:
			PtbonusesManager.ptbonus(givepts * 2, "MADE IN HEAVEN", Color("00ffdc"))

var dmgtween: Tween
func damageAnimation():
	Functions.def_enemy_explosion(self)
	sprite.material.set_shader_parameter("flash_brightness", 1.0)
	if dmgtween and dmgtween.is_running():
		dmgtween.kill()
	dmgtween = create_tween()
	dmgtween.tween_property(sprite.material, "shader_parameter/flash_brightness", 0.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func die():
	if not hitbox:
		return
	remove_from_group("enemies")
	Events.enemy_killed.emit()
	Functions.mid_enemy_explosion(self)
	Saves.data["killed_bigdars"] += 1
	Functions.checkHeal()
	Saves.data["killed_enemies"] += 1
	if bonus_blocked == false:
		Functions.addRandomBonus(self)
	Functions.sfx_play("res://sounds/bigDarDead.mp3", 0.0, randf_range(0.9, 1.1))
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
var offpos = 6.5
var color1 := Color.BLACK
var color2 := Color.GREEN_YELLOW

var stw: Tween
func shot():
	var defscale = sprite.scale
	if stw and stw.is_running():
		stw.kill()
	stw = create_tween()
	stw.tween_property(sprite, "scale", Vector2(defscale.x * 1.75, defscale.y * 0.65), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	stw.tween_callback(spawn_bullet)
	stw.tween_property(sprite, "scale", Vector2(defscale.x * 0.65, defscale.y * 1.75), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	stw.chain().tween_property(sprite, "scale", defscale, 2.0).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func spawn_bullet():
	if died == false:
		Functions.sfx_play("res://sounds/bigDarFire.mp3")
		var bullet = bulletScene.instantiate()
		bullet.global_position += global_position + Vector2(0, 5.0)
		get_parent().add_child(bullet)

func _on_dmgstop_timeout() -> void:
	ETween = create_tween()
	ETween.tween_property(hpbar2, "size:x", (fullsize / fullhp) * hp, bar2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
