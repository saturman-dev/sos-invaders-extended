extends Node2D

@onready var label = $label
@onready var cont = $cont
@onready var sett = $sett
@onready var quit = $quit
@onready var black = $black
@onready var stb = $stb
@onready var cnt = $cnt
@onready var contAnim = $cont/contAnim
@onready var settAnim = $sett/settAnim
@onready var quitAnim = $quit/quitAnim
@onready var cntLine = $cnt/cntLine
@onready var cntLine2 = $cnt/cntLine2

var fade0: Tween
var move1: Tween
var move2: Tween
var move3: Tween
var move4: Tween
var moves: Tween
var cntl: Tween
var cntl2: Tween

var ly = 0.1
var tm = 0.25
var en = false
var ct = int(Saves.data["ct"])

const setts = preload("res://menu/settings.tscn")

func da():
	move1 = create_tween()
	move1.tween_property(label, "position", Vector2(140.0, 0.0), tm).as_relative().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(ly).timeout
	move2 = create_tween()
	move2.tween_property(cont, "position", Vector2(140.0, 0.0), tm).as_relative().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(ly/2).timeout
	move3 = create_tween()
	move3.tween_property(sett, "position", Vector2(140.0, 0.0), tm).as_relative().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(ly).timeout
	move4 = create_tween()
	move4.tween_property(quit, "position", Vector2(140.0, 0.0), tm).as_relative().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await move2.finished
	en = true

func net():
	cont.disabled = true
	sett.disabled = true
	quit.disabled = true
	move1 = create_tween()
	move1.tween_property(label, "position", Vector2(-140.0, 0.0), tm).as_relative().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(ly).timeout
	move2 = create_tween()
	move2.tween_property(cont, "position", Vector2(-140.0, 0.0), tm).as_relative().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(ly).timeout
	move3 = create_tween()
	move3.tween_property(sett, "position", Vector2(-140.0, 0.0), tm).as_relative().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(ly).timeout
	move4 = create_tween()
	move4.tween_property(quit, "position", Vector2(-140.0, 0.0), tm).as_relative().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func _ready() -> void:
	Globals.game_running = false
	get_tree().paused = true
	fade0 = create_tween()
	fade0.tween_property(black, "modulate:a", 1.0, 0.1)
	da()

func menuClick_play():
	Functions.sfx_play("res://sounds/menuClick.mp3")

func _on_cont_mouse_entered() -> void:
	contAnim.play("hover")

func _on_cont_mouse_exited() -> void:
	contAnim.play("unhover")

func _on_cont_pressed() -> void:
	if en == true:
		ct = int(Saves.data["ct"])
		fade0 = create_tween()
		fade0.tween_property(black, "modulate:a", 0.0, float(ct))
		net()
		cnt.visible = true
		cntl = create_tween()
		cntl.tween_property(cntLine, "size:x", 0.0, ct)
		cntl2 = create_tween()
		cntl2.tween_property(cntLine2, "size:x", 0.0, ct)
		while ct > 0:
			cnt.text = str(ct)
			await get_tree().create_timer(1.0).timeout
			ct -= 1
		cnt.visible = false
		Globals.game_running = true
		get_tree().paused = false
		Events.unpaused.emit()
		queue_free()



func _on_sett_mouse_entered() -> void:
	settAnim.play("hover")

func _on_sett_mouse_exited() -> void:
	settAnim.play("unhover")

func _on_sett_pressed() -> void:
	menuClick_play()
	add_child(setts.instantiate())
	stb.visible = true
	cont.disabled = true
	sett.disabled = true
	quit.disabled = true


func _on_quit_mouse_entered() -> void:
	quitAnim.play("hover")

func _on_quit_mouse_exited() -> void:
	quitAnim.play("unhover")

func _on_quit_pressed() -> void:
	Functions.stop_all_sfx()
	get_tree().paused = false
	get_tree().reload_current_scene()


func back():
	stb.visible = false
	cont.disabled = false
	sett.disabled = false
	quit.disabled = false
