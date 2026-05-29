extends CanvasLayer

@onready var gameover = $MarginContainer/VBOX/Gameo/Gameov/Gameover
@onready var a6 = $A6

@onready var pointsText := $MarginContainer/VBOX/POINTS/Pt/PtsL
@onready var pointsCountText := $MarginContainer/VBOX/POINTS/Pt/Pts
@onready var pointsMax := $MarginContainer/VBOX/POINTS/maxPts
@onready var pointsNewBest := $MarginContainer/VBOX/POINTS/Pt/PtsL/Pts2
@onready var damage := $MarginContainer/VBOX/POINTS/bar
@onready var damageBar := $MarginContainer/VBOX/POINTS/bar/bar
@onready var damageText := $MarginContainer/VBOX/POINTS/bar/DAMAGE
@onready var damageMin := $MarginContainer/VBOX/POINTS/bar/min
@onready var damageMax := $MarginContainer/VBOX/POINTS/bar/max
@onready var damageCurrent := $MarginContainer/VBOX/POINTS/bar/current
@onready var unlimited := $MarginContainer/VBOX/POINTS/bar/unlimited

@onready var killsText := $MarginContainer/VBOX/KILLS/Kil/KilL
@onready var killsCountText := $MarginContainer/VBOX/KILLS/Kil/Kills
@onready var killsMax := $MarginContainer/VBOX/KILLS/maxKills
@onready var killsNewBest := $MarginContainer/VBOX/KILLS/Kil/KilL/Kil2
@onready var bonusChances := $MarginContainer/VBOX/KILLS/bar
@onready var bonusChancesBar := $MarginContainer/VBOX/KILLS/bar/bar
@onready var bonusChancesText := $"MarginContainer/VBOX/KILLS/bar/BONUS CHANCES"
@onready var bonusChancesMin := $MarginContainer/VBOX/KILLS/bar/min
@onready var bonusChancesMax := $MarginContainer/VBOX/KILLS/bar/max
@onready var bonusChancesCurrent := $MarginContainer/VBOX/KILLS/bar/current

@onready var timeText := $MarginContainer/VBOX/TIME/Tim/TimeL
@onready var timeCountText := $MarginContainer/VBOX/TIME/Tim/Time
@onready var timeMax := $MarginContainer/VBOX/TIME/maxTime
@onready var timeNewBest := $MarginContainer/VBOX/TIME/Tim/TimeL/Time2
@onready var cooldownsSpeed := $MarginContainer/VBOX/TIME/bar
@onready var cooldownsSpeedBar := $MarginContainer/VBOX/TIME/bar/bar
@onready var cooldownsSpeedText := $"MarginContainer/VBOX/TIME/bar/COOLDOWNS SPEED"
@onready var cooldownsSpeedMin := $MarginContainer/VBOX/TIME/bar/min
@onready var cooldownsSpeedMax := $MarginContainer/VBOX/TIME/bar/max
@onready var cooldownsSpeedCurrent := $MarginContainer/VBOX/TIME/bar/current

@onready var bottom := $MarginContainer/VBOX/BOTTOM

var a6tween: Tween
var between = 0.5
var is_skipped = false
var current_tween: Tween = null

func skip_sequence():
	is_skipped = true
	if current_tween and current_tween.is_valid():
		current_tween.set_speed_scale(100.0)



func precounterSfx():
	Functions.sfx_play("res://sounds/preCounter.mp3")

func newbestSfx():
	Functions.sfx_play("res://sounds/newBest.mp3")

var lastSoundTime := 0.0
var sound_interval := 0.02

func _play_buffered_tick() -> void:
	if is_skipped: return
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - lastSoundTime >= sound_interval:
		Functions.sfx_play("res://sounds/counter.mp3", -4.0)
		lastSoundTime = current_time

func _play_buffered_tick_bar(pitch: float) -> void:
	if is_skipped: return
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - lastSoundTime >= sound_interval:
		Functions.sfx_play("res://sounds/counter.mp3", -4.0, pitch)
		lastSoundTime = current_time



