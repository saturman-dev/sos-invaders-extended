extends Area2D

@onready var hitbox := $CollisionShape2D
@onready var sprite := $blink

func get_ready():
	interrupting = false
	hitbox.disabled = false
	sprite.speed_scale = get_parent().SPEEDMOD
	sprite.play("int")
	Functions.sfx_play("res://sounds/unterruptable.mp3", -5.0)

func get_unready():
	await get_tree().process_frame
	hitbox.disabled = true

var interrupting := false
func interrupt():
	if interrupting: return
	interrupting = true
	get_parent().interrupt()
