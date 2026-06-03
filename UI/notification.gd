extends CanvasLayer

@onready var text := $hbox/BG/text

@onready var bg := $hbox/BG

var Atween: Tween

func notify(notification_text: String = "Some notification"):
	var pos = bg.position.x
	if Globals.notification_running == true:
		await Events.notification_finished
	Globals.notification_running = true
	text.text = notification_text
	Atween = create_tween()
	Atween.tween_property(bg, "position", Vector2(-pos, 0.0), 0.5).as_relative().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await Atween.finished
	await get_tree().create_timer(3.0).timeout
	if not is_inside_tree(): return
	Atween = create_tween()
	Atween.tween_property(bg, "position", Vector2(pos, 0.0), 0.5).as_relative().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await Atween.finished
	queue_free()
	Globals.notification_running = false
	Events.notification_finished.emit()
