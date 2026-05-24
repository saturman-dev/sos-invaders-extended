extends CharacterBody2D

@export var speed = 45.0
var direction := Vector2.RIGHT
var sizeout := 2.0

@onready var sprite = $AnimatedSprite2D

var gh = 0.1
func ghosts():
	while 1>0:
		Functions.add_ghost(self, 0.7, 0.5)
		await get_tree().create_timer(gh).timeout

var t: Tween
func _ready() -> void:
	ghosts()
	var defsize = sprite.scale
	sprite.scale *= 4
	t = create_tween()
	t.tween_property(sprite, "scale", defsize, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.chain().tween_property(self, "scale", Vector2(0, 0), sizeout).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(self, "speed", 0.0, sizeout).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	t.chain().tween_callback(queue_free)

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(direction * delta * speed)
	if collision:
		var collider = collision.get_collider()
		if collider.has_method("takeDmg"):
			collider.takeDmg()
		queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
