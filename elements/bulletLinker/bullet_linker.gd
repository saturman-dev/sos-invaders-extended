extends Node2D

@onready var line: Line2D = $line
@onready var glow_line: Line2D = $glowline
@onready var area: Area2D = $area


@export var base_width: float = 1.0
@export var glow_multiplier: float = 4
@export var wave_speed: float = 20.0
@export var wave_frequency: float = 4.0


@export var core_color: Color = Color.WHITE

@export var glow_color: Color = Color("ff00b680")

var is_attacking: bool = true

var tracked_bullets: Array[Node2D] = []
var curve: Curve = Curve.new()
var time_passed: float = 0.0

func _ready() -> void:
	global_position = Vector2.ZERO
	
	# Настраиваем внутреннее ядро
	line.width = base_width
	line.width_curve = curve
	line.modulate = core_color
	
	# Настраиваем внешнее свечение
	glow_line.width = base_width * glow_multiplier
	glow_line.width_curve = curve # Они делят одну кривую, пульсация будет синхронной!
	glow_line.modulate = glow_color

func _physics_process(delta: float) -> void:
	tracked_bullets = tracked_bullets.filter(func(b): return is_instance_valid(b))
	if tracked_bullets.size() < 2:
		queue_free()
		return

	# Обновляем точки СРАЗУ для двух линий
	line.clear_points()
	glow_line.clear_points()
	for b in tracked_bullets:
		var pos = b.global_position
		line.add_point(pos)
		glow_line.add_point(pos)

	time_passed += delta
	_update_wave_curve()

	# Логика фаз (Атака / Предупреждение)
	if not is_attacking:
		_clear_collisions()
		line.modulate.a = 0.0 # Полностью прячем белое ядро во время телеграфа
		# Оставляем только тусклое, едва заметное внешнее свечение
		glow_line.modulate = Color(glow_color.r, glow_color.g, glow_color.b, 0.15)
	else:
		line.modulate = core_color
		glow_line.modulate = glow_color
		_update_sequential_collisions()

	# Нанесение урона
	for body in area.get_overlapping_bodies():
		if body.has_method("takeDmg"):
			body.takeDmg()

func activate_attack() -> void:
	is_attacking = true

func _update_wave_curve() -> void:
	curve.clear_points()
	var resolution := 5
	for i in range(resolution):
		var t = float(i) / float(resolution - 1)
		var wave = sin(t * wave_frequency * PI * 2.0 - time_passed * wave_speed)
		var amplitude = 0.2 if not is_attacking else 0.5
		var thickness_factor = 1.0 + (wave * amplitude)
		curve.add_point(Vector2(t, clamp(thickness_factor, 0.1, 2.0)))

func _update_sequential_collisions() -> void:
	_clear_collisions()
	for i in range(tracked_bullets.size() - 1):
		var collision_shape = CollisionShape2D.new()
		var segment = SegmentShape2D.new()

		segment.a = tracked_bullets[i].global_position
		segment.b = tracked_bullets[i + 1].global_position

		collision_shape.shape = segment
		area.add_child(collision_shape)

func _clear_collisions() -> void:
	for child in area.get_children():
		child.queue_free()
