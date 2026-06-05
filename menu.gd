extends Node2D

var able = false

@onready var best := $CanvasLayer/buttons/playAnim/BEST
@onready var playAnim := $CanvasLayer/buttons/playAnim
@onready var quitAnim := $CanvasLayer/buttons/quitAnim
@onready var extraAnim := $CanvasLayer/buttons/extraAnim
@onready var settingsAnim := $CanvasLayer/buttons/settingsAnim
@onready var logo := $CanvasLayer/Logo
@onready var buttons := $CanvasLayer/buttons
@onready var canv := $CanvasLayer

const neo_sel := preload("res://menu/neo_selection.tscn")

func _ready() -> void:
	best.bbcode_enabled = true
	while Saves.is_loading == true:
		await get_tree().process_frame
		if not is_inside_tree(): return
	var score = Saves.data["score"]
	if score > 0:
		best.text = str("Highest score: [color=#ffffff]%s[/color]" % str(int(score)))
	else:
		best.queue_free()
	#Saves.data["greatest_neo_tier"] = 0
	if Saves.data["greatest_neo_tier"] > 0:
		playAnim.material.set_shader_parameter("blend_strength", 0.35)
		if Saves.data["greatest_neo_tier"] >= 5:
			playAnim.material.set_shader_parameter("blend_strength", 1)
			if Saves.data["greatest_neo_tier"] >= 10:
				playAnim.material.set_shader_parameter("gradient_color1", Color("ffe600").inverted())
				playAnim.material.set_shader_parameter("gradient_color2", Color("ff6600").inverted())
	

var loadedTime := 0.7
var betweenLoaded := 0.1
var lt: Tween
func loaded():
	logo.modulate.a = 0.0
	playAnim.modulate.a = 0.0
	settingsAnim.modulate.a = 0.0
	extraAnim.modulate.a = 0.0
	settingsAnim.modulate.a = 0.0
	quitAnim.modulate.a = 0.0
	await get_tree().create_timer(betweenLoaded*2, false).timeout
	if not is_inside_tree(): return
	lt = create_tween().set_parallel(true)
	lt.tween_property(logo, "modulate:a", 1.0, loadedTime)
	await get_tree().create_timer(betweenLoaded, false).timeout
	if not is_inside_tree(): return
	lt = create_tween().set_parallel(true)
	lt.parallel().tween_property(playAnim, "modulate:a", 1.0, loadedTime*0.7)
	await get_tree().create_timer(betweenLoaded, false).timeout
	if not is_inside_tree(): return
	lt = create_tween().set_parallel(true)
	lt.parallel().tween_property(extraAnim, "modulate:a", 1.0, loadedTime*0.85)
	await get_tree().create_timer(betweenLoaded, false).timeout
	if not is_inside_tree(): return
	lt = create_tween().set_parallel(true)
	lt.parallel().tween_property(settingsAnim, "modulate:a", 1.0, loadedTime)
	await get_tree().create_timer(betweenLoaded, false).timeout
	if not is_inside_tree(): return
	lt = create_tween().set_parallel(true)
	lt.parallel().tween_property(quitAnim, "modulate:a", 1.0, loadedTime*1.2)

func menuClick_play():
	Functions.sfx_play("res://sounds/menuClick.mp3")

var trans := Tween.TRANS_CUBIC
var s: Tween
var stspeed := 0.5
func _on_play_pressed() -> void:
	
	if Saves.data["greatest_neo_tier"] > 0:
		menuClick_play()
		var neo_select := neo_sel.instantiate()
		neo_select.global_position = get_viewport_rect().size / 2
		neo_select.global_position.y -= 10
		neo_select.scale *= 1.2
		canv.add_child(neo_select)
		return
	Functions.sfx_play("res://sounds/menuClick.mp3", 5.0, 1.0, false, 0.2)
	start()

func start():
	if able == false:
		return
	able = false
	get_parent().start()
	s = create_tween()
	s.tween_property(playAnim, "modulate:a", 0.0, stspeed)
	s.parallel().tween_property(playAnim, "scale", Vector2.ONE*2, stspeed * 1.5).set_trans(trans).set_ease(Tween.EASE_OUT)
	s.parallel().tween_property(logo, "global_position:y", -100, stspeed).as_relative().set_trans(trans).set_ease(Tween.EASE_OUT)
	s.parallel().tween_property(extraAnim, "global_position:y", 115, stspeed).as_relative().set_trans(trans).set_ease(Tween.EASE_OUT)
	s.parallel().tween_property(settingsAnim, "global_position:y", 115, stspeed).as_relative().set_trans(trans).set_ease(Tween.EASE_OUT)
	s.parallel().tween_property(quitAnim, "global_position:y", 115, stspeed).as_relative().set_trans(trans).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(stspeed/2, false).timeout
	if not is_inside_tree(): return
	get_parent().staart()
	await s.finished
	queue_free()


func _on_quit_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)


func _on_extra_pressed() -> void:
	if able == false:
		return
	menuClick_play()
	get_parent().extra()

func _on_settings_pressed() -> void:
	if able == false:
		return
	menuClick_play()
	get_parent().settings()

var pt: Tween
var hovspeed := 0.5
var unhovspeed := 0.8
func _on_play_mouse_entered() -> void:
	playAnim.play("hover")
	if able == false: return
	if pt and pt.is_running():
		pt.kill()
	pt = create_tween()
	pt.tween_property(playAnim, "scale", Vector2.ONE * 1.2, hovspeed).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	pt.parallel().tween_property(logo, "position", Vector2(197, 60), hovspeed).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	pt.parallel().tween_property(extraAnim, "position", Vector2(-26, 45), hovspeed).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	pt.parallel().tween_property(settingsAnim, "position", Vector2(26, 45), hovspeed).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	pt.parallel().tween_property(quitAnim, "position", Vector2(0, 67.5), hovspeed).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)


func _on_play_mouse_exited() -> void:
	if s and s.is_running():
		return
	playAnim.play("unhover")
	if able == false: return
	if pt and pt.is_running():
		pt.kill()
	pt = create_tween()
	pt.tween_property(playAnim, "scale", Vector2.ONE, hovspeed).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	pt.parallel().tween_property(logo, "position", Vector2(197, 70), hovspeed).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	pt.parallel().tween_property(extraAnim, "position", Vector2(-26, 35), hovspeed).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	pt.parallel().tween_property(settingsAnim, "position", Vector2(26, 35), hovspeed).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	pt.parallel().tween_property(quitAnim, "position", Vector2(0, 57.5), hovspeed).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)




func _on_quit_mouse_entered() -> void:
	quitAnim.play("hover")

func _on_quit_mouse_exited() -> void:
	quitAnim.play("unhover")



func _on_extra_mouse_entered() -> void:
	extraAnim.play("hover")

func _on_extra_mouse_exited() -> void:
	extraAnim.play("unhover")



func _on_settings_mouse_entered() -> void:
	settingsAnim.play("hover")

func _on_settings_mouse_exited() -> void:
	settingsAnim.play("unhover")
