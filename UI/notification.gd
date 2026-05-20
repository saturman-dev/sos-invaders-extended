extends CanvasLayer

@onready var label1 := $BG/Label1
@onready var label2 := $BG/Label2
@onready var bg := $BG

var Atween: Tween

func notify(notification_text: String = "Some notification", notification_info: String = "More info ahh"):
	var pos = bg.position.x
	if Globals.notification_running == true:
		await Events.notification_finished
	Globals.notification_running = true
	label1.text = notification_text
	label2.text = notification_info
	Atween = create_tween()
	Atween.tween_property(bg, "position", Vector2(-pos, 0.0), 0.5).as_relative().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await Atween.finished
	await get_tree().create_timer(3.0).timeout
	Atween = create_tween()
	Atween.tween_property(bg, "position", Vector2(pos, 0.0), 0.5).as_relative().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await Atween.finished
	queue_free()
	Globals.notification_running = false
	Events.notification_finished.emit()
