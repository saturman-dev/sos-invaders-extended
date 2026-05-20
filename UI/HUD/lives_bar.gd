extends HBoxContainer

var RECT_SCENE = preload("res://UI/HUD/live_rect.tscn")

func _ready() -> void:
	Globals.setDefHp()
	Events.deflives_changed.connect(update_lives)
	update_lives(Globals.deflives)

func update_lives(lives: int):
	if lives < 0:
		return
	var diff = lives - get_child_count()
	for i in range(abs(diff)):
		add_live() if diff > 0 else remove_live()

func add_live():
	var rect = RECT_SCENE.instantiate()
	add_child(rect)
	move_child(rect, 0)
	
func remove_live():
	get_child(0).end()
