extends ColorRect

var x = randf_range(-200.0, 200.0)
#var y = randf_range(-1000.0, -500.0)
var y = -1000.0
var gr = 2000.0

func _ready() -> void:
	Events.unpaused.connect(_on_unp)
	if Saves.data["bars"] == 0.0:
		modulate.a = 0.0

func _on_unp():
	if Saves.data["bars"] == 0.0:
		modulate.a = 0.0
	else:
		modulate.a = 1.0

func _process(delta: float) -> void:
	if get_parent().died == true:
		y += gr * delta
		position.y += y * delta
		position.x += x * delta
		rotation += x / 10 * delta
