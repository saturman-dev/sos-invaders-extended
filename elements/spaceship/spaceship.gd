extends CharacterBody2D

const rocket_scene = preload("res://elements/bullet/bullet.tscn")

@onready var cdt := $CD
@onready var shit := $ShootEffect
@onready var sprite := $sprite
var cd = 0.2
var defcd  = cd
var INVINCIBLE := 1.5
var dmg = 1.0

@export var speed = 150.0
@export var acceleration = speed * 6

@onready var defShitSize = shit.scale
var trioShitSize = Vector2(4.5, 4.5)

func _ready() -> void:
	Globals.bonusSpeedActive = false
	Globals.bonusTrioActive = false
	Globals.bonusSplashActive = false

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("ui_accept"):
		if cdt.is_stopped():
			shot()
			cdt.start(cd)

	var direction = Vector2.ZERO
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	direction = direction.normalized()
	var target_velocity = direction * speed
	velocity = velocity.move_toward(target_velocity, acceleration * delta)
	move_and_slide()

func shot():
	if Globals.bonusTrioActive == true:
		Functions.sfx_play("res://sounds/defaultFire.mp3", -6.0, randf_range(0.85, 0.95))
	else:
		Functions.sfx_play("res://sounds/defaultFire.mp3", -7.0, randf_range(0.95, 1.05))
	shit.frame = 0
	shit.play("shoot")
	var rocket = rocket_scene.instantiate()
	rocket.global_position = global_position + Vector2(0, -15)
	add_child(rocket)
	rocket.damage = dmg
	if Globals.bonusTrioActive == true:
		var rocketL = rocket_scene.instantiate()
		rocketL.global_position = global_position + Vector2(-5, -15)
		add_child(rocketL)
		rocketL.damage = dmg
		rocketL.left()
		var rocketR = rocket_scene.instantiate()
		rocketR.global_position = global_position + Vector2(5, -15)
		add_child(rocketR)
		rocketR.damage = dmg
		rocketR.right()
		if Globals.bonusSplashActive == true:
			rocketR.splash()
			rocketL.splash()
		if Globals.bonusSpeedActive == true:
			rocketR.speedup()
			rocketL.speedup()
	if Globals.bonusSplashActive == true:
		rocket.splash()
	if Globals.bonusSpeedActive == true:
		rocket.speedup()

var is_invincible := false

func takeDmg():
	is_invincible = true
	set_collision_layer_value(2, false)
	Globals.apply_shake(5.0)
	if Globals.overlives == 0:
		Globals.change_lives(-1)
	else:
		Globals.change_overlives(-1)
	sprite.play("dmg")
	await get_tree().create_timer(INVINCIBLE, false).timeout
	sprite.play("def")
	set_collision_layer_value(2, true)
	is_invincible = false

func die():
	sprite.play("dmg")

func ZONE():
	pass

func unZONE():
	pass

var gh = 0.035
func ghosts():
	while Globals.bonusSpeedActive == true:
		Functions.add_ghost(self, 0.5, 0.3)
		await get_tree().create_timer(gh, false).timeout

@onready var bonusGained = $bonusGained
@onready var trio = $NicknameTrio

func playBonusGained():
	Functions.sfx_play("res://sounds/bonusGained.mp3")

func playBonusEnded():
	Functions.sfx_play("res://sounds/bonusEnded.mp3")

func bonusTrio():
	playBonusGained()
	get_parent().addBonus("trio")
	bonusGained.modulate = Color("FF00DD")
	bonusGained.frame = 0
	bonusGained.play("new_animation")
	Globals.bonusTrioActive = true
	trio.visible = true
	shit.scale = trioShitSize
	await get_tree().create_timer(Globals.trioTimer, false).timeout
	shit.scale = defShitSize
	Globals.bonusTrioActive = false
	trio.visible = false
	playBonusEnded()

var bonusSpeedMod = 1.5
func bonusSpeed():
	speed *= bonusSpeedMod
	acceleration *= bonusSpeedMod
	cd /= bonusSpeedMod
	playBonusGained()
	get_parent().addBonus("speed")
	bonusGained.modulate = Color("00FFF6")
	bonusGained.frame = 0
	bonusGained.play("new_animation")
	Globals.bonusSpeedActive = true
	ghosts()
	await get_tree().create_timer(Globals.speedTimer, false).timeout
	cd *= bonusSpeedMod
	speed /= bonusSpeedMod
	acceleration /= bonusSpeedMod
	Globals.bonusSpeedActive = false
	playBonusEnded()

func bonusHeal():
	Functions.sfx_play("res://sounds/bonusHeal.mp3")
	bonusGained.modulate = Color("00ff22")
	bonusGained.frame = 0
	bonusGained.play("new_animation")
	Globals.change_lives(1)

func bonusOverheal():
	Functions.sfx_play("res://sounds/bonusOverheal.mp3")
	bonusGained.modulate = Color("ffff00")
	bonusGained.frame = 0
	bonusGained.play("new_animation")
	Globals.change_overlives(1)

func bonusSplash():
	playBonusGained()
	get_parent().addBonus("splash")
	bonusGained.modulate = Color("ff0009")
	bonusGained.frame = 0
	bonusGained.play("new_animation")
	shit.modulate = Color.DEEP_SKY_BLUE
	Globals.bonusSplashActive = true
	await get_tree().create_timer(Globals.splashTimer, false).timeout
	Globals.bonusSplashActive = false
	shit.modulate = Color.WHITE
	playBonusEnded()
