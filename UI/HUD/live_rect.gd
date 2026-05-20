extends Control

@onready var defsprite = $AnimatedSprite2D
@onready var oversprite = $over

func over():
	oversprite.visible = true
	defsprite.visible = false

func end():
	Functions.sfx_play("res://sounds/damage.mp3")
	defsprite.play("end")
	oversprite.play("end")
	await defsprite.animation_finished
	queue_free()
