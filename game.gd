extends Node2D

var speed = 1.0
var scrollStrength := 270.0

@onready var scrollPoints := $scrollsManager/scrollPoints
@onready var scrollKills := $scrollsManager/scrollKills
@onready var scrollTime := $scrollsManager/scrollTime
@onready var scrollBonus := $scrollsManager/scrollBonus
@onready var scrollDamage := $scrollsManager/scrollDamage
@onready var scrollSpeed := $scrollsManager/scrollSpeed
@onready var scrollMan := $scrollsManager

var fade_tween: Tween
var fade_tween1: Tween
var fade_tween2: Tween
var move_tween: Tween
var move_tween2: Tween

@onready var menuu := $menu
@onready var strlogo := $CanvasLayer/StrLogo
@onready var music := $Title
var setting: Object
var extr: Object

const lv_1_scene = preload ("res://lv_1.tscn")
const settings_scene = preload ("res://menu/settings.tscn")
const extra_scene = preload ("res://menu/extra.tscn")
const menu_scene = preload ("res://menu.tscn")
const pause = preload ("res://menu/pause/pause.tscn")

var strl: Tween
func _ready() -> void:
	Globals.diffi = 0
	Globals.update_stats()
	music_fade_in()
	menuu.able = true
	menuu.loaded()
	Functions.remove_flashes()
	Functions.removeBonuses()
	Globals.shake_str = 0.0
	Globals.currentStaminas = 0.0
	Globals.bgStay = false
	if Globals.instart == true:
		instart()
	while Saves.is_loading == true:
		await get_tree().process_frame
	Globals.update_volume()
	strlogo.global_position.y += 20
	strl = create_tween()
	strl.tween_property(strlogo, "global_position:y", -20.0, 2.0).as_relative().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

	scrollBonus.modulate.a = 0.0
	scrollDamage.modulate.a = 0.0
	scrollSpeed.modulate.a = 0.0
	scrollPoints.modulate.a = 0.0
	scrollKills.modulate.a = 0.0
	scrollTime.modulate.a = 0.0
	scrollDamage.text = "[color=#181d7ab3]   DAMAGE MOD: [/color][color=#f61900]%s[/color]" % (Functions.floor_to(Saves.data["damage_modifier"]) + "x")
	scrollBonus.text = "[color=#181d7ab3]   BONUS MOD: [/color][color=#f7f700]%s[/color]" % (Functions.floor_to(Saves.data["bonus_modifier"]) + "x")
	scrollSpeed.text = "[color=#181d7ab3]   SPEED MOD: [/color][color=#00d2db]%s[/color]" % (Functions.floor_to(Saves.data["speed_modifier"]) + "x")
	scrollPoints.text = "[color=#181d7ab3]   MAX POINTS: [/color][color=#f61900]%s[/color]" % str(int(Saves.data["score"]))
	scrollKills.text = "[color=#181d7ab3]   MAX KILLS: [/color][color=#f7f700]%s[/color]" % str(int(Saves.data["max_kills"]))
	scrollTime.text = "[color=#181d7ab3]   MAX DIFFICULTY: [/color][color=#00d2db]%s[/color]" % (Functions.floor_to(Saves.data["max_diffi"] / 150 * 100) + "%")
	shimmer()

var shimmer_time := 4.0
var shimmer_speed := 0.3
var shimmer_between := 0.01
var st: Tween
var stt: Tween
func shimmer():
	
	stt = create_tween()
	stt.tween_property(scrollPoints, "modulate:a", 1.0, shimmer_speed)
	stt.tween_interval(shimmer_between)
	stt.parallel().tween_property(scrollKills, "modulate:a", 1.0, shimmer_speed)
	stt.tween_interval(shimmer_between)
	stt.parallel().tween_property(scrollTime, "modulate:a", 1.0, shimmer_speed)
	
	while self:
		st = create_tween()
		st.tween_interval(shimmer_time)
		
		st.chain().tween_property(scrollDamage, "modulate:a", 1.0, shimmer_speed)
		st.parallel().tween_property(scrollPoints, "modulate:a", 0.0, shimmer_speed)
		st.tween_interval(shimmer_between)
		
		st.parallel().tween_property(scrollBonus, "modulate:a", 1.0, shimmer_speed)
		st.parallel().tween_property(scrollKills, "modulate:a", 0.0, shimmer_speed)
		st.tween_interval(shimmer_between)
		
		st.parallel().tween_property(scrollSpeed, "modulate:a", 1.0, shimmer_speed)
		st.parallel().tween_property(scrollTime, "modulate:a", 0.0, shimmer_speed)
		
		st.tween_interval(shimmer_time)
		
		st.chain().tween_property(scrollDamage, "modulate:a", 0.0, shimmer_speed)
		st.parallel().tween_property(scrollPoints, "modulate:a", 1.0, shimmer_speed)
		st.tween_interval(shimmer_between)
		
		st.parallel().tween_property(scrollBonus, "modulate:a", 0.0, shimmer_speed)
		st.parallel().tween_property(scrollKills, "modulate:a", 1.0, shimmer_speed)
		st.tween_interval(shimmer_between)
		
		st.parallel().tween_property(scrollSpeed, "modulate:a", 0.0, shimmer_speed)
		st.parallel().tween_property(scrollTime, "modulate:a", 1.0, shimmer_speed)
		
		await st.finished

