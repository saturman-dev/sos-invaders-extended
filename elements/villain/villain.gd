extends CharacterBody2D

const color = Color("ffc472")

var SPEEDMOD := 1.0
var NEO := 0
var bullet_direction := Vector2.DOWN
var player: Object = null
var AIMING := false

var fullhp = 2.5
var hp = fullhp
@onready var sprite := $AnimatedSprite2D

var givepts = 1
var died = false
var expltime = 0.2
var explsize = 3.0
var explstay = 0.2
var unexpltime = 0.3
var afterdead = 2.0
var rot = randf_range(10.0, 30.0)

const bulletScene = preload("res://elements/vlnbullet/vlnbullet.tscn")

@onready var raycast_left := $RayCastLeft
@onready var raycast_right := $RayCastRight
@onready var hpbar := $hpfull
@onready var expl := $Slabo
@onready var hitbox := $CollisionShape2D

var enabled = true

var shotOffset = 5.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	sprite.material.set_shader_parameter("flash_modifier", 0.0)
	Saves.data["ever_met_darsin"] = true
	
	await hpbar.setted_default
	sethp()

func sethp():
	hp = fullhp
	hpbar.set_hp(fullhp)

func _process(delta: float) -> void:
	if AIMING and is_instance_valid(player) and NEO > 0:
		var target_dir = (player.global_position - global_position).normalized()
		var target_angle = target_dir.angle() - PI/2
		
		sprite.rotation = lerp_angle(sprite.rotation, target_angle, 50.0 * delta)

func _physics_process(_delta: float) -> void:
	if not raycast_left == null:
		if raycast_left.is_colliding() or raycast_right.is_colliding():
			get_parent().change_direction()

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
	if died:
		return
	died = true
	remove_from_group("enemies")
	Events.enemy_killed.emit()
	Functions.dead_enemy_explosion(self)
	Saves.data["killed_darsins"] += 1
	Functions.checkHeal()
	Saves.data["killed_enemies"] += 1
	Functions.addRandomBonus(self, 0.33)
	Functions.sfx_play("res://sounds/darsinDead.mp3", 0.0, randf_range(0.9, 1.1))
	Globals.change_points(givepts * NEO)
	hitbox.queue_free()
	raycast_left.queue_free()
	raycast_right.queue_free()
	expl.visible = true
	expl.rotation_degrees = -rot
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
var offpos = 5.0

var stw: Tween

func shot():
	if not is_instance_valid(player): return
	
	AIMING = true
	
	var defscale = sprite.scale
	if stw and stw.is_running():
		stw.kill()
	stw = create_tween()
	stw.tween_property(sprite, "scale", Vector2(defscale.x * 1.5, defscale.y * 0.75), 1.0 / SPEEDMOD).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	stw.tween_callback(func():
		spawn_bullet()
		AIMING = false
		)
	stw.tween_property(sprite, "scale", Vector2(defscale.x * 0.75, defscale.y * 1.5), 0.1 / SPEEDMOD).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	stw.chain().tween_property(sprite, "scale", defscale, 1.0 / SPEEDMOD).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	stw.parallel().tween_property(sprite, "rotation", 0.0, 1.0 / SPEEDMOD)

func spawn_bullet():
	if died == false:
		
		var shoot_dir = Vector2.DOWN.rotated(sprite.rotation)
		var bullet_pos = global_position + (shoot_dir * shotOffset)
		
		Functions.sfx_play("res://sounds/enemyFire.mp3", 0.0, randf_range(0.8, 1.2))
		var bullet = bulletScene.instantiate()
		
		bullet.global_position = bullet_pos
		bullet.set_direction(shoot_dir)
		
		get_parent().add_child(bullet)
		bullet.SPEEDMOD = SPEEDMOD
		bullet.scale *= SPEEDMOD
