extends CanvasLayer

const game = preload("res://game.tscn")

var pts = Globals.points
var newbest = Globals.newbest
var times = Globals.secs
var timee = Globals.time
var mod = 1.0
var modd = 1.0

var ATween: Tween
var BTween: Tween
var CTween: Tween

var between = 0.5 / mod
var timetime = 0
var minmin = 60
var time1 = 0
var time2 = 0

@onready var gameover = $VBOX/Gameo/Gameov/Gameover
@onready var a6 = $A6
@onready var ptst = $VBOX/Pt/Pts
@onready var nb = $VBOX/Pt/Pts/Pts2
@onready var time = $VBOX/Tim/Time

var counting = false
var skipping = false

func counterSfx():
	Functions.sfx_play("res://sounds/counter.mp3", -4.0)

func precounterSfx():
	Functions.sfx_play("res://sounds/preCounter.mp3")

var firstSound := 0
var firstSound2 := 0
func _ready():
	ATween = create_tween()
	ATween.tween_property(a6, "modulate:a", 0.85, 3.0)
	shimmer()
	await get_tree().create_timer(1.5).timeout
	$VBOX/Pt/PtsL.visible = true
	precounterSfx()
	counting = true
	await get_tree().create_timer(between).timeout
	if skipping == true:
		return
	# POINTS
	ptst.visible = true
	var LPts = 0
	var Ptime = float(0.1 / pts)
	if pts >= 1:
		ptst.text = "1"
		counterSfx()
	while not int(ptst.text) == pts:
		ptst.text = str(LPts)
		LPts += 1
		counterSfxCheck2()
		if not int(ptst.text) == pts:
			await get_tree().create_timer(Ptime / modd).timeout
	if newbest == true:
		await get_tree().create_timer(between).timeout
		nb.visible = true
		Functions.sfx_play("res://sounds/newBest.mp3")
		nb_flash()
	await get_tree().create_timer(between).timeout
	$VBOX/Tim/TimeL.visible = true
	precounterSfx()
	await get_tree().create_timer(between).timeout
	# TIME
	time.visible = true
	var Ttime = float(0.2 / times)
	time.text = "00:00"
	var time_elapsed = 0.0
	while not (time.text) == Globals.time:
		time_elapsed += 1
		var minutes := int(time_elapsed) / 60
		var seconds := int(time_elapsed) % 60
		time.text = "%02d:%02d" % [minutes, seconds]
		counterSfxCheck()
		if not time.text == Globals.time:
			await get_tree().create_timer(Ttime / modd).timeout
	await get_tree().create_timer(between).timeout
	# OTHER
	$VBOX/Text/Press.visible = true
	$"VBOX/Text/esc to exit".visible = true
	precounterSfx()

func counterSfxCheck():
	if firstSound == 2:
		counterSfx()
		firstSound = 0
	else:
		firstSound += 1

func counterSfxCheck2():
	if firstSound2 == 2:
		counterSfx()
		firstSound2 = 0
	else:
		firstSound2 += 1

func shimmer():
	while 1>0:
		BTween = create_tween()
		BTween.tween_property(gameover, "modulate:a", 0.7, 0.8)
		await BTween.finished
		BTween = create_tween()
		BTween.tween_property(gameover, "modulate:a", 1.0, 0.8)
		await BTween.finished

func Skip():
	between = 0.0
	skipping = true
	ptst.text = str(pts)
	time.text = Globals.time
	ptst.visible = true
	$VBOX/Tim/TimeL.visible = true
	$VBOX/Tim/Time.visible = true
	$VBOX/Text/Press.visible = true
	$"VBOX/Text/esc to exit".visible = true

func nb_flash():
	while 1>0:
		nb.modulate = Color.SPRING_GREEN
		await get_tree().create_timer(0.1).timeout
		nb.modulate = Color.SKY_BLUE
		await get_tree().create_timer(0.1).timeout

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
			if counting == true:
				Skip()
