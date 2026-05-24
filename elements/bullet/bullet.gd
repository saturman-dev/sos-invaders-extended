extends Area2D

var hit_guys: Array = []

@onready var sprite := $Sprite2D
@onready var hitbox := $CollisionShape2D

var SPEED = 300.0
var rotdir = [1, -1].pick_random()
var rotspeed = randf_range(200.0, 400.0) * rotdir
var damage = 0.0
var trioMod = 0.75
var trioSize = 0.75
var direction = 0
var splashing = false

var gh = 0.035
func ghosts():
	while 1>0:
		Functions.add_ghost(self, 0.5, 0.3)
		await get_tree().create_timer(gh, false).timeout

func _ready() -> void:
	ghosts()

func left():
	global_scale.y *= trioSize
	global_scale.x *= trioSize
	damage *= trioMod
	direction = -1

func right():
	global_scale.y *= trioSize
	global_scale.x *= trioSize
	damage *= trioMod
	direction = 1

func _physics_process(delta: float) -> void:
	rotation_degrees += rotspeed * delta
	global_position.x += SPEED * delta / 5 * direction
	global_position.y -= SPEED * delta

func _on_body_entered(body: Node2D):
	if body in hit_guys:
		return
	if "hp" in body:
		Functions.dmg(body, damage)
		Functions.sfx_play("res://sounds/niceBullet.mp3", -15.0, randf_range(0.8, 1.2))
	if body.has_method("explode"):
		Functions.sfx_play("res://sounds/niceBullet.mp3", -15.0, 1.0, true)
		if body.has_method("warn"):
			body.warn()
		Functions.hitstop(0.5)
		await Functions.unhitstopped
		body.explode()
		Globals.apply_shake(7.5)
	hit_guys.append(body)
	if splashing == false:
		queue_free()

func speedup():
	SPEED *= 1.5
	gh /= 2

func splash():
	splashing = true
	sprite.modulate = Color.DEEP_SKY_BLUE
	global_scale *= 1.2

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
