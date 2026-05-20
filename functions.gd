extends Node

# BONUS CHANCES, %
var bonus_chances = {
	"heal": 5.0,
	"overheal": 4.0,
	"splash": 1.5,
	"trio": 1.5,
	"speed": 1.5
}

var hitstopping = false
signal unhitstopped

const notifier = preload("res://UI/notification.tscn")
const trio = preload("res://elements/bonuses/trio/trio.tscn")
const speed = preload("res://elements/bonuses/speed/speed.tscn")
const heal = preload("res://elements/bonuses/heal/heal.tscn")
const overheal = preload("res://elements/bonuses/overheal/overheal.tscn")
const splash = preload("res://elements/bonuses/splash/splash.tscn")

func hitstop(seconds: float):
	hitstopping = true
	get_tree().paused = true
	await get_tree().create_timer(seconds, true).timeout
	get_tree().paused = false
	hitstopping = false
	unhitstopped.emit()

func add_ghost(source: Object, visibility: float, duration: float):
	var sprite = source.get("sprite")
	var ghost := Sprite2D.new()
	if sprite is Sprite2D:
		ghost.texture = sprite.texture
		ghost.flip_h = sprite.flip_h
		ghost.vframes = sprite.vframes
		ghost.hframes = sprite.hframes
		ghost.frame = sprite.frame
	elif sprite is AnimatedSprite2D:
		var frames = sprite.sprite_frames
		var animation = sprite.animation
		var frame_index = sprite.frame
		ghost.texture = frames.get_frame_texture(animation, frame_index)
		ghost.hframes = 1
		ghost.vframes = 1
	elif sprite is Object:
		print("ghost error: wat is that sprite bradar")
		return
	ghost.flip_h = sprite.flip_h
	ghost.flip_v = sprite.flip_v
	ghost.global_position = sprite.global_position
	ghost.global_rotation = sprite.global_rotation
	ghost.global_scale = sprite.global_scale
	ghost.modulate = sprite.modulate
	ghost.z_index = sprite.z_index - 1
	get_tree().current_scene.add_child(ghost)
	var ATween = ghost.create_tween()
	ghost.modulate.a = visibility
	ATween.tween_property(ghost, "modulate:a", 0.0, duration)
	ATween.finished.connect(ghost.queue_free)



func dmg(source: Object, dam: float):
	var ATween: Tween
	var BTween: Tween
	source.timer.start(source.yellwait)
	source.hp -= dam
	if source.hp <= 0:
		source.hp = 0
		if source.has_method("die"):
			source.die()
	else:
		if source.sprite is Sprite2D:
			source.damageAnimation()
		else:
			source.sprite.modulate = source.dmgColor
			ATween = create_tween().set_parallel(true)
			ATween.tween_property(source.sprite, "modulate", Color.WHITE, source.undam)
		BTween = create_tween().set_parallel(true)
		BTween.tween_property(source.hpbar, "size:x", (source.fullsize / source.fullhp) * source.hp, source.bar1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		Functions.sfx_play("res://sounds/enemyDamage.mp3", -5.0)



func fade_music(player: AudioStreamPlayer, duration: float):
	var tween = create_tween()
	tween.tween_property(player, "volume_db", -80.0, duration).set_trans(Tween.TRANS_SINE)
	tween.finished.connect(player.stop)



func sfx_play(soundPath, volume: float = 0.0, pitch: float = 1.0, play_on_hitstop: bool = false):
	var player = AudioStreamPlayer.new()
	player.bus = "SFX"
	player.stream = load(soundPath)
	player.volume_db = volume
	player.pitch_scale = pitch
	if play_on_hitstop == true:
		player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

func stop_all_sfx():
	for child in get_children():
		if child is AudioStreamPlayer:
			child.stop()



func notify(notification_text: String = "Some notification", notification_info: String = "More info ahh"):
	var Notifier = notifier.instantiate()
	add_child(Notifier)
	Notifier.notify(notification_text, notification_info)



func add_bonus(bonus_type: String, bonus_position, ignore_locked: bool = true):
	if bonus_type == "trio":
		if Saves.data["ever_got_trio_bonus"] == false and ignore_locked == false:
			return
		var Trio = trio.instantiate()
		Trio.global_position = bonus_position
		add_child(Trio)
		Saves.data["gotten_trios"] += 1
	if bonus_type == "speed":
		if Saves.data["ever_got_speed_bonus"] == false and ignore_locked == false:
			return
		var Speed = speed.instantiate()
		Speed.global_position = bonus_position
		add_child(Speed)
		Saves.data["gotten_speeds"] += 1
	if bonus_type == "heal":
		if Saves.data["ever_got_heal_bonus"] == false and ignore_locked == false:
			return
		var Heal = heal.instantiate()
		Heal.global_position = bonus_position
		add_child(Heal)
		Saves.data["gotten_heals"] += 1
	if bonus_type == "overheal":
		if Saves.data["ever_got_overheal_bonus"] == false and ignore_locked == false:
			return
		var Overheal = overheal.instantiate()
		Overheal.global_position = bonus_position
		add_child(Overheal)
		Saves.data["gotten_overheals"] += 1
	if bonus_type == "splash":
		if Saves.data["ever_got_splash_bonus"] == false and ignore_locked == false:
			return
		var Splash = splash.instantiate()
		Splash.global_position = bonus_position
		add_child(Splash)
		Saves.data["gotten_splashes"] += 1

func removeBonuses():
	for bonus in get_tree().get_nodes_in_group("bonuses"):
		bonus.queue_free()

func addRandomBonus(just_enter_self: Object, chance_modifier: float = 1.0):
	var random = randf_range(0.0, 100.0)
	var current_sum = 0.0
	var selected_bonus = ""
	for bonus in bonus_chances.keys():
		current_sum += bonus_chances[bonus] * chance_modifier
		if random <= current_sum:
			selected_bonus = bonus
			break
	if selected_bonus != "":
		add_bonus(selected_bonus, just_enter_self.global_position, false)

func checkHeal():
	if Globals.deflives < Globals.def_hp and Saves.data["ever_got_heal_bonus"] == false:
		Saves.data["ever_got_heal_bonus"] = true
		Functions.add_bonus("heal", Vector2(195.0, 70.0))
		Functions.notify("New \"Heal\" bonus added!!", "Go catch it!")
