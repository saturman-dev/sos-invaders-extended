extends Area2D

var okfade = 2.0
var oksize = 1.3
var znsize = 2.0
var znfadein = 0.3
var znfadeout = 2.2

var damage_tick := 0.5
var time_passed := 0.0

@onready var okrestnosti = $okrestnosti
@onready var znak = $znak
@onready var hitbox = $CollisionShape2D

var ATween: Tween
var BTween: Tween
var CTween: Tween
var DTween: Tween

var norilsk = false

func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.has_method("takeDmg"):
			body.takeDmg()
		if body.has_method("periodic_dmg"):
			body.periodic_dmg(5.0)
		if body.has_method("explode"):
			Globals.shake_str += 5.0
			body.explode()

func _ready() -> void:
	ATween = create_tween()
	ATween.tween_property(okrestnosti, "modulate:a", 0.0, okfade)
	BTween = create_tween()
	BTween.tween_property(okrestnosti, "scale", Vector2(oksize, oksize), okfade)
	CTween = create_tween()
	CTween.tween_property(znak, "modulate:a", 0.9, znfadein)
	DTween = create_tween()
	DTween.tween_property(znak, "scale", Vector2(znsize, znsize), znfadein + znfadeout)
	await CTween.finished
	CTween = create_tween()
	CTween.tween_property(znak, "modulate:a", 0.0, znfadeout)
	await get_tree().create_timer(okfade * 0.8 - znfadein, false).timeout
	hitbox.disabled = true
	await CTween.finished
	queue_free()
