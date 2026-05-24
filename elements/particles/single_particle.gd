extends CharacterBody2D

@onready var sprite := $Trail
@onready var hitbox := $CollisionShape2D
@export var bounciness := 0.7

var gravity := 10.0
var color := Color.WHITE
var lifetime := 0.5

func _ready() -> void:
	sprite.target = self
	var tween = create_tween()
	tween.tween_property(sprite, "width", 0.0, lifetime)
	tween.tween_callback(queue_free)

func _process(delta: float) -> void:
	velocity.y += gravity * delta
	var collision_info = move_and_collide(velocity * delta)
	
	if collision_info:
		var normal = collision_info.get_normal()
		velocity = velocity.bounce(normal) * bounciness
