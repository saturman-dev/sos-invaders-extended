extends Area2D

var tracking_speed := 8.5

func _process(delta: float) -> void:
	var pos = get_parent().global_position
	for body in get_overlapping_bodies():
		if body.has_method("takeDmg"):
			if get_parent().anim: return
			get_parent().global_position.x = lerp(pos.x, body.global_position.x, tracking_speed * delta)
			get_parent().global_position.y = lerp(pos.y, body.global_position.y, tracking_speed * delta)
			scale = Vector2.ONE * 3
