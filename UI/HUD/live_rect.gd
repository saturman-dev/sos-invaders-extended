extends Control

@onready var defsprite = $AnimatedSprite2D
@onready var oversprite = $over

func over():
	oversprite.visible = true
	defsprite.visible = false

func end():
	reparent(get_tree().get_first_node_in_group("endedLivesManager"))
	Functions.sfx_play("res://sounds/damage.mp3")
	defsprite.play("end")
	oversprite.play("end")
	if Globals.lives == 0:
		Functions.stop_all_sfx()
	await defsprite.animation_finished
	queue_free()
