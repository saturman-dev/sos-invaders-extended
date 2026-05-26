extends Node

var enemyTimer: Timer
var killSeries := 0
var targetEnemyTime = 1.0

func _ready() -> void:
	enemyTimer = Timer.new()
	enemyTimer.timeout.connect(expired)
	Events.enemy_killed.connect(enemy_killed)
	enemyTimer.one_shot = true
	enemyTimer.wait_time = targetEnemyTime
	add_child(enemyTimer)

func enemy_killed():
	killSeries += 1
	enemyTimer.start()
	if killSeries == 2:
		ptbonus(3, "DOUBLE KILL", Color.ORANGE)
	elif killSeries == 3:
		ptbonus(5, "TRIPLE KILL", Color.ORANGE)
	elif killSeries == 4:
		ptbonus(7, "QUADRIPLE KILL", Color.ORANGE)
	elif killSeries > 4:
		ptbonus(5 + killSeries * 2, "MULTIKILL", Color.ORANGE, killSeries)

func expired():
	killSeries = 0

func ptbonus(points: int, name: String, color: Color, series: int = 0):
	Globals.change_points(points)
	get_tree().get_first_node_in_group("ptBonusesContainer").add(name, color, series)
