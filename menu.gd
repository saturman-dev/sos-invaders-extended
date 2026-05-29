extends Node2D

var able = false

@onready var best := $CanvasLayer/buttons/playAnim/BEST
@onready var playAnim := $CanvasLayer/buttons/playAnim
@onready var quitAnim := $CanvasLayer/buttons/quitAnim
@onready var extraAnim := $CanvasLayer/buttons/extraAnim
@onready var settingsAnim := $CanvasLayer/buttons/settingsAnim
@onready var logo := $CanvasLayer/Logo
@onready var buttons := $CanvasLayer/buttons

@onready var scrollPoints := $CanvasLayer/scrollPoints
@onready var scrollKills := $CanvasLayer/scrollKills
@onready var scrollTime := $CanvasLayer/scrollTime
@onready var scrollBonus := $CanvasLayer/scrollBonus
@onready var scrollDamage := $CanvasLayer/scrollDamage
@onready var scrollSpeed := $CanvasLayer/scrollSpeed

func _ready() -> void:
	best.bbcode_enabled = true
	while Saves.is_loading == true:
		await get_tree().process_frame
	var score = Saves.data["score"]
	if score > 0:
		best.text = str("Highest score: [color=#ffffff]%s[/color]" % str(int(score)))
	else:
		best.queue_free()
	
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
	scrollTime.text = "[color=#181d7ab3]   MAX TIME: [/color][color=#00d2db]%s[/color]" % Functions.time_to(Saves.data["max_time"])
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
	lt = create_tween().set_parallel(true)
	lt.tween_property(logo, "modulate:a", 1.0, loadedTime)
	await get_tree().create_timer(betweenLoaded, false).timeout
	lt = create_tween().set_parallel(true)
	lt.parallel().tween_property(playAnim, "modulate:a", 1.0, loadedTime*0.7)
	await get_tree().create_timer(betweenLoaded, false).timeout
	lt = create_tween().set_parallel(true)
	lt.parallel().tween_property(extraAnim, "modulate:a", 1.0, loadedTime*0.85)
	await get_tree().create_timer(betweenLoaded, false).timeout
	lt = create_tween().set_parallel(true)
	lt.parallel().tween_property(settingsAnim, "modulate:a", 1.0, loadedTime)
	await get_tree().create_timer(betweenLoaded, false).timeout
	lt = create_tween().set_parallel(true)
	lt.parallel().tween_property(quitAnim, "modulate:a", 1.0, loadedTime*1.2)

func menuClick_play():
	Functions.sfx_play("res://sounds/menuClick.mp3")

var trans := Tween.TRANS_CUBIC
var s: Tween
var stspeed := 0.5
func _on_play_pressed() -> void:
	if able == false:
		return
	able = false
	menuClick_play()
	get_parent().start()
	unshimmer()
	s = create_tween()
	s.tween_property(playAnim, "modulate:a", 0.0, stspeed)
	s.parallel().tween_property(playAnim, "scale", Vector2.ONE*2, stspeed * 1.5).set_trans(trans).set_ease(Tween.EASE_OUT)
	s.parallel().tween_property(logo, "global_position:y", -100, stspeed).as_relative().set_trans(trans).set_ease(Tween.EASE_OUT)
	s.parallel().tween_property(extraAnim, "global_position:y", 115, stspeed).as_relative().set_trans(trans).set_ease(Tween.EASE_OUT)
	s.parallel().tween_property(settingsAnim, "global_position:y", 115, stspeed).as_relative().set_trans(trans).set_ease(Tween.EASE_OUT)
	s.parallel().tween_property(quitAnim, "global_position:y", 115, stspeed).as_relative().set_trans(trans).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(stspeed/2, false).timeout
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
