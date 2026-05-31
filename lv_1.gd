extends Node2D

@onready var viewpos = get_viewport_rect().size
@onready var spaceship := $spaceship
@onready var ui := $UI

const GAME_OVER_SCENE = preload("res://UI/gameover/game_over.tscn")
const particle = preload("res://elements/particles/speed_particle.tscn")

const ENEMY_CATALOG = {
	"darsin": {"cost": 10, "min_diffi": 0, "scene": preload("res://elements/vln_group.tscn")},
	"bigdar": {"cost": 15, "min_diffi": 20, "scene": preload("res://elements/BigDar/big_dar.tscn")},
	"a3": {"cost": 20, "min_diffi": 55, "scene": preload("res://elements/a3/a_3.tscn")},
	"wertue": {"cost": 30, "min_diffi": 100, "scene": preload("res://elements/wertue/wertue.tscn")}
}

var is_boss_fight := false
var diffi := 0.0
var spawn_credits := 10.0
@onready var spawn_timer := $spawntimer

const NEO_GAP := 150.0
var introduced_variants = {}

var boss_timeline = [
	{"threshold": 149.99, "anim_func": "flseye", "done": false}
]

func _process(delta: float) -> void:
	
	if diffi > NEO_GAP: _spawn_particles(delta)
	
	if is_boss_fight: return
	
	var enemy_count = get_tree().get_nodes_in_group("enemies").size()
	var growth_modifier = 1.0
	
	if enemy_count == 0:
		growth_modifier = 5.0
	elif enemy_count <= 3:
		growth_modifier = 2.5
	elif enemy_count >= 10:
		growth_modifier = 0.2
	elif enemy_count >= 7:
		growth_modifier = 0.5
	
	diffi += 1.0 * growth_modifier * delta
	spawn_credits += diffi * 2 * delta
	
	_check_boss_timeline()
	_check_dynamic_intros()
	
	spawn_timer.wait_time = clamp((5.0 - diffi * 0.02) / growth_modifier, 4.0 / growth_modifier, 10.0 / growth_modifier)

func _execute_spawn(enemy_scene: PackedScene, neo_tier: int) -> void:
	if not enemy_scene: return
	
	var new_enemy = enemy_scene.instantiate()
	add_child(new_enemy)
	
	new_enemy.add_to_group("enemies")
	
	if neo_tier > 0 and is_instance_valid(new_enemy):
		Functions.set_neo(new_enemy, neo_tier)

func _check_dynamic_intros() -> void:
	for enemy_name in ENEMY_CATALOG:
		var data = ENEMY_CATALOG[enemy_name]
		
		for tier in range(11):
			var required_diffi = data.min_diffi + (NEO_GAP * tier)
			
			if diffi >= required_diffi:
				var key = enemy_name + "_tier_" + str(tier)
				if not introduced_variants.has(key):
					introduced_variants[key] = true
					_execute_spawn(data.scene, tier)
					spawn_credits -= data.cost * (tier + 1)
					print("NEW ENEMY. NEW introduced_variants:  ", introduced_variants)

func _on_spawntimer_timeout() -> void:
	
	if is_boss_fight: return
	
	var shopping_list = []
	for enemy_name in ENEMY_CATALOG:
		var data = ENEMY_CATALOG[enemy_name]
		for tier in range(11):
			var required_diffi = data.min_diffi + (NEO_GAP * tier)
			
			if diffi >= required_diffi:
				var current_cost = data.cost * (tier + 1)
				if spawn_credits >= current_cost:
					shopping_list.append({"scene": data.scene, "tier": tier, "cost": current_cost})
		
	if shopping_list.is_empty(): return
	
	var choice = shopping_list.pick_random()
	spawn_credits -= choice.cost
	_execute_spawn(choice.scene, choice.tier)

func _check_boss_timeline() -> void:
	for boss in boss_timeline:
		if not boss.done and diffi >= boss.threshold:
			boss.done = true
			_prepare_boss_fight(boss.anim_func)
			break

func _prepare_boss_fight(name: String) -> void:
	is_boss_fight = true
	
	while get_tree().get_nodes_in_group("enemies").size() > 0:
		await get_tree().process_frame
	
	Functions.spawn_boss(name)

func boss_defeated() -> void:
	is_boss_fight = false

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			Globals.setDefHp()
			Globals.points = 0
			Globals.instart = true
			get_tree().reload_current_scene()

func _ready() -> void:
	
	Globals.shake_str = 0.0
	
	Globals.kills = 0
	Globals.timeSeconds = 0
	Globals.points = 0
	Globals.oldMaxKills = Saves.data["max_kills"]
	Globals.oldMaxPoints = Saves.data["score"]
	Globals.oldMaxTime = Saves.data["max_time"]
	Globals.oldBonusMod = Saves.data["bonus_modifier"]
	Globals.oldDamageMod = Saves.data["damage_modifier"]
	Globals.oldSpeedMod = Saves.data["speed_modifier"]
	
	Globals.update_stats()
	
	print("Game started!")
	Events.lives_changed.connect(func(lives): check_game_over())
	Events.enemy_killed.connect(func(): Globals.kills += 1)
	ready_animation()

func ready_animation():
	Globals.hp_animation = true
	Globals.change_lives(-2)
	Functions.sfx_play("res://sounds/hpStart.mp3", 0.0)
	await get_tree().create_timer(0.2, false).timeout
	Globals.change_lives(1)
	Functions.sfx_play("res://sounds/hpStart.mp3", 0.0, 1.1)
	await get_tree().create_timer(0.2, false).timeout
	Globals.change_lives(1)
	Functions.sfx_play("res://sounds/hpStart.mp3", 0.0, 1.2)
	Globals.hp_animation = false
	spawn_timer.start()

func check_game_over():
	if Globals.lives <= 0:
		if Globals.nodeath == false:
			gameOver()

func gameOver():
	
	if Globals.points > Globals.oldMaxPoints:
		Saves.data["score"] = Globals.points
	if Globals.kills > Globals.oldMaxKills:
		Saves.data["max_kills"] = Globals.kills
	if Globals.timeSeconds > Globals.oldMaxTime:
		Saves.data["max_time"] = Globals.timeSeconds
	Globals.update_stats()
	
	Functions.stop_all_sfx()
	get_tree().paused = true
	print("RIP Saraf")
	await get_tree().create_timer(1.0).timeout
	spaceship.sprite.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(GAME_OVER_SCENE.instantiate())
	spaceship.die()

func addBonus(bonus_type: String):
	ui.addBonus(bonus_type)

var particleTimer = 0.0
var particleTime = defParticleTime
var defParticleTime = 20
var p_x_offset = 30.0
var p_y_offset = 170.0
func _spawn_particles(delta: float):
	particleTime = defParticleTime / diffi
	particleTimer += 1 * delta
	if particleTimer > particleTime:
		particleTimer = 0.0
		var p = particle.instantiate()
		p.speed = diffi*5
		p.global_position = Vector2(randf_range(p_x_offset, viewpos.x - p_x_offset), randf_range(-50.0, viewpos.y - p_y_offset))
		add_child(p)
