extends AnimatedSprite2D

var hue = 0.0

func _on_animation_finished() -> void:
	queue_free()

func _ready() -> void:
	material.set_shader_parameter("hue_offset", hue)
