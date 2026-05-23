extends Area2D

@onready var sprite := $TextureRect
@onready var hitbox := $CollisionShape2D
var t: Tween
func _ready() -> void:
	scaling()

func scaling():
	while sprite:
		t = create_tween()
		t.tween_property(sprite, "scale:x", 0.8, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		await t.finished
		t = create_tween()
		t.tween_property(sprite, "scale:x", 1.5, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		await t.finished

func _process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.has_method("takeDmg") and body.is_invincible == false:
			body.takeDmg()
