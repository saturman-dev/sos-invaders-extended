extends Control

@onready var bar = $bar
@onready var sprite = $Sprite

var Atween: Tween
var Btween: Tween

var fade := 0.5

func _ready() -> void:
	Atween = create_tween()
	Atween.tween_property(bar, "size:x", 0.0, Globals.speedTimer)
	await Atween.finished
	Atween = create_tween()
	Atween.tween_property(sprite, "position:y", -20.0, fade).as_relative().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	Btween = create_tween()
	Btween.tween_property(self, "modulate:a", 0.0, fade)
	await Btween.finished
	queue_free()
