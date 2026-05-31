extends Area2D

var okfade = 2.0
var oksize = 1.3
var znsize = 2.0
var znfadein = 0.3
var znfadeout = 2.2

var SPEEDMOD := 1.0
var bullet_count := 10

var damage_tick := 0.45
var time_passed := 0.0

@onready var okrestnosti = $okrestnosti
@onready var znak = $znak
@onready var hitbox = $CollisionShape2D

var darbulletscene = preload("res://elements/vlnbullet/vlnbullet.tscn")

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
			body.periodic_dmg(5.0 * SPEEDMOD)
		if body.has_method("explode"):
			body.get_hit(true)

func _ready() -> void:
	var defscale = global_scale
	global_scale *= 0.2
	Functions.particle_explosion(self, global_position, randi_range(20, 30), Color("8fd94e"), 500, 0.8, 100.0, 0.7, 1.5, true, 0.1)
	if SPEEDMOD > 1.0:
		#defscale *= 1.3
		var angle_step = TAU / bullet_count
		for i in range(bullet_count):
			var bullet = darbulletscene.instantiate()
			bullet.SPEEDMOD = SPEEDMOD * 1.25
			
			var current_angle = i * angle_step
			var shoot_dir = Vector2.from_angle(current_angle)
			
			bullet.global_position = global_position
			bullet.global_scale *= 1.5
			
			get_parent().add_child(bullet)
			bullet.set_direction(shoot_dir)
			bullet.fade()
			
	ATween = create_tween()
	ATween.tween_property(self, "global_scale", defscale, 0.7).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	ATween.parallel().tween_property(okrestnosti, "modulate:a", 0.0, okfade)
	ATween.parallel().tween_property(okrestnosti, "scale", Vector2(oksize, oksize), okfade)
	ATween.parallel().tween_property(znak, "scale", Vector2(znsize, znsize), znfadein + znfadeout)
	CTween = create_tween()
	CTween.tween_property(znak, "modulate:a", 0.9, znfadein)
	await CTween.finished
	CTween = create_tween()
	CTween.tween_property(znak, "modulate:a", 0.0, znfadeout)
	await get_tree().create_timer(okfade * 0.8 - znfadein, false).timeout
	hitbox.disabled = true
	await CTween.finished
	queue_free()
