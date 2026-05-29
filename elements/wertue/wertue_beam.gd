extends Area2D

var NEO := 0
var NEO2 := 0
var SPEEDMOD := 1.0
var speedmodmod := 2

signal warrned
var is_attacking := false

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
@onready var aimer := $aimer

var wertue = 0
var enragedColor = Color.RED
var warnTickTime = 0.025

# Переменные состояний луча
# Возможные состояния: "WAIT", "WARNING", "INTERRUPTION", "ATTACK", "FINISHED"
var current_state := "WAIT"

var waited = false
var killedBefore = false
var warned = false
var interruption = false
var hitted = false

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
		
	current_state = "WAIT"
	waitTime.wait_time /= (1 + (SPEEDMOD - 1) / speedmodmod)
	warningTime.wait_time /= (1 + (SPEEDMOD - 1) / speedmodmod)
	laserTime.wait_time /= (1 + (SPEEDMOD - 1) / speedmodmod)
	waitTime.start()

func _physics_process(delta: float) -> void:
	
	var owner_is_dead := false
	if not is_instance_valid(wertue):
		owner_is_dead = true
	elif wertue.died == true:
		owner_is_dead = true

	# ЦЕНТРАЛИЗОВАННЫЙ КОНТРОЛЬ СМЕРТИ ВЛАДЕЛЬЦА
	if owner_is_dead:
		if current_state == "WAIT":
			_handle_death_during_wait()
		elif current_state == "WARNING":
			_handle_interruption_trigger()

	# Логика нанесения урона во время атаки
	if is_attacking:
		_handle_damage_logic()

	# Логика слежения за игроком (только в первой фазе)
	if not waited:
		_handle_player_tracking(delta)

# --- БЛОК ОБРАБОТКИ СМЕРТИ И ИНТЕРРАПШНА ---

func _handle_death_during_wait():
	current_state = "FINISHED"
	waitTime.stop()
	killedBefore = true
	var stoptween = create_tween()
	stoptween.tween_property(slabost, "modulate:a", 0.0, 1.0)
	stoptween.parallel().tween_property(aimer, "modulate:a", 0.0, 1.0)
	var looptween = create_tween()
	looptween.tween_property(beamLoop, "pitch_scale", 0.7, 1.0)
	await stoptween.finished
	beamLoop.stop()
	queue_free()

func _handle_interruption_trigger():
	current_state = "INTERRUPTION"
	warningTime.stop() # КРИТИЧЕСКИ ВАЖНО: сбрасываем старый таймер, предотвращая досрочную атаку!
	
	PtbonusesManager.ptbonus(wertue.givepts / 2, "INTERRUPTION", Color.WHITE)
	interruption = true
	warning.modulate.a = 1.0
	
	# Корректируем масштабы и время
	laserTime.wait_time *= 2
	var warntween = create_tween()
	warntween.tween_property(self, "scale:x", scale.x * 1.5, warningTime.wait_time)
	
	# Запускаем таймер предупреждения заново для фазы прерывания
	warningTime.start()
	_run_interruption_flashing()

# --- БЛОК МИГАНИЯ ПРЕДУПРЕЖДЕНИЙ ---

func _run_warning_flashing():
	aimer.visible = false
	while current_state == "WARNING":
		warning.visible = true
		if NEO == 0:
			Functions.sfx_play("res://sounds/wertueWarning.mp3")
		await get_tree().create_timer(warnTickTime, false).timeout
		if current_state != "WARNING": break
		
		warning.visible = false
		await get_tree().create_timer(warnTickTime, false).timeout
		if current_state != "WARNING": break
		warrned.emit()

func _run_interruption_flashing():
	while current_state == "INTERRUPTION":
		warning.visible = true
		if NEO == 0:
			Functions.sfx_play("res://sounds/wertueInterruption.mp3")
		await get_tree().create_timer(warnTickTime, false).timeout
		if current_state != "INTERRUPTION": break
		
		warning.visible = false
		await get_tree().create_timer(warnTickTime, false).timeout
		if current_state != "INTERRUPTION": break
		warrned.emit()

# --- БЛОК ТАЙМАУТОВ И АКТИВАЦИИ ЛАЗЕРА ---

func _on_wait_time_timeout() -> void:
	if current_state != "WAIT": return
	beamLoop.stop()
	waited = true
	slabost.visible = false
	
	current_state = "WARNING"
	warningTime.start()
	_run_warning_flashing()

func _on_warning_time_timeout() -> void:
	# Сюда код придет И после обычного предупреждения, И после интеррапшна
	if current_state == "WARNING" or current_state == "INTERRUPTION":
		current_state = "ATTACK"
		warned = true
		warning.visible = false
		laser.visible = true
		is_attacking = true
		laserTime.start()
		
		if NEO == 0:
			Functions.sfx_play("res://sounds/wertueAttack.mp3", -5.0)
		attackLoop.play()
		
		if interruption == true:
			set_collision_mask_value(3, true)
			Globals.shake_str += 3.0

func _on_laser_time_timeout() -> void:
	if current_state != "ATTACK": return
	current_state = "FINISHED"
	
	var looptween = create_tween()
	looptween.tween_property(attackLoop, "pitch_scale", 0.7, laserTime.wait_time/2 / (1 + ((SPEEDMOD - 1) / 3)))
	var lasertween = create_tween()
	lasertween.tween_property(self, "global_scale:x", 0.0, laserTime.wait_time/2 / (1 + ((SPEEDMOD - 1) / 3))).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await lasertween.finished
	attackLoop.stop()
	
	if wertue:
		if hitted == false:
			if NEO == 0:
				wertue.failedAttacks += 1
		else:
			if wertue.enraged == true:
				wertue.unenrage()
			wertue.failedAttacks = 0
		if NEO == 0:
			wertue.newShot()
	queue_free()

# --- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ---

func _handle_damage_logic():
	for body in get_overlapping_bodies():
		if is_attacking == false:
			break
		if body.has_method("takeDmg"):
			if body.is_invincible == false:
				body.takeDmg()
		if body.has_method("beam_dmg"):
			body.beam_dmg(5.0 * get_parent().SPEEDMOD)
		if body.has_method("explode"):
			body.get_hit()
	if get_overlapping_bodies().size() > 0 and is_attacking == true:
		hitted = true

func _handle_player_tracking(delta: float):
	var player = get_tree().get_first_node_in_group("player")
	if player:
		target_pos.x = player.global_position.x
		global_position.x = lerp(global_position.x, target_pos.x, tracking_speed * delta)
		target_pos.y = player.global_position.y
		global_position.y = lerp(global_position.y, target_pos.y, tracking_speed * delta)
		aimer.global_position = player.global_position

func turn90():
	rotation_degrees = 90.0
	NEO = true
	beamLoop.volume_db -= 80.0
	attackLoop.volume_db -= 80.0
