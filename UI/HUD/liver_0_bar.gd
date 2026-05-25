extends HBoxContainer

var RECT_SCENE = preload("res://UI/HUD/live_rect0.tscn")

func _ready() -> void:
	Events.deflives_changed.connect(update_lives)
	update_lives(Globals.deflives)

func update_lives(lives: int):
	if lives < 0:
		return
	var target_amount = Globals.def_hp - Globals.deflives
	var diff = get_child_count() - target_amount
	for i in range(abs(diff)):
		add_live0() if diff < 0 else remove_live0()

func add_live0():
	var rect = RECT_SCENE.instantiate()
	add_child(rect)

func remove_live0():
	if get_child_count() <= 0:
		return
	get_child(get_child_count() - 1).queue_free()
