extends Label

var time_elapsed := 0.0

func _process(delta: float) -> void:
	time_elapsed += delta
	var minutes := int(time_elapsed) / 60
	var seconds := int(time_elapsed) % 60
	text = "%02d:%02d" % [minutes, seconds]
	Globals.secs = seconds
	Globals.time = text
