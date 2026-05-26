extends Node

var enemyTimer: Timer
var killStreak := 0
var targetEnemyTime = 1.0
var bonusQueueTime := 0.07

func _ready() -> void:
	enemyTimer = Timer.new()
	enemyTimer.timeout.connect(expired)
	Events.enemy_killed.connect(enemy_killed)
	enemyTimer.one_shot = true
	enemyTimer.wait_time = targetEnemyTime
	add_child(enemyTimer)
	
	spawn_timer = Timer.new()
	spawn_timer.one_shot = true
	add_child(spawn_timer)
	spawn_timer.timeout.connect(_process_queue)

func enemy_killed():
	killStreak += 1
	#ptbonus(3, "KILL", Color.WHITE)
	enemyTimer.start()
	var target_points = killStreak * 2 - 1
	if killStreak == 2:
		ptbonus(target_points, "DOUBLE KILL", Color.ORANGE)
	elif killStreak == 3:
		ptbonus(target_points, "TRIPLE KILL", Color.ORANGE)
	elif killStreak == 4:
		ptbonus(target_points, "QUADRIPLE KILL", Color.ORANGE)
	elif killStreak > 4:
		ptbonus(target_points, "MULTIKILL", Color.ORANGE, killStreak)

func expired():
	killStreak = 0

var ptbonus_queue: Array[Dictionary] = []
@onready var spawn_timer: Timer

func ptbonus(points: int, text: String, color: Color, streak: int = 0):
	
	var color_hex = color.to_html(false)
	
	ptbonus_queue.append({
		"text": text,
		"points": points,
		"color": color_hex,
		"streak": streak
	})
	
	if spawn_timer.is_stopped():
		_process_queue()

func _process_queue() -> void:
	if ptbonus_queue.is_empty():
		return
	
	var bonus = ptbonus_queue.pop_front()
	var container = get_tree().get_first_node_in_group("ptBonusesContainer")
	
	if container:
		var bbcode_text = "+ [color=#%s]%s[/color]" % [bonus.color, bonus.text]
		
		if bonus.streak > 0:
			bbcode_text += " x%d" % bonus.streak
		
		container.add(bbcode_text)
	
	Globals.change_points(bonus.points)
	spawn_timer.start(bonusQueueTime)
