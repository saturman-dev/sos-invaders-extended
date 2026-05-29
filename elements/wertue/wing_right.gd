extends Sprite2D

var SPEEDMOD := 1.0
var NEO := 0

var Atween: Tween
var rot = 30.0
var rottime = 0.75

var x = randf_range(300.0, 700.0)
var y = -750.0
var gr = 2000.0

func _ready() -> void:
	await get_tree().process_frame
	rotation_degrees = -rot/2
	rotatee()

func left():
	rot *= -1
	x *= -1

func rotatee():
	while self:
		Atween = create_tween()
		Atween.tween_property(self, "rotation_degrees", rot, rottime / get_parent().SPEEDMOD).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		await Atween.finished
		Atween = create_tween()
		Atween.tween_property(self, "rotation_degrees", -rot, rottime / get_parent().SPEEDMOD).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		await Atween.finished

func die():
	rot = 0.0
	if Atween.is_running():
		Atween.kill()

func _process(delta: float) -> void:
	if get_parent().has_method("die"):
		if get_parent().died == true:
			y += gr * delta
			position.y += y * delta
			position.x += x * delta
			rotation_degrees += x / 10 * delta