func animate_points():
	
	if Globals.points == 0:
		pointsCountText.text = "0"
		return
	
	var target_value = Globals.points
	var duration = 0.05 if is_skipped else clamp(float(target_value) / 100, 0.5, 3.5)
	var closure_state = {"last_int": -1}
	
	current_tween = create_tween()
	current_tween.tween_method(
		func(val: float):
			var current_int = int(val)
			pointsCountText.text = str(int(val))
			
			if current_int != closure_state["last_int"]:
				closure_state["last_int"] = current_int
				_play_buffered_tick()
			,
		0.0,
		float(target_value),
		duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	await current_tween.finished

func animate_kills():
	
	if Globals.kills == 0:
		killsCountText.text = "0"
		return
	
	var target_value = Globals.kills
	var duration = 0.05 if is_skipped else clamp(float(target_value) / 20, 0.5, 3.5)
	var closure_state = {"last_int": -1}
	
	current_tween = create_tween()
	current_tween.tween_method(
		func(val: float):
			var current_int = int(val)
			killsCountText.text = str(int(val))
			
			if current_int != closure_state["last_int"]:
				closure_state["last_int"] = current_int
				_play_buffered_tick()
			,
		0.0,
		float(target_value),
		duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	await current_tween.finished

func animate_time():
	
	var target_value = Globals.timeSeconds
	var duration = 0.05 if is_skipped else clamp((float(target_value) / 55) * 0.5, 0.5, 4.0)
	
	var closure_state = {"last_int": Functions.time_to(-1)}
	
	current_tween = create_tween()
	current_tween.tween_method(
		func(val: float):
			var current_int = Functions.time_to(val)
			var total_secs = int(val)
			timeCountText.text = Functions.time_to(total_secs)
			
			if current_int != closure_state["last_int"]:
				closure_state["last_int"] = current_int
				_play_buffered_tick()
			,
		0.0,
		float(target_value),
		duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	await current_tween.finished

func set_bar(bar: ProgressBar, label: Label, target_val: float, min_val: float, max_val: float):
	bar.min_value = min_val
	bar.max_value = max_val
	bar.value = target_val
	
	var displayed_val = Functions.floor_to(target_val)
	label.text = displayed_val + "x"
	
	var ratio = bar.get_as_ratio()
	var filled_width = bar.size.x * ratio
	label.position.x = filled_width + 2

func set_damage_bar():
	var min_val = 1.0
	var max_val = Globals.maxDamageModifier
	
	damageBar.min_value = min_val
	damageBar.max_value = min_val + (max_val - min_val) * 2.0
	damageBar.value = Globals.oldDamageMod
	
	var displayed_val = Functions.floor_to(damageBar.value)
	damageCurrent.text = displayed_val + "x"
	
	var ratio = damageBar.get_as_ratio()
	
	var target_x = (damageBar.size.x * ratio) + 2
	var max_width = (damageBar.size.x / 2) + 2
	
	if target_x > max_width:
		damageCurrent.force_update_transform()
		damageCurrent.position.x = 179 - damageCurrent.size.x
		damageCurrent.position.y = 2
		unlimited.modulate.a = 1.0
		already_unlimited = true
	else:
		damageCurrent.position.x = target_x

func animate_bar(bar: ProgressBar, label: Label, target_val: float, min_val: float, max_val: float):
	
	bar.min_value = min_val
	bar.max_value = max_val
	
	if abs(bar.value - target_val) < 0.01:
		return
	
	var val_range = max_val - min_val
	
	
	var progress_needed = target_val - bar.value
	var duration = 0.05 if is_skipped else clampf((progress_needed / val_range) * 7.0, 0.5, 2.5)
	
	
	var closure_state = {"last_text": ""}
	
	current_tween = create_tween()
	current_tween.tween_method(
		func(val: float):
			bar.value = val
			var ratio = bar.get_as_ratio()
			
			
			var current_text = Functions.floor_to(val) + "x"
			label.text = current_text
			
			
			var filled_width = bar.size.x * ratio
			label.position.x = filled_width + 2
			
			var dynamic_pitch = remap(ratio, 0.0, 1.0, 0.7, 1.6)
			
			
			if current_text != closure_state["last_text"]:
				closure_state["last_text"] = current_text
				_play_buffered_tick_bar(dynamic_pitch)
			,
		bar.value,
		target_val,
		duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	await current_tween.finished
	
	if bar.value >= max_val:
		show_and_flash(bar)
		show_and_flash(label)
		Functions.sfx_play("res://sounds/newBest.mp3", 5.0, 0.7)
		await flashTween.finished


var already_unlimited = false

func unlimit():
	if already_unlimited: return
	
	already_unlimited = true
	show_and_flash(unlimited)
	show_and_flash(damageCurrent)

func animate_damage_bar():
	var target_val = Saves.data["damage_modifier"]
	var min_val = 1.0
	var max_val = Globals.maxDamageModifier
	var bar = damageBar
	var label = damageCurrent
	
	bar.min_value = min_val
	bar.max_value = min_val + (max_val - min_val) * 2.0
	
	if abs(bar.value - target_val) < 0.01:
		return
		
	var val_range = max_val - min_val
	var progress_needed = target_val - bar.value
	var duration = 0.05 if is_skipped else clampf((progress_needed / val_range) * 7.0, 0.5, 2.5)
	
	var closure_state = {"last_text": ""}
	
	current_tween = create_tween()
	current_tween.tween_method(
		func(val: float):
			bar.value = val
			var ratio = bar.get_as_ratio()
			
			var current_text = Functions.floor_to(val) + "x"
			label.text = current_text
			
			var filled_width = bar.size.x * ratio
			var target_x = filled_width + 2
			
			var max_width = bar.size.x / 2 + 2
			
			if target_x > max_width:
				label.position.x = 179 - label.size.x
				label.position.y = 2
				unlimit()
			else:
				label.position.x = target_x
				label.position.y = 10
			
			var pitch_ratio = clampf(ratio, 0.0, 0.5)
			var dynamic_pitch = remap(pitch_ratio, 0.0, 0.5, 0.7, 1.6)
			
			if current_text != closure_state["last_text"]:
				closure_state["last_text"] = current_text
				_play_buffered_tick_bar(dynamic_pitch)
			,
		bar.value,
		target_val,
		duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	await current_tween.finished

func animate_delay(duration: float = between):
	
	if is_skipped:
		return
	
	current_tween = create_tween()
	current_tween.tween_interval(duration)
	
	await current_tween.finished

var flashTween: Tween
func show_and_flash(node: Object, duration: float = 0.5, brightness: float = 5):
	node.modulate.a = 1.0
	flashTween = create_tween()
	flashTween.tween_property(node, "modulate", node.modulate, duration).from(Color(brightness, brightness, brightness))



func _ready() -> void:
	
	# HIDING EVERYTHING
	pointsText.modulate.a = 0.0
	pointsCountText.modulate.a = 0.0
	pointsMax.modulate.a = 0.0
	pointsNewBest.modulate.a = 0.0
	bonusChances.modulate.a = 0.0
	killsText.modulate.a = 0.0
	killsCountText.modulate.a = 0.0
	killsMax.modulate.a = 0.0
	killsNewBest.modulate.a = 0.0
	damage.modulate.a = 0.0
	timeText.modulate.a = 0.0
	timeCountText.modulate.a = 0.0
	timeMax.modulate.a = 0.0
	timeNewBest.modulate.a = 0.0
	cooldownsSpeed.modulate.a = 0.0
	bottom.modulate.a = 0.0
	unlimited.modulate.a = 0.0
	
	# TEXT SETUP
	bonusChancesMax.text = Functions.floor_to(Globals.maxBonusModifier) + "x"
	damageMax.text = Functions.floor_to(Globals.maxDamageModifier) + "x"
	cooldownsSpeedMax.text = Functions.floor_to(Globals.maxSpeedModifier) + "x"
	bonusChancesBar.max_value = Globals.maxBonusModifier
	damageBar.max_value = Globals.maxDamageModifier
	cooldownsSpeedBar.max_value = Globals.maxSpeedModifier
	pointsMax.text = "/ " + str(Globals.oldMaxPoints)
	killsMax.text = "/ " + str(Globals.oldMaxKills)
	timeMax.text = "/ " + "%02d:%02d" % [int(Globals.oldMaxTime) / 60, int(Globals.oldMaxTime) % 60]
	
	# BAR SETUP
	set_bar(bonusChancesBar, bonusChancesCurrent, Globals.oldBonusMod, 1.0, Globals.maxBonusModifier)
	set_damage_bar()
	set_bar(cooldownsSpeedBar, cooldownsSpeedCurrent, Globals.oldSpeedMod, 1.0, Globals.maxSpeedModifier)
	
	start_animation()



func start_animation():
	
	a6tween = create_tween()
	a6tween.tween_property(a6, "modulate:a", 0.7, 3.0)
	
	shimmer()
	await animate_delay(between * 1.5)
	
	show_and_flash(pointsText)
	precounterSfx()
	await animate_delay()
	
	pointsCountText.modulate.a = 1.0
	pointsMax.modulate.a = 1.0
	await animate_points()
	await animate_delay()
	
	damage.modulate.a = 1.0
	unlimited.show()
	precounterSfx()
	if Globals.points > Globals.oldMaxPoints:
		show_and_flash(damage)
		show_and_flash(pointsNewBest)
		newbestSfx()
		if Globals.oldDamageMod != Globals.maxDamageModifier: 
			await animate_delay()
			await animate_damage_bar()
	await animate_delay()
	
	show_and_flash(killsText)
	precounterSfx()
	await animate_delay()
	
	killsCountText.modulate.a = 1.0
	killsMax.modulate.a = 1.0
	await animate_kills()
	await animate_delay()
	
	bonusChances.modulate.a = 1.0
	precounterSfx()
	if Globals.kills > Globals.oldMaxKills:
		show_and_flash(bonusChances)
		show_and_flash(killsNewBest)
		newbestSfx()
		if Globals.oldBonusMod != Globals.maxBonusModifier: 
			await animate_delay()
			await animate_bar(bonusChancesBar, bonusChancesCurrent, Saves.data["bonus_modifier"], 1.0, Globals.maxBonusModifier)
	await animate_delay()
	
	show_and_flash(timeText)
	precounterSfx()
	await animate_delay()
	
	timeCountText.modulate.a = 1.0
	timeMax.modulate.a = 1.0
	await animate_time()
	await animate_delay()
	
	cooldownsSpeed.modulate.a = 1.0
	precounterSfx()
	if Globals.timeSeconds > Globals.oldMaxTime:
		show_and_flash(cooldownsSpeed)
		show_and_flash(timeNewBest)
		newbestSfx()
		if Globals.oldSpeedMod != Globals.maxSpeedModifier: 
			await animate_delay()
			await animate_bar(cooldownsSpeedBar, cooldownsSpeedCurrent, Saves.data["speed_modifier"], 1.0, Globals.maxSpeedModifier)
	await animate_delay()
	
	show_and_flash(bottom)
	precounterSfx()
	
	current_tween = null


var GOt: Tween
func shimmer():
	while 1>0:
		GOt = create_tween()
		GOt.tween_property(gameover, "modulate:a", 0.7, 0.8)
		GOt.chain().tween_property(gameover, "modulate:a", 1.0, 0.8)
		await GOt.finished

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			Functions.stop_all_sfx()
			get_tree().paused = false
			get_node("/root/Globals").setDefHp()
			get_node("/root/Globals").points = 0
			Globals.game_running = false
			get_tree().reload_current_scene()
		if event.keycode == KEY_R:
			Functions.stop_all_sfx()
			get_tree().paused = false
			get_node("/root/Globals").setDefHp()
			get_node("/root/Globals").points = 0
			Globals.instart = true
			get_tree().reload_current_scene()
		if event.keycode == KEY_SPACE:
			if not is_skipped:
				skip_sequence()
