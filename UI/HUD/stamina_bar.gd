extends HBoxContainer

const rect_scene = preload("res://UI/stamina_rect.tscn")
var max_stamina := 3

func _ready() -> void:
	max_stamina = int(Globals.staminas)
	for i in range(max_stamina):
		var rect = rect_scene.instantiate()
		add_child(rect)
		move_child(rect, 0)
		#await get_tree().create_timer(0.3 * (i + 1), false).timeout

func update(stamina: float):
	var children = get_children()
	
	for i in range(children.size()):
		var fill_amount = clamp(stamina - i, 0.0, 1.0)
		children[get_child_count() - i - 1].set_fill(fill_amount)

func _process(delta: float) -> void:
	update(Globals.currentStaminas)
