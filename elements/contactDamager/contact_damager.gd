extends Area2D

@export var size_horizontal = 20.0
@onready var hitbox = $hitbox

var disabled = false

func _ready() -> void:
	hitbox.shape.height = clamp(size_horizontal, 20.0, 1024.0)

func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.has_method("takeDmg") and body.is_invincible == false and disabled == false:
			body.takeDmg()
	if "died" in get_parent():
		if get_parent().died == true:
			hitbox.disabled = true
