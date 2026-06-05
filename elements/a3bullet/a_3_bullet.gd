extends CharacterBody2D

var speed = 125.0
var direction = 0
var SPEEDMOD = 1.0

@onready var sprite = $AnimatedSprite2D

var gh = 0.1
func ghosts():
	while 1>0:
		Functions.add_ghost(self, 0.7, 0.63)
		await get_tree().create_timer(gh / SPEEDMOD, false).timeout
		if not is_inside_tree(): return

func _ready() -> void:
	ghosts()
	var defsize = sprite.scale
	sprite.scale *= 4 * (1 + (SPEEDMOD - 1) / 2)
	var t = create_tween()
	t.tween_property(sprite, "scale", defsize * (1 + (SPEEDMOD - 1) / 2), 0.3 / SPEEDMOD).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_callback(func(): set_collision_layer_value(3, true))


func _physics_process(delta: float) -> void:
	global_position.x += speed * delta / 4 * direction * SPEEDMOD
	var collision = move_and_collide(Vector2.DOWN * delta * speed * SPEEDMOD / (1 + abs(direction)))
	if collision:
		var collider = collision.get_collider()
		if collider.has_method("takeDmg"):
			collider.takeDmg()
		queue_free()

func left():
	direction = -1

func lleft():
	direction = -2

func right():
	direction = 1

func rright():
	direction = 2

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	await get_tree().create_timer(5.0, false).timeout
	if not is_inside_tree(): return
	queue_free()

const breakParticleScene = preload("res://elements/particles/inter_particle.tscn")
func get_out():
	var p = breakParticleScene.instantiate()
	p.modulate = Color("ff00b6")
	p.global_position = global_position
	get_parent().add_child(p)
	queue_free()
