extends Node

# BONUS CHANCES, %
var bonus_chances = {
	"heal": 5.0,
	"overheal": 4.0,
	"splash": 2.0,
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
const single_particle = preload("res://elements/particles/single_particle.tscn")

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
			if source.has_method("damageAnimation"):
				source.damageAnimation()
			source.die()
	else:
		if source.has_method("damageAnimation"):
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



func sfx_play(soundPath, volume: float = 0.0, pitch: float = 1.0, play_on_hitstop: bool = false, reverb_power: float = 0.0):
	var player = AudioStreamPlayer.new()
	if reverb_power == 0.0:
		player.bus = "SFX"
	else:
		player.bus = "REVERB"
		var bus_index = AudioServer.get_bus_index("REVERB")
		var effect_index = 0
		var reverb_effect = AudioServer.get_bus_effect(bus_index, effect_index) as AudioEffectReverb
		if reverb_effect:
			reverb_effect.wet = clamp(reverb_power, 0.0, 1.0)
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



func add_bonus(bonus_type: String, spawn_source: Variant):
	var spawn_pos: Vector2 = Vector2.ZERO
	if spawn_source is Vector2:
		spawn_pos = spawn_source
	elif spawn_source is Object:
		spawn_pos = spawn_source.global_position
	else:
		push_error("Неверный тип spawn_source в системе бонусов!")
		return
	
	var bonus_node: Node2D = null
	
	match bonus_type:
		"trio":
			bonus_node = trio.instantiate()
			Saves.data["gotten_trios"] += 1
		"speed":
			bonus_node = speed.instantiate()
			Saves.data["gotten_speeds"] += 1
		"heal":
			bonus_node = heal.instantiate()
			Saves.data["gotten_heals"] += 1
		"overheal":
			bonus_node = overheal.instantiate()
			Saves.data["gotten_overheals"] += 1
		"splash":
			bonus_node = splash.instantiate()
			Saves.data["gotten_splashes"] += 1
	
	if bonus_node:
		bonus_node.global_position = spawn_pos
		call_deferred("add_child", bonus_node)

func removeBonuses():
	for bonus in get_tree().get_nodes_in_group("bonuses"):
		bonus.queue_free()

func addRandomBonus(spawn_source: Variant, chance_modifier: float = 1.0):
	var valid_bonuses = []
	var total_weight = 0.0
	
	for bonus in bonus_chances.keys():
		if is_bonus_allowed(bonus):
			valid_bonuses.append(bonus)
			
			total_weight += bonus_chances[bonus]
	
	if valid_bonuses.is_empty():
		return
	
	var drop_roll = randf_range(0.0, 100.0)
	
	var final_drop_chance = clamp(total_weight * chance_modifier * Saves.data["bonus_modifier"], 0.0, 100.0)
	
	if drop_roll > final_drop_chance:
		return
	
	var bonus_roll = randf_range(0.0, total_weight)
	var current_sum = 0.0
	var selected_bonus = ""
	for bonus in valid_bonuses:
		current_sum += bonus_chances[bonus]
		if bonus_roll <= current_sum:
			selected_bonus = bonus
			break
	if selected_bonus != "":
		add_bonus(selected_bonus, spawn_source)

func is_bonus_allowed(bonus_type: String) -> bool:
	
	var save_key = "ever_got_" + bonus_type + "_bonus"
	if Saves.data.has(save_key) and Saves.data[save_key] == false:
		return false
	
	match bonus_type:
		"trio":     return not Globals.bonusTrioActive
		"speed":    return not Globals.bonusSpeedActive
		"splash":   return not Globals.bonusSplashActive
		"heal":     return Globals.lives < Globals.deflives
		"overheal": return Globals.overlives != Globals.deflives
	return true

func checkHeal():
	if Globals.deflives < Globals.def_hp and Saves.data["ever_got_heal_bonus"] == false:
		Saves.data["ever_got_heal_bonus"] = true
		Functions.add_bonus("heal", Vector2(195.0, 70.0))
		Functions.notify("New \"Heal\" bonus added!!", "Go catch it!")

func flash(fade_in: float, fade_out: float, hold: float = 0.0, visibility: float = 1.0, color: Color = Color.WHITE):
	var canv := CanvasLayer.new()
	canv.layer = 200
	canv.add_to_group("flash")
	var flasher := ColorRect.new()
	flasher.color = color
	flasher.global_position = Vector2(-100, -100)
	flasher.size = Vector2(590, 440)
	flasher.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flasher.modulate.a = 0.0
	add_child(canv)
	canv.add_child(flasher)
	var ftween: Tween
	ftween = create_tween()
	ftween.tween_property(flasher, "modulate:a", visibility, fade_in)
	await ftween.finished
	await get_tree().create_timer(hold, false).timeout
	if not canv:
		return
	ftween = create_tween()
	ftween.tween_property(flasher, "modulate:a", 0.0, fade_out)
	ftween.tween_callback(canv.queue_free)

func remove_flashes():
	for canv in get_tree().get_nodes_in_group("flash"):
		canv.queue_free()

func def_enemy_explosion(enter_self: Object):
	particle_explosion(enter_self, enter_self.global_position, randi_range(1, 3), enter_self.color, 300, 0.2, 100, 0.2, 1.25, false)

func dead_enemy_explosion(enter_self: Object):
	particle_explosion(enter_self, enter_self.global_position, randi_range(5, 10), enter_self.color, 500, 0.35, 100, 0.5, 1.5, true, 0.10)

func mid_enemy_explosion(enter_self: Object):
	particle_explosion(enter_self, enter_self.global_position, randi_range(8, 14), enter_self.color, 600, 0.5, 100, 0.75, 2.0, true, 0.20)

func big_enemy_explosion(enter_self: Object):
	particle_explosion(enter_self, enter_self.global_position, randi_range(12, 20), enter_self.color, 700, 0.7, 100, 0.75, 3.0, true, 0.30)

func particle_explosion(
	target: Object,
	position: Vector2,
	particle_amount: int = 10,
	particle_color: Color = Color.WHITE,
	explosion_speed: float = 300.0,
	lifetime: float = 0.3,
	gravity: float = 100.0,
	min_particle_size: float = 0.4,
	max_particle_size: float = 1.25,
	collide_with_walls: bool = true,
	trail_length: float = 0.05
):
	for i in range(particle_amount):
		var p = single_particle.instantiate()
		p.global_position = position
		
		var random_angle = randf_range(0, 2*PI)
		var direction = Vector2(cos(random_angle), sin(random_angle))
		var random_speed = randf_range(explosion_speed * 0.5, explosion_speed)
		
		p.velocity = direction * random_speed
		p.gravity = gravity
		p.lifetime = randf_range(lifetime * 0.5, lifetime * 1.5)
		
		var random_scale = randf_range(min_particle_size, max_particle_size)
		p.scale = Vector2(random_scale, random_scale)
		
		var final_color = particle_color
		var color_change = randf_range(0.0, 0.5)
		if randf() > 0.5:
			final_color = particle_color.lightened(color_change)
		else:
			final_color = particle_color.darkened(color_change)
		p.get_node("Trail").default_color = final_color
		
		p.get_node("Trail").lifetime = trail_length
		
		if not collide_with_walls:
			p.set_collision_mask_value(8, false)
		
		get_tree().current_scene.call_deferred("add_child", p)
		
		#await get_tree().process_frame
		#print(p.get_node("Trail").lifetime)
