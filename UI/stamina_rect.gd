extends ColorRect

@onready var s = $stamina
var t: Tween
var able = false
var spawn_time = 0.2
var target_size = 20.0
var c := Color("59a5ff")
var cc: Color

func _ready() -> void:
	cc = s.color
	size.x = 0
	t = create_tween()
	t.tween_property(s, "size:x", target_size, spawn_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_callback(func(): able = true)
	t.tween_callback(func(): s.color = c)
	t.tween_callback(func(): size.x = target_size)

func loss():
	s.size.x = 0
	s.color = cc
	t = create_tween()
	t.tween_property(s, "size:x", target_size, 2.0 * Saves.data["speed_modifier"])
	t.tween_callback(func(): able = true)
	t.tween_callback(func(): s.color = c)
