extends HBoxContainer

var RECT_SCENE = preload("res://UI/HUD/live_rect.tscn")

func _ready() -> void:
	get_parent().add_theme_constant_override("separation", 0)
	Events.overlives_changed.connect(update_lives)
	update_lives(0)

func update_lives(lives: int):
	if lives < 0:
		return
	var diff = lives - get_child_count()
	for i in range(abs(diff)):
		add_live() if diff > 0 else remove_live()

func add_live():
	get_parent().add_theme_constant_override("separation", 4)
	var rect = RECT_SCENE.instantiate()
	add_child(rect)
	move_child(rect, 0)
	rect.over()
	
func remove_live():
	get_child(0).end()
	if get_child_count() == 0:
		get_parent().add_theme_constant_override("separation", 0)
