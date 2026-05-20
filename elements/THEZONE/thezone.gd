extends Area2D

@onready var circle2 = $Circle2
@onready var circle1 = $Circle1

var Atween: Tween

func _process(delta: float) -> void:
	circle1.global_rotation_degrees += 10 * delta

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("ZONE"):
		body.ZONE()
		Atween = create_tween().set_parallel(true)
		Atween.tween_property(circle2, "modulate:a", 0.3, 0.3)

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("unZONE"):
		body.unZONE()
		Atween = create_tween().set_parallel(true)
		Atween.tween_property(circle2, "modulate:a", 0.15, 0.3)
