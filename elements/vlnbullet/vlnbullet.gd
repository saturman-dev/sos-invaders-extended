extends CharacterBody2D

var speed = 45.0

var SPEEDMOD := 1.0

@onready var sprite = $AnimatedSprite2D

var gh = 0.15
func ghosts():
	while 1>0:
		Functions.add_ghost(self, 0.7, 0.5)
		await get_tree().create_timer(gh).timeout

var defaultscale: Vector2

func _ready() -> void:
	
	ghosts()
	var defsize = sprite.scale
	sprite.scale *= 7
	var t = create_tween()
	t.tween_property(sprite, "scale", defsize, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _physics_process(delta: float) -> void:
	
	var collision = move_and_collide(Vector2.DOWN * delta * speed * SPEEDMOD)
	if collision:
		var collider = collision.get_collider()
		if collider.has_method("takeDmg"):
			collider.takeDmg()
		queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
