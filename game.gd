extends Node2D


var fade_tween: Tween
var fade_tween1: Tween
var fade_tween2: Tween
var move_tween: Tween
var move_tween2: Tween

const lv_1_scene = preload ("res://lv_1.tscn")
const settings_scene = preload ("res://menu/settings.tscn")
const extra_scene = preload ("res://menu/extra.tscn")
const menu_scene = preload ("res://menu.tscn")
const pause = preload ("res://menu/pause/pause.tscn")

func _ready() -> void:
	Functions.removeBonuses()
	Globals.shake_str = 0.0
	if Globals.instart == true:
		instart()
	while Saves.is_loading == true:
		await get_tree().process_frame
	Globals.update_volume()

func staart():
	$Title.queue_free()
	var lv_1 = lv_1_scene.instantiate()
	lv_1.global_position = Vector2(0, 0)
	add_child(lv_1)
	move_tween = create_tween()
	move_tween.tween_property($lv1/spaceship, "position", Vector2(0.0, -35.0), 1.0).as_relative().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	move_tween2 = create_tween()
	move_tween2.tween_property($lv1/UI/MarginContainer, "position", Vector2(0, 35), 1.0).as_relative().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await move_tween.finished
	Globals.game_running = true
	Globals.instart = false

func instart():
	$menu.queue_free()
	staart()

func start():
	Functions.fade_music($Title, 1.0)
	fade_tween = create_tween()
	fade_tween1 = create_tween()
	fade_tween2 = create_tween()
	fade_tween.tween_property($menu/CanvasLayer/StrLogo, "modulate:a", 0.0, 1.0)
	fade_tween1.tween_property($menu/CanvasLayer/Logo, "modulate:a", 0.0, 1.0)
	fade_tween2.tween_property($menu/CanvasLayer/buttons, "modulate:a", 0.0, 1.0)
	$menu/CanvasLayer/buttons/play.disabled = true
	$menu/CanvasLayer/buttons/settings.disabled = true
	$menu/CanvasLayer/buttons/extra.disabled = true
	$menu/CanvasLayer/buttons/quit.disabled = true
	await fade_tween.finished
	$menu.queue_free()
	staart()


func extra():
	$menu.queue_free()
	var extra = extra_scene.instantiate()
	extra.global_position = Vector2(0, 0)
	add_child(extra)
	
func settings():
	$menu.queue_free()
	var settings = settings_scene.instantiate()
	settings.global_position = Vector2(0, 0)
	add_child(settings)


func back():
	var menu = menu_scene.instantiate()
	menu.global_position = Vector2(0, 0)
	add_child(menu)


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if Globals.game_running == true:
			$pauseC.add_child(pause.instantiate())
	#if event.is_action_pressed("ui_accept"):
	#	Functions.notify()
