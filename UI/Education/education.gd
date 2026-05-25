extends CanvasLayer

@onready var move := $move
@onready var shoot := $shoot
@onready var dash := $dash

var Atween: Tween

func show_move():
	move.show()
	Atween = create_tween()
	Atween.tween_property(move, "modulate:a", 1.0, 1.0)

func hide_move():
	move.modulate = Color("ffdf00")
	Atween = create_tween()
	Atween.tween_property(move, "modulate:a", 0.0, 1.0)

func show_shoot():
	shoot.show()
	Atween = create_tween()
	Atween.tween_property(shoot, "modulate:a", 1.0, 1.0)

func hide_shoot():
	shoot.modulate = Color("ff6c5a")
	Atween = create_tween()
	Atween.tween_property(shoot, "modulate:a", 0.0, 1.0)

func show_dash():
	dash.show()
	Atween = create_tween()
	Atween.tween_property(dash, "modulate:a", 1.0, 1.0)

func hide_dash():
	dash.modulate = Color("59a5ff")
	Atween = create_tween()
	Atween.tween_property(dash, "modulate:a", 0.0, 1.0)

func _ready() -> void:
	if Saves.data["educated"] == true:
		queue_free()
	else:
		go()

func go():
	move.modulate.a = 0.0
	shoot.modulate.a = 0.0
	dash.modulate.a = 0.0
	show_shoot()
	await get_tree().create_timer(0.2, false).timeout
	show_move()
	await get_tree().create_timer(0.2, false).timeout
	show_dash()

var moved = false
var shooted = false
var dashed = false

func _input(event):
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_down") or event.is_action_pressed("ui_up"):
		if moved == true:
			return
		if Globals.game_running == true:
			hide_move()
			moved = true
			check_educated()
	if event.is_action_pressed("ui_accept") and shooted == false:
		if Globals.game_running == true:
			hide_shoot()
			shooted = true
			check_educated()
	if event.is_action_pressed("dash") and dashed == false:
		if Globals.game_running == true:
			hide_dash()
			dashed = true
			check_educated()

func check_educated():
	if moved == true and dashed == true and shooted == true:
		Saves.data["educated"] = true
