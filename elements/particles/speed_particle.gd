extends Sprite2D

@export var speed = 0.0
@export var lifetime = randf_range(0.75, 1.75)

func _ready() -> void:
	scale *= randf_range(3, 8)
	var s = create_tween()
	s.tween_property(self, "modulate:a", randf_range(0.5, 1.0), lifetime/4)
	s.parallel().tween_property(self, "scale:x", 0.0, lifetime)
	s.chain().tween_callback(queue_free)

func _process(delta: float) -> void:
	global_position.y += speed * delta
