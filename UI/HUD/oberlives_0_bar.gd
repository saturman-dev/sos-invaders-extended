extends HBoxContainer

var RECT_SCENE = preload("res://UI/HUD/live_rect0.tscn")

func _ready() -> void:
	Events.overlives_changed.connect(update_lives)
	ready_animation()

func ready_animation():
	await get_tree().create_timer(0.2, false).timeout
	for i in range(Globals.def_hp):
		var rect = RECT_SCENE.instantiate()
		add_child(rect)
		move_child(rect, 0)
		rect.get_child(0).play("over")
		Functions.sfx_play("res://sounds/hpStart.mp3", -10.0, 0.5 + float((i+1)/10))
		var target_scale = rect.get_child(0).scale
		rect.get_child(0).scale = Vector2.ZERO
		var rectTween = create_tween()
		rectTween.tween_property(rect.get_child(0), "scale", target_scale, 1.0 * (i+1)).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		await get_tree().create_timer(0.2 * (i+1), false).timeout

func update_lives(lives: int):
	if lives < 0:
		return
	var target_amount = Globals.def_hp - lives
	var diff = get_child_count() - target_amount
	for i in range(abs(diff)):
		add_live0() if diff < 0 else remove_live0()

func add_live0():
	var rect = RECT_SCENE.instantiate()
	add_child(rect)
	rect.get_child(0).play("over")

func remove_live0():
	if get_child_count() <= 0:
		return
	get_child(get_child_count() - 1).queue_free()