func unshimmer():
	if st and st.is_running():
		st.kill()
	if stt and stt.is_running():
		stt.kill()
	st = create_tween()
	st.tween_property(scrollPoints, "modulate:a", 0.0, shimmer_speed / 2)
	st.parallel().tween_property(scrollDamage, "modulate:a", 0.0, shimmer_speed / 2)
	st.tween_interval(shimmer_between)
	st.tween_property(scrollKills, "modulate:a", 0.0, shimmer_speed / 2)
	st.parallel().tween_property(scrollBonus, "modulate:a", 0.0, shimmer_speed / 2)
	st.tween_interval(shimmer_between)
	st.tween_property(scrollTime, "modulate:a", 0.0, shimmer_speed / 2)
	st.parallel().tween_property(scrollSpeed, "modulate:a", 0.0, shimmer_speed / 2)


func music_fade_in():
	await get_tree().process_frame
	if not music: return
	music.play()
	var mt = create_tween()
	mt.tween_property(music, "volume_db", 0.0, 0.25)

func staart():
	Globals.paused = true
	var lv_1 = lv_1_scene.instantiate()
	lv_1.global_position = Vector2(0, 0)
	lv_1.skip(Saves.data["last_selected_neo"] * 150)
	#lv_1.skip()
	add_child(lv_1)
	Globals.game_running = true
	var staminaTween = create_tween()
	staminaTween.tween_property(Globals, "currentStaminas", Globals.staminas, 2.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	move_tween = create_tween()
	move_tween.tween_property($lv1/spaceship, "position", Vector2(0.0, -40.0), 1.0).as_relative().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	#move_tween2 = create_tween()
	#move_tween2.tween_property($lv1/UI/MarginContainer, "global_position", Vector2(0, 0), 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await move_tween.finished
	Globals.instart = false

func instart():
	menuu.queue_free()
	music.queue_free()
	strlogo.queue_free()
	scrollMan.modulate.a = 0.0
	staart()

func start():
	unshimmer()
	Functions.fade_music(music, 1.0)
	if strl and strl.is_running:
		strl.kill()
	var s = create_tween()
	s.tween_property(strlogo, "global_position:y", 20, 0.4).as_relative()


func extra():
	menuu.able = false
	var extra = extra_scene.instantiate()
	add_child(extra)
	extr = extra
	extr.get_node("CanvasLayer2/back").disabled = true
	var ecanv = extr.get_node("CanvasLayer2")
	var mcanv = menuu.get_node("CanvasLayer")
	ecanv.offset.x = -scrollStrength
	var t = create_tween()
	t.tween_property(ecanv, "offset:x", 0, speed).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(mcanv, "offset:x", scrollStrength, speed).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(scrollMan, "position:x", scrollStrength/2*0.9, speed).as_relative().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(scrollMan, "rotation_degrees", -45, speed).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(speed / 2, false).timeout
	menuu.queue_free()
	extr.able = true
	extr.get_node("CanvasLayer2/back").disabled = false
	
func settings():
	menuu.able = false
	var settingss = settings_scene.instantiate()
	add_child(settingss)
	setting = settingss
	settingss.get_node("CanvasLayer/back").disabled = true
	var scanv = settingss.get_node("CanvasLayer")
	var mcanv = menuu.get_node("CanvasLayer")
	scanv.offset.x = scrollStrength
	var t = create_tween()
	t.tween_property(scanv, "offset:x", 0, speed).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(mcanv, "offset:x", -scrollStrength, speed).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(scrollMan, "position:x", -scrollStrength/2*0.9, speed).as_relative().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(scrollMan, "rotation_degrees", -45, speed).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(speed / 2, false).timeout
	menuu.queue_free()
	settingss.able = true
	settingss.get_node("CanvasLayer/back").disabled = false


func back(direction: int):
	if direction == 1 and setting:
		setting.able = false
		var menu = menu_scene.instantiate()
		add_child(menu)
		menuu = menu
		var scanv = setting.get_node("CanvasLayer")
		var mcanv = menuu.get_node("CanvasLayer")
		mcanv.offset.x = -scrollStrength
		var t = create_tween()
		t.tween_property(mcanv, "offset:x", 0, speed).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		t.parallel().tween_property(scanv, "offset:x", scrollStrength*direction, speed).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		t.parallel().tween_property(scrollMan, "position:x", scrollStrength*direction/2*0.9, speed).as_relative().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		t.parallel().tween_property(scrollMan, "rotation_degrees", 0.0, speed).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		await get_tree().create_timer(speed / 2, false).timeout
		setting.queue_free()
		menuu.able = true
	elif direction == -1 and extr:
		extr.able = false
		var menu = menu_scene.instantiate()
		add_child(menu)
		menuu = menu
		var ecanv = extr.get_node("CanvasLayer2")
		var mcanv = menuu.get_node("CanvasLayer")
		mcanv.offset.x = scrollStrength
		var t = create_tween()
		t.tween_property(mcanv, "offset:x", 0, speed).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		t.parallel().tween_property(ecanv, "offset:x", scrollStrength*direction, speed).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		t.parallel().tween_property(scrollMan, "position:x", scrollStrength*direction/2*0.9, speed).as_relative().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		t.parallel().tween_property(scrollMan, "rotation_degrees", 0.0, speed).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		await get_tree().create_timer(speed / 2, false).timeout
		extr.queue_free()
		menuu.able = true

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if Globals.game_running == true:
			$pauseC.add_child(pause.instantiate())
	if event.is_action_pressed("ui_accept"):
		pass
