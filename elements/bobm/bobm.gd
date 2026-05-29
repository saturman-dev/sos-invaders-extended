extends CharacterBody2D

var SPEEDMOD := 1.0
var NEO := 0

var speed = 45.0
var zamedlenie = 25.0

const explosion = preload("res://elements/bobm/bobm_explosion.tscn")
@onready var sprite = $AnimatedSprite2D

var gh = 0.3
func ghosts():
	while 1>0:
		Functions.add_ghost(self, 0.5, 0.5)
		await get_tree().create_timer(gh / SPEEDMOD, false).timeout

func tick_sound(volume: float = 0.0, hitstop: bool = false):
	Functions.sfx_play("res://sounds/bobmTick.mp3", volume - 0.0, 1.0, hitstop)

func _ready() -> void:
	ghosts()
	var defsize = sprite.scale
	sprite.scale *= 4
	var t = create_tween()
	t.tween_property(sprite, "scale", defsize, 0.5 / (1 + (SPEEDMOD - 1) / 4)).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tick_sound()
	await get_tree().create_timer(1.0 / (1 + (SPEEDMOD - 1) / 4), false).timeout
	tick_sound(-5.0)
	await get_tree().create_timer(1.0 / (1 + (SPEEDMOD - 1) / 4), false).timeout
	tick_sound(-10.0)

var second = false
var third = false

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(Vector2.DOWN * delta * speed * SPEEDMOD)
	if collision:
		var collider = collision.get_collider()
		if collider.has_method("takeDmg"):
			explode()
	if global_position.y >= 100.0 and global_position.y < 137.5 and second == false:
		sprite.play("2")
		second = true
	if global_position.y >= 137.5 and global_position.y < 175.0 and third == false:
		sprite.play("3")
		third = true
	if global_position.y >= 175.0:
		speed -= zamedlenie * delta * SPEEDMOD
		warn()

var warned = false

func tick():
	while self:
		await get_tree().create_timer(0.1 / (1 + (SPEEDMOD - 1) / 4), false).timeout
		tick_sound()

func warn():
	if warned == false:
		warned = true
		sprite.play("warn")
		tick_sound(4.0, true)
		tick()
		await get_tree().create_timer(1.5 / (1 + (SPEEDMOD - 1) / 2), false).timeout
		explode()

func explode():
	Functions.sfx_play("res://sounds/bobmExplosion.mp3")
	var Expl = explosion.instantiate()
	Expl.global_position = global_position
	get_parent().add_child(Expl)
	Expl.SPEEDMOD = SPEEDMOD
	Globals.shake_str += 4
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

var getting_hit = false
func get_hit():
	if getting_hit: return
	getting_hit = true
	warn()
	Functions.hitstop(0.5)
	await Functions.unhitstopped
	Globals.shake_str += 2
	getting_hit = true
	explode()
