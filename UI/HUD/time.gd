extends Label

var time_elapsed := 0.0

func _ready() -> void:
	ready_animation()
	text = "00:00"

@onready var parent = get_parent().get_parent()

func ready_animation():
	parent.hide()
	await get_tree().create_timer(0.2, false).timeout
	parent.show()
	await get_tree().create_timer(0.03, false).timeout
	parent.hide()
	await get_tree().create_timer(0.05, false).timeout
	parent.show()
	await get_tree().create_timer(0.04, false).timeout
	parent.hide()
	await get_tree().create_timer(0.075, false).timeout
	parent.show()
	await get_tree().create_timer(0.07, false).timeout
	parent.hide()
	await get_tree().create_timer(0.15, false).timeout
	parent.show()
	await get_tree().create_timer(0.15, false).timeout
	parent.hide()
	await get_tree().create_timer(0.25, false).timeout
	parent.show()

func _process(delta: float) -> void:
	if Globals.paused: return
	if Saves.data["educated"] == false:
		return
	time_elapsed += delta
	var minutes := int(time_elapsed) / 60
	var seconds := int(time_elapsed) % 60
	text = "%02d:%02d" % [minutes, seconds]
	Globals.secs = seconds
	Globals.time = text
	Globals.timeSeconds = int(time_elapsed)
