extends Node

var needForOverheal = 40
var nodeath: bool = false

var def_hp: int = 3
var staminas := 3.0
var currentStaminas := 0.0
var staminaTime := 2.0
var dashable := true
var game_running: bool = false
var instart: bool = false
var pts = 0
var newbest: bool = false
var time: String = " "
var secs: int = 0
var shake_str := 0.0
var shake_fad := 3.0
var diffi := 0.0

var notification_running := false

var bonusTrioActive := false
var bonusSpeedActive := false
var bonusSplashActive := false
var trioTimer := 11.0
var speedTimer := 15.0
var splashTimer := 9.0

var bgStay = false
var hp_animation = false


func _process(delta: float) -> void:
	
	# CAMERA SHAKE
	if shake_str > 0:
		shake_str = lerp(shake_str, 0.0, shake_fad * delta)
		var camera = get_viewport().get_camera_2d()
		if camera:
			camera.offset = Vector2(
				randf_range(-shake_str, shake_str),
				randf_range(-shake_str, shake_str)
			)
	
	# STAMINA
	if currentStaminas < staminas and game_running == true:
		currentStaminas += delta / staminaTime
		if currentStaminas >= 1:
			dashable = true
		else:
			dashable = false
		#print(currentStaminas)


func setDefHp():
	lives = def_hp
	deflives = def_hp
	overlives = 0

var points := 0
var lives := def_hp
var deflives := def_hp
var overlives := 0

func change_points(diff: int):
	points += diff
	pts += diff
	Events.points_added.emit(diff)
	Events.points_changed.emit(points)
	if Saves.data["ever_got_overheal_bonus"] == false and Saves.data["killed_enemies"] >= needForOverheal:
		Saves.data["ever_got_overheal_bonus"] = true
		Functions.notify("New \"Overheal\" bonus added!!", "Go catch it!")
		Functions.add_bonus("overheal", Vector2(195.0, 70.0))

func change_lives(diff: int):
	deflives += diff
	lives += diff
	Events.lives_changed.emit(lives)
	Events.deflives_changed.emit(deflives)

func change_overlives(diff: int):
	overlives += diff
	lives += diff
	Events.lives_changed.emit(lives)
	Events.overlives_changed.emit(overlives)

func apply_shake(strength: float):
	shake_str = strength

func update_volume():
	var master = AudioServer.get_bus_index("Master")
	var music = AudioServer.get_bus_index("Music")
	var sfx = AudioServer.get_bus_index("SFX")
	var v_all = Saves.data["v_all"] / 100
	var v_mus = Saves.data["v_mus"] / 100
	var v_sfx = Saves.data["v_sfx"] / 100
	AudioServer.set_bus_volume_db(master, linear_to_db(v_all))
	AudioServer.set_bus_volume_db(music, linear_to_db(v_mus))
	AudioServer.set_bus_volume_db(sfx, linear_to_db(v_sfx))
