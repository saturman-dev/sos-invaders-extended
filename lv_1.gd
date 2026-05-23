extends Node2D


var bossfighting = false
var flseye_diffi = diffi_range[0]
var shaurman_diffi = 9999

# ENEMIES COOLDOWN
var defCldown = 2
var newCldown = 4
var cooldown = defCldown
var maxDiffi = 360

@onready var diffLabel = $UI/MarginContainer/VBoxContainer2/HBoxContainer/diffLabel

const GAME_OVER_SCENE = preload("res://UI/gameover/game_over.tscn")
const WIN_SCENE = preload("res://UI/win/win.tscn")

#  ENEMIES
const darsin = preload("res://elements/vln_group.tscn")
const bigDar = preload("res://elements/BigDar/big_dar.tscn")
const a3 = preload("res://elements/a3/a_3.tscn")
const wertue = preload("res://elements/wertue/wertue.tscn")

#  BOSSES
const flseye = preload("res://elements/flseye/flseye.tscn")

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			get_node("/root/Globals").setDefHp()
			get_node("/root/Globals").points = 0
			Globals.instart = true
			get_tree().reload_current_scene()

func _ready() -> void:
	Globals.shake_str = 0.0
	print("Game started!")
	Events.lives_changed.connect(func(lives): check_game_over())
	Events.points_changed.connect(func(points): check_bossfighting())
	Events.bossfight_start.connect(func(type): spawn_boss_flseye())
	Events.bossfight_end.connect(func(): end_bossfight())
	Globals.newbest = false

func end_bossfight():
	bossfighting = false

func check_game_over():
	if Globals.lives <= 0:
		if Globals.nodeath == false:
			gameOver()

func check_bossfighting():
	await get_tree().process_frame
	if bossfighting == true and get_tree().get_nodes_in_group("enemies").size() == 0:
		if diffi < flseye_diffi + 50:
			Events.bossfight_start.emit("flseye")

func gameOver():
	if Globals.pts > Saves.data["score"]:
		Saves.data["score"] = Globals.pts
		Globals.newbest = true
	Functions.stop_all_sfx()
	get_tree().paused = true
	print("RIP Saraf")
	await get_tree().create_timer(1.0).timeout
	$spaceship/sprite.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(GAME_OVER_SCENE.instantiate())
	$spaceship.die()

var diffi = 0.0
var timer = 0.0
var time = 0.0
var sec = 1
var min = 60
var time1 = 0
var time2 = 0

var diffsec = 0.01

var already_bossfighted = false
var already_bossfighted_2 = false

func _process(delta: float) -> void:
	if diffi < maxDiffi and bossfighting == false:
		diffi += delta * 1.0
		Globals.diffi = diffi
		if diffi > flseye_diffi and diffi < flseye_diffi + 50 and already_bossfighted == false:
			bossfighting = true
			already_bossfighted = true
		if diffi > shaurman_diffi and diffi < shaurman_diffi + 50 and already_bossfighted_2 == false:
			bossfighting = true
			already_bossfighted_2 = true
	timer += delta
	time += delta
	if diffi > diffsec:
		diffLabel.text = str("Difficulty: ", str(round(diffsec * 100) / 100))
		diffsec += 0.01
	if time > sec:
		sec += 1
		Globals.secs += 1
		timech()
	if timer >= cooldown:
		defCldown = newCldown
		spawn_enemy()
		timer = 0.0
		cooldown = (defCldown - diffi/180) * float(randf_range(0.7, 1.3))

func timech():
	if time >= min:
		min += 60
		time1 += 1
		time2 = 0
	else:
		time2 += 1
	if time2 < 10:
		$UI/MarginContainer/VBoxContainer/HBoxContainer2/time.text = str(time1, ":0", time2)
		Globals.time = str(time1, ":0", time2)
	else:
		$UI/MarginContainer/VBoxContainer/HBoxContainer2/time.text = str(time1, ":", time2)
		Globals.time = str(time1, ":", time2)

func addBonus(bonus_type: String):
	$UI.addBonus(bonus_type)

const diffi_range = [4, 35, 55, 80, 105, 135, 175, 230]

func spawn_enemy():
	if bossfighting == true:
		return
	print("hi")
	if diffi < diffi_range[0]:
		spawn_darsinGroup()
	elif diffi < diffi_range[1]:
		if Saves.data["ever_met_bigdar"] == false:
			spawn_bigDar()
			print("NEW ENEMY BIGDAR")
			return
		var random = randf_range(0, 100)
		if random < 50:
			spawn_darsinGroup()
		else:
			spawn_bigDar()
	elif diffi < diffi_range[2]:
		if Saves.data["ever_met_a3"] == false:
			spawn_a3()
			print("NEW ENEMY A3")
			return
		var random = randf_range(0, 100)
		if random < 33:
			spawn_darsinGroup()
		elif random < 67:
			spawn_bigDar()
		else:
			spawn_a3()
	elif diffi < diffi_range[3]:
		var random = randf_range(0, 100)
		if random < 30:
			spawn_darsinGroup()
		elif random < 60:
			spawn_bigDar()
		else:
			spawn_a3()
	elif diffi < diffi_range[4]:
		if Saves.data["ever_met_wertue"] == false:
			spawn_wertue()
			print("NEW ENEMY WERTUE")
			return
		var random = randf_range(0, 100)
		if random < 20:
			spawn_darsinGroup()
		elif random < 55:
			spawn_bigDar()
		elif random < 85:
			spawn_a3()
		else:
			spawn_wertue()
	elif diffi < diffi_range[5]:
		var random = randf_range(0, 100)
		if random < 15.0:
			spawn_darsinGroup()
		elif random < 50.0:
			spawn_bigDar()
		elif random < 75.0:
			spawn_a3()
		else:
			spawn_wertue()
	elif diffi < diffi_range[6]:
		var random = randf_range(0, 100)
		if random < 10.0:
			spawn_darsinGroup()
		elif random < 30.0:
			spawn_bigDar()
		elif random < 60:
			spawn_a3()
		else:
			spawn_wertue()
	elif diffi < diffi_range[7]:
		var random = randf_range(0, 100)
		if random < 5.0:
			spawn_darsinGroup()
		elif random < 20.0:
			spawn_bigDar()
		elif random < 50:
			spawn_a3()
		else:
			spawn_wertue()
	else:
		var random = randf_range(0, 100)
		if random < 5.0:
			spawn_darsinGroup()
		elif random < 15.0:
			spawn_bigDar()
		elif random < 35:
			spawn_a3()
		else:
			spawn_wertue()




func spawn_darsinGroup():
	var Darsin = darsin.instantiate()
	Darsin.position = Vector2(randf_range(62, 328), -20)
	add_child(Darsin)

func spawn_bigDar():
	var BigDar = bigDar.instantiate()
	BigDar.position = Vector2(randf_range(20, 370), -20)
	add_child(BigDar)

func spawn_a3():
	var A3 = a3.instantiate()
	A3.position = Vector2(randf_range(60, 330), -20)
	add_child(A3)

func spawn_wertue():
	var Wertue = wertue.instantiate()
	Wertue.position = Vector2(randf_range(60, 330), -30)
	add_child(Wertue)

func spawn_boss_flseye():
	await get_tree().create_timer(3.0, false).timeout
	print("BOSSFIGHT FLSEYE")
	var Flseye = flseye.instantiate()
	Flseye.position = Vector2(390.0/2, 50.0)
	add_child(Flseye)
