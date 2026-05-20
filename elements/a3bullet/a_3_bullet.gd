extends CharacterBody2D

var speed = 70.0
var direction = 0

@onready var sprite = $AnimatedSprite2D

var gh = 0.1
func ghosts():
	while 1>0:
		Functions.add_ghost(self, 0.7, 0.63)
		await get_tree().create_timer(gh).timeout

func _ready() -> void:
	ghosts()

func _physics_process(delta: float) -> void:
	global_position.x += speed * delta / 4 * direction
	var collision = move_and_collide(Vector2.DOWN * delta * speed)
	if collision:
		var collider = collision.get_collider()
		if collider.has_method("takeDmg"):
			collider.takeDmg()
		queue_free()

func left():
	direction = -1

func right():
	direction = 1

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
