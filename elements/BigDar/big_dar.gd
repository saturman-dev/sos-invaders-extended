extends CharacterBody2D

const color = Color("18ff3b")

var SPEEDMOD := 1.0
var NEO := 0

# FOR DAMAGE
var fullhp = 10.0
var hp = fullhp
@onready var sprite := $AnimatedSprite2D
@onready var hpbar := $hpfull

var givepts = 2
var died = false
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
@onready var expl := $Slabovat
@onready var cldown := $cldown
@onready var shotTimer := $shotTimer
@onready var hitbox := $CollisionShape2D



var direction := int([-1, 1].pick_random())
var speed := 20.0
var defyspeed = 15.0
var yspeed = defyspeed

func _process(delta: float) -> void:
	if global_position.y < 15:
		yspeed = defyspeed * 5
	else:
		yspeed = defyspeed
	global_position.x += direction * speed * delta * SPEEDMOD
	global_position.y += yspeed * delta * (1 + ((SPEEDMOD - 1) / 2))
	yspeed -= delta * 1.0 if yspeed > 0.1 else 0.0

func _on_shot_timer_timeout() -> void:
		shot()
		shotTimer.wait_time = randf_range(5.0, 7.5) / SPEEDMOD
		shotTimer.start()

var enabled = true

func _ready() -> void:
	
	global_position = Vector2(randf_range(20, get_viewport_rect().size.x - 20), -13)
	
	sprite.material.set_shader_parameter("flash_modifier", 0.0)
	
	Saves.data["ever_met_bigdar"] = true
	
	await hpbar.setted_default
	sethp()
	shotTimer.wait_time = randf_range(5.0, 7.5) / 5.0 / SPEEDMOD
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

var dietween: Tween
var dietween2: Tween

func die():
	if died or not hitbox:
		return
	died = true
	remove_from_group("enemies")
	Events.enemy_killed.emit()
	Functions.mid_enemy_explosion(self)
	Saves.data["killed_bigdars"] += 1
	Functions.checkHeal()
	Saves.data["killed_enemies"] += 1
	if bonus_blocked == false:
		Functions.addRandomBonus(self)
	Functions.sfx_play("res://sounds/bigDarDead.mp3", 0.0, randf_range(0.9, 1.1))
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
	stw.tween_property(sprite, "scale", Vector2(defscale.x * 1.75, defscale.y * 0.65), 1.0 / SPEEDMOD).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	stw.tween_callback(spawn_bullet)
	stw.tween_property(sprite, "scale", Vector2(defscale.x * 0.65, defscale.y * 1.75), 0.2 / SPEEDMOD).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	stw.chain().tween_property(sprite, "scale", defscale, 2.0 / SPEEDMOD).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func spawn_bullet():
	if died == false:
		Functions.sfx_play("res://sounds/bigDarFire.mp3")
		var bullet = bulletScene.instantiate()
		bullet.global_position = global_position + Vector2(0, 5.0)
		bullet.SPEEDMOD = SPEEDMOD
		bullet.NEO = NEO
		get_parent().add_child(bullet)
