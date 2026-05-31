extends CharacterBody2D

var speed = 45.0

var SPEEDMOD := 1.0
var direction := Vector2.DOWN

@onready var sprite = $AnimatedSprite2D
@onready var hitbox := $CollisionShape2D

var gh = 0.15
func ghosts():
	while 1>0:
		Functions.add_ghost(self, 0.7, 0.5)
		await get_tree().create_timer(gh / SPEEDMOD).timeout

var defaultscale: Vector2

func _ready() -> void:
	
	ghosts()
	var defsize = sprite.scale
	sprite.scale *= 7
	var t = create_tween()
	t.tween_property(sprite, "scale", defsize, 0.5 / SPEEDMOD).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _physics_process(delta: float) -> void:
	
	var collision = move_and_collide(direction * speed * delta * (1 + (SPEEDMOD - 1) * 2))
	if collision:
		var collider = collision.get_collider()
		if collider.has_method("takeDmg"):
			collider.takeDmg()
		queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func set_direction(dir: Vector2):
	direction = dir.normalized()
	rotation = direction.angle()
	
func fade():
	var fadetw = create_tween()
	fadetw.tween_property(self, "scale", Vector2.ZERO, 2.0 / SPEEDMOD).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fadetw.tween_callback(queue_free)
	await get_tree().create_timer(1.5 / SPEEDMOD, false).timeout
	hitbox.disabled = true
	
