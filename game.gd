extends Node2D

var speed = 1.0
var scrollStrength := 270.0

var fade_tween: Tween
var fade_tween1: Tween
var fade_tween2: Tween
var move_tween: Tween
var move_tween2: Tween

@onready var menuu := $menu
@onready var strlogo := $CanvasLayer/StrLogo
var setting: Object
var extr: Object

const lv_1_scene = preload ("res://lv_1.tscn")
const settings_scene = preload ("res://menu/settings.tscn")
const extra_scene = preload ("res://menu/extra.tscn")
const menu_scene = preload ("res://menu.tscn")
const pause = preload ("res://menu/pause/pause.tscn")

var strl: Tween
func _ready() -> void:
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

func staart():
	var lv_1 = lv_1_scene.instantiate()
	lv_1.global_position = Vector2(0, 0)
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
	$Title.queue_free()
	strlogo.queue_free()
	staart()

func start():
	Functions.fade_music($Title, 1.0)
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
		await get_tree().create_timer(speed / 2, false).timeout
		extr.queue_free()
		menuu.able = true

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if Globals.game_running == true:
			$pauseC.add_child(pause.instantiate())
	if event.is_action_pressed("fullscreen"):
		toggle_fullscreen()
	if event.is_action_pressed("ui_accept"):
		pass

func toggle_fullscreen():
	var current = DisplayServer.window_get_mode()
	if current == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		var base_size = get_viewport_rect().size
		DisplayServer.window_set_size(base_size * 3)
		
		var screen = DisplayServer.window_get_current_screen()
		var screen_size = DisplayServer.screen_get_size(screen)
		var window_size = DisplayServer.window_get_size()
		DisplayServer.window_set_position(screen_size / 2 - window_size / 2)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
