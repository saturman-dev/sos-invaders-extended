extends Label

var time_elapsed := 0.0

func _ready() -> void:
	ready_animation()
	if Saves.data["educated"] == false:
		text = "00:00"

func ready_animation():
	hide()
	await get_tree().create_timer(0.2, false).timeout
	show()
	await get_tree().create_timer(0.03, false).timeout
	hide()
	await get_tree().create_timer(0.05, false).timeout
	show()
	await get_tree().create_timer(0.04, false).timeout
	hide()
	await get_tree().create_timer(0.075, false).timeout
	show()
	await get_tree().create_timer(0.07, false).timeout
	hide()
	await get_tree().create_timer(0.15, false).timeout
	show()
	await get_tree().create_timer(0.15, false).timeout
	hide()
	await get_tree().create_timer(0.25, false).timeout
	show()

func _process(delta: float) -> void:
	if Saves.data["educated"] == false:
		return
	time_elapsed += delta
	var minutes := int(time_elapsed) / 60
	var seconds := int(time_elapsed) % 60
	text = "%02d:%02d" % [minutes, seconds]
	Globals.secs = seconds
	Globals.time = text
