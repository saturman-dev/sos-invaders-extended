extends Area2D

@onready var circle := $circle
var Atween: Tween
var Btween: Tween
var circleTime := 0.75
var circleSizeUp := 1.5
var circleSizeDown := 0.75
var circleAlphaUp := 0.5
var circleAlphaDown := 0.1

var speed := 40.0

func _ready() -> void:
	circle.modulate.a = circleAlphaUp
	circling()

func _physics_process(delta: float) -> void:
	global_position.y += speed * delta
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.has_method("bonusHeal") and Globals.deflives < Globals.def_hp:
			body.bonusHeal()
			animate()

@onready var sprite := $sprite
@onready var outline := $outline
@onready var hitbox := $hitbox
@onready var effect := $bonusGained
var anim := false
func animate():
	if anim: return
	anim = true
	speed = 0
	hitbox.disabled = true
	circle.hide()
	sprite.hide()
	outline.hide()
	effect.play("new_animation")
	await effect.animation_finished
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func circling():
	while 1>0:
		Atween = create_tween()
		Atween.tween_property(circle, "scale", Vector2(circleSizeUp, circleSizeUp), circleTime).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		Btween = create_tween()
		Btween.tween_property(circle, "modulate:a", circleAlphaDown, circleTime)
		await Btween.finished
		Atween = create_tween()
		Atween.tween_property(circle, "scale", Vector2(circleSizeDown, circleSizeDown), circleTime).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		Btween = create_tween()
		Btween.tween_property(circle, "modulate:a", circleAlphaUp, circleTime)
		await Btween.finished
