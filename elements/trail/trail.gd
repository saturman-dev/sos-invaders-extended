extends Line2D

@export var lifetime: float = 0.05
@export var tick_rate: float = 0.01
var target: Object
@export var offset = Vector2.ZERO
var points_lifetime: Array = []
var time_since_last_tick: float = 0.0

func _ready() -> void:
	clear_points()
	top_level = true
	if is_instance_valid(target):
		add_point(target.global_position + offset)
		points_lifetime.append(0.0)


func _process(delta: float) -> void:
	if not is_instance_valid(target):
		queue_free()
		return

	var current_pos = target.global_position
	time_since_last_tick += delta
	if time_since_last_tick >= tick_rate:
		time_since_last_tick = 0.0
		add_point(current_pos + offset)
		points_lifetime.append(0.0)
	if get_point_count() > 0:
		set_point_position(get_point_count() - 1, current_pos + offset)
	var i = 0
	while i < points_lifetime.size() - 1:
		points_lifetime[i] += delta
		if points_lifetime[i] > lifetime:
			remove_point(i)
			points_lifetime.remove_at(i)
		else:
			i += 1


func fade_out_trail(delta):
	if get_point_count() > 0:
		var i = 0
		while i < points_lifetime.size():
			points_lifetime[i] += delta
			if points_lifetime[i] > lifetime:
				remove_point(i)
				points_lifetime.remove_at(i)
			else:
				i += 1
	else:
		queue_free()
