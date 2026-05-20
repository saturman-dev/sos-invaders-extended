extends CanvasLayer

@onready var move = $move
@onready var shoot = $shoot

var Atween: Tween

func show_move():
	move.modulate.a = 0.0
	move.show()
	Atween = create_tween()
	Atween.tween_property(move, "modulate:a", 1.0, 1.0)

func hide_move():
	move.hide()

func show_shoot():
	shoot.modulate.a = 0.0
	shoot.show()
	Atween = create_tween()
	Atween.tween_property(shoot, "modulate:a", 1.0, 1.0)

func hide_shoot():
	shoot.hide()

func _process(delta: float) -> void:
	if Saves.data["educated"] == true:
		queue_free()
	else:
		go()
		set_process(false)

func go():
	show_shoot()
	show_move()

var moved = false
var shooted = false

func _input(event):
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_down") or event.is_action_pressed("ui_up"):
		if Globals.game_running == true:
			hide_move()
			moved = true
			if moved == true and shooted == true:
				Saves.data["educated"] = true
	if event.is_action_pressed("ui_accept"):
		if Globals.game_running == true:
			hide_shoot()
			shooted = true
			if moved == true and shooted == true:
				Saves.data["educated"] = true
